import 'dart:math' as math;

import '../../constant/num_constant.dart';
import '../../constant/str_constant.dart';
import 'ppg_analysis.dart';
import 'ppg_fft.dart';
import 'ppg_filter.dart';

/// 光电容积脉搏波分析引擎
///
/// 功能说明: 接收逐帧红色通道均值，完成重采样、滤波、频谱分析与 HRV 计算
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class PpgEngine
{
  /// 采样率，单位 Hz
  static const double sampleRate = 30.0;

  /// 原始信号
  final List<double> _values = <double>[];

  /// 对应时间戳，单位秒
  final List<double> _times = <double>[];

  /// 采样点数量
  int get sampleCount => _values.length;

  /// 已采集时长，单位秒
  double get duration => _times.isEmpty ? 0 : _times.last - _times.first;

  /// 是否已满足最短分析时长
  bool get hasEnoughData => duration >= NumberConstants.MEASURE_MIN_VALID_SEC;

  /// 添加一个采样点
  ///
  /// [value] 红色通道均值
  /// [timeSec] 采样时刻，单位秒
  void addSample(double value, double timeSec)
  {
    if (value.isNaN || value.isInfinite)
    {
      return;
    }
    _values.add(value);
    _times.add(timeSec);
  }

  /// 清空缓存
  void reset()
  {
    _values.clear();
    _times.clear();
  }

  /// 取最近若干点的归一化波形，用于实时绘制
  ///
  /// [count] 点数
  /// 返回 0-1 区间的相对幅值
  List<double> recentWaveform(int count)
  {
    if (_values.isEmpty)
    {
      return <double>[];
    }
    final start = math.max(0, _values.length - count);
    final slice = _values.sublist(start);
    var minValue = slice.first;
    var maxValue = slice.first;
    for (final item in slice)
    {
      minValue = math.min(minValue, item);
      maxValue = math.max(maxValue, item);
    }
    final span = maxValue - minValue;
    if (span <= 0)
    {
      return List<double>.filled(slice.length, 0.5);
    }
    return slice.map((item) => (item - minValue) / span).toList();
  }

  /// 执行分析
  ///
  /// 返回 null 表示数据不足或无法解析出有效心率
  PpgAnalysis? analyze()
  {
    if (!hasEnoughData)
    {
      return null;
    }

    // 1. 重采样到均匀采样率
    final uniform = _resample();
    if (uniform.length < NumberConstants.FFT_WINDOW_SIZE ~/ 2)
    {
      return null;
    }

    // 2. 去趋势与带通滤波
    final window = (NumberConstants.DETREND_WINDOW_SEC * sampleRate).round();
    final detrended = PpgFilter.detrend(uniform, window);
    final filtered = PpgFilter.bandPass(
      detrended,
      sampleRate,
      NumberConstants.BANDPASS_LOW_HZ,
      NumberConstants.BANDPASS_HIGH_HZ,
    );

    // 3. 取末端窗口做频谱分析
    const windowSize = NumberConstants.FFT_WINDOW_SIZE;
    final segment = filtered.length > windowSize
        ? filtered.sublist(filtered.length - windowSize)
        : filtered;

    // 4. 频谱峰值定位
    final spectrum = PpgFft.magnitudes(PpgFft.hann(segment));
    if (spectrum.isEmpty)
    {
      return null;
    }
    // FFT 内部会补零到 2 的幂，频率分辨率必须按补零后的长度计算，
    // 否则会系统性高估心率（补零越多，偏差越大）。
    final binCount = PpgFft.nextPowerOfTwo(segment.length);
    final lowBin = (NumberConstants.BANDPASS_LOW_HZ * binCount / sampleRate).ceil();
    final highBin = (NumberConstants.BANDPASS_HIGH_HZ * binCount / sampleRate).floor();
    if (highBin <= lowBin || highBin >= spectrum.length)
    {
      return null;
    }

    var peakBin = lowBin;
    var peakPower = 0.0;
    var bandPower = 0.0;
    for (var bin = lowBin; bin <= highBin; bin++)
    {
      final power = spectrum[bin] * spectrum[bin];
      bandPower = bandPower + power;
      if (power > peakPower)
      {
        peakPower = power;
        peakBin = bin;
      }
    }
    if (bandPower <= 0 || peakBin <= lowBin || peakBin >= highBin)
    {
      return null;
    }

    // 5. 抛物线插值细化频率
    final leftPower = spectrum[peakBin - 1] * spectrum[peakBin - 1];
    final rightPower = spectrum[peakBin + 1] * spectrum[peakBin + 1];
    final denominator = leftPower - 2 * peakPower + rightPower;
    final offset = denominator.abs() < 1e-9 ? 0.0 : 0.5 * (leftPower - rightPower) / denominator;
    final refinedBin = peakBin + offset;
    final frequency = refinedBin * sampleRate / binCount;
    final heartRate = frequency * NumberConstants.SIXTY;

    // 6. 质量分与 HRV
    final quality = peakPower / bandPower;
    final intervals = _detectIntervals(filtered);
    final rmssd = _computeRmssd(intervals);
    final sdnn = _computeSdnn(intervals);

    if (heartRate < NumberConstants.HR_MIN || heartRate > NumberConstants.HR_MAX)
    {
      return null;
    }

    return PpgAnalysis(
      heartRate: heartRate,
      sdnn: sdnn,
      rmssd: rmssd,
      quality: quality.clamp(NumberConstants.ZERO, NumberConstants.ONE),
    );
  }

  /// 线性插值重采样为均匀序列
  ///
  /// 返回 30Hz 均匀采样序列
  List<double> _resample()
  {
    if (_times.length < 2)
    {
      return <double>[];
    }
    final startTime = _times.first;
    final endTime = _times.last;
    final total = ((endTime - startTime) * sampleRate).floor();
    if (total < 2)
    {
      return <double>[];
    }
    final result = List<double>.filled(total, 0);
    var cursor = 0;
    for (var index = 0; index < total; index++)
    {
      final targetTime = startTime + index / sampleRate;
      while (cursor < _times.length - 2 && _times[cursor + 1] < targetTime)
      {
        cursor++;
      }
      final t0 = _times[cursor];
      final t1 = _times[cursor + 1];
      final span = t1 - t0;
      final ratio = span <= 0 ? 0.0 : (targetTime - t0) / span;
      result[index] = _values[cursor] + (_values[cursor + 1] - _values[cursor]) * ratio;
    }
    return result;
  }

  /// 检测脉搏峰值并计算间期
  ///
  /// [signal] 带通滤波后的信号
  /// 返回峰值间期序列，单位毫秒
  List<double> _detectIntervals(List<double> signal)
  {
    if (signal.length < NumberConstants.FRAME_RATE_TARGET)
    {
      return <double>[];
    }
    var maxAmplitude = 0.0;
    for (final item in signal)
    {
      maxAmplitude = math.max(maxAmplitude, item.abs());
    }
    if (maxAmplitude <= 0)
    {
      return <double>[];
    }
    final threshold = maxAmplitude * 0.3;
    final minDistance = (sampleRate * 0.3).round();
    final peaks = <int>[];
    var lastPeak = -minDistance;
    for (var index = 1; index < signal.length - 1; index++)
    {
      final isLocalMax = signal[index] > signal[index - 1] && signal[index] >= signal[index + 1];
      if (!isLocalMax || signal[index] < threshold)
      {
        continue;
      }
      if (index - lastPeak < minDistance)
      {
        continue;
      }
      peaks.add(index);
      lastPeak = index;
    }
    final intervals = <double>[];
    for (var index = 1; index < peaks.length; index++)
    {
      intervals.add((peaks[index] - peaks[index - 1]) / sampleRate * 1000);
    }
    return intervals;
  }

  /// 计算 RMSSD
  ///
  /// [intervals] 峰值间期序列，单位毫秒
  double _computeRmssd(List<double> intervals)
  {
    if (intervals.length < 2)
    {
      return 0;
    }
    var sum = 0.0;
    var count = 0;
    for (var index = 1; index < intervals.length; index++)
    {
      final diff = intervals[index] - intervals[index - 1];
      if (diff.abs() > intervals[index] * 0.3)
      {
        continue;
      }
      sum = sum + diff * diff;
      count++;
    }
    if (count == 0)
    {
      return 0;
    }
    return math.sqrt(sum / count);
  }

  /// 计算 SDNN
  ///
  /// [intervals] 峰值间期序列，单位毫秒
  double _computeSdnn(List<double> intervals)
  {
    if (intervals.length < 2)
    {
      return 0;
    }
    var sum = 0.0;
    for (final item in intervals)
    {
      sum = sum + item;
    }
    final mean = sum / intervals.length;
    var variance = 0.0;
    for (final item in intervals)
    {
      variance = variance + (item - mean) * (item - mean);
    }
    return math.sqrt(variance / intervals.length);
  }

  /// 指标编码描述，用于日志
  String get engineName => StringConstants.METRIC_HEART_RATE;
}
