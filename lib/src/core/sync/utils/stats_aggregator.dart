class StatsAggregator {
  static Map<String, dynamic> build({
    required String shopId,
    required String bucket,
    required DateTime date,
    required double usd,
    required double zig,
    required int count,
  }) {
    return {
      "shop_id": shopId,
      "bucket": bucket,
      "sync_date": date.toIso8601String(),
      "total_sales_usd": usd,
      "total_sales_zig": zig,
      "transaction_count": count,
    };
  }
}
