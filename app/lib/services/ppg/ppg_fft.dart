import 'dart:math' as math;

/// 快速傅里叶变换工具
///
/// 功能说明: 提供 radix-2 FFT 与 Hann 窗，用于脉搏波频谱分析
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class PpgFft
{
  /// 计算实数序列的幅度谱
  ///
  /// [input] 输入信号，内部自动补零到 2 的幂
  /// 返回长度为 n/2 的幅度谱
  static List<double> magnitudes(List<double> input)
  {
    if (input.isEmpty)
    {
      return <double>[];
    }
    final size = nextPowerOfTwo(input.length);
    final real = List<double>.filled(size, 0);
    final imag = List<double>.filled(size, 0);
    for (var index = 0; index < input.length; index++)
    {
      real[index] = input[index];
    }
    _transform(real, imag);
    final half = size ~/ 2;
    final result = List<double>.filled(half, 0);
    for (var index = 0; index < half; index++)
    {
      result[index] = math.sqrt(real[index] * real[index] + imag[index] * imag[index]);
    }
    return result;
  }

  /// 施加 Hann 窗
  ///
  /// [input] 输入信号
  /// 返回加窗后的新序列
  static List<double> hann(List<double> input)
  {
    final length = input.length;
    if (length <= 1)
    {
      return List<double>.from(input);
    }
    final result = List<double>.filled(length, 0);
    for (var index = 0; index < length; index++)
    {
      final weight = 0.5 - 0.5 * math.cos(2 * math.pi * index / (length - 1));
      result[index] = input[index] * weight;
    }
    return result;
  }

  /// 取不小于输入长度的最小 2 的幂
  ///
  /// [length] 原始长度
  static int nextPowerOfTwo(int length)
  {
    var size = 1;
    while (size < length)
    {
      size = size * 2;
    }
    return size;
  }

  /// 原地执行基 2 FFT
  ///
  /// [real] 实部数组
  /// [imag] 虚部数组
  static void _transform(List<double> real, List<double> imag)
  {
    final size = real.length;
    if (size <= 1)
    {
      return;
    }

    // 1. 位反转重排
    var target = 0;
    for (var index = 1; index < size; index++)
    {
      var bit = size >> 1;
      while ((target & bit) != 0)
      {
        target ^= bit;
        bit >>= 1;
      }
      target ^= bit;
      if (index < target)
      {
        final tempReal = real[index];
        real[index] = real[target];
        real[target] = tempReal;
        final tempImag = imag[index];
        imag[index] = imag[target];
        imag[target] = tempImag;
      }
    }

    // 2. 蝶形运算
    var length = 2;
    while (length <= size)
    {
      final angle = -2 * math.pi / length;
      final wRealStep = math.cos(angle);
      final wImagStep = math.sin(angle);
      for (var start = 0; start < size; start += length)
      {
        var wReal = 1.0;
        var wImag = 0.0;
        final half = length ~/ 2;
        for (var offset = 0; offset < half; offset++)
        {
          final evenIndex = start + offset;
          final oddIndex = evenIndex + half;
          final oddReal = real[oddIndex] * wReal - imag[oddIndex] * wImag;
          final oddImag = real[oddIndex] * wImag + imag[oddIndex] * wReal;
          real[oddIndex] = real[evenIndex] - oddReal;
          imag[oddIndex] = imag[evenIndex] - oddImag;
          real[evenIndex] = real[evenIndex] + oddReal;
          imag[evenIndex] = imag[evenIndex] + oddImag;
          final nextReal = wReal * wRealStep - wImag * wImagStep;
          wImag = wReal * wImagStep + wImag * wRealStep;
          wReal = nextReal;
        }
      }
      length = length * 2;
    }
  }
}
