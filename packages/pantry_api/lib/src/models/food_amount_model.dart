import 'package:equatable/equatable.dart';

import '../util.dart';

class FoodAmountException implements Exception {
  final String message;

  FoodAmountException([this.message = "Unknown amount"]);
}

/// Amount of remaining product, or expired
enum Amount { full, half, low, empty, expired }

class FoodAmount extends Equatable {
  final Amount amount;

  /// Helper to convert between String <-> eNum for Firebase
  static final Map<String, Amount> amountMap = {
    for (var amount in Amount.values) describeEnum(amount): amount
  };

  const FoodAmount(this.amount);

  static const full = FoodAmount(Amount.full);

  String get displayName => this.toString().capitalize();

  static List<Amount> get amounts => List.of(Amount.values);

  factory FoodAmount.fromString(String amount) {
    if (!amountMap.keys.contains(amount)) {
      throw FoodAmountException("Unknown food amount: $amount");
    } else {
      final foodAmount = amountMap[amount]!;
      return FoodAmount(foodAmount);
    }
  }

  @override
  String toString() => describeEnum(amount);

  @override
  List<Object> get props => [amount];
}
