import 'vital_record.dart';

/// 分页查询结果
///
/// 功能说明: 承载记录列表的一次分页响应，避免网络层直接暴露原始结构
/// 时间: 2026-10-25
/// 作者: zhengchaojun
class RecordPage
{
  /// 当前页记录
  final List<VitalRecord> records;

  /// 总条数
  final int total;

  /// 构造函数
  const RecordPage({required this.records, required this.total});

  /// 是否还有下一页
  ///
  /// [loaded] 已加载条数
  bool hasMore(int loaded)
  {
    return loaded < total;
  }
}
