import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class PriceTicker extends StatelessWidget {
  final Map<String, double> prices;

  const PriceTicker({
    super.key,
    required this.prices,
  });

  @override
  Widget build(BuildContext context) {
    // Check if prices is empty
    if (prices.isEmpty) {
      return Container(
        height: 40,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Center(
          child: Text('Loading prices...'),
        ),
      );
    }

    // Get top 5 coins and format their text
    final topCoins = prices.entries.take(5).map((coin) {
      return '${coin.key.toUpperCase()}: \$${coin.value.toStringAsFixed(2)}';
    }).join('   |   ');

    return Container(
      height: 40,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Marquee(
        text: topCoins,
        style: const TextStyle(fontSize: 16),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 20.0,
        velocity: 50.0,
        pauseAfterRound: const Duration(seconds: 1),
        startPadding: 10.0,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}
