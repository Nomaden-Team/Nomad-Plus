import '../datasources/loyalty_remote.dart';
import '../models/user_model.dart';

class LoyaltyRepository {
  final LoyaltyRemote remote;

  LoyaltyRepository(this.remote);

  Future<UserModel> syncCheckoutPoints({
    required String userId,
    required int currentPoints,
    required int currentTotalEarnedPoints,
    required int pointsUsed,
    required int pointsEarned,
  }) {
    return remote.syncCheckoutPoints(
      userId: userId,
      currentPoints: currentPoints,
      currentTotalEarnedPoints: currentTotalEarnedPoints,
      pointsUsed: pointsUsed,
      pointsEarned: pointsEarned,
    );
  }
}