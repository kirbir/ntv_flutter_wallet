
// Token model for the wallet
class Token {
  final String mint;
  final String symbol;
  final String? name;
  final int? decimals;
  final String? logoUri;
  final double amount;

  const Token({
    required this.mint,
    required this.symbol,
    this.name,
    this.decimals,
    this.logoUri,
    required this.amount,
  });
}
