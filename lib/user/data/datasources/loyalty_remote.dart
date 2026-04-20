import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

class LoyaltyRemote {
  final client = SupabaseService.client;

  Future<UserModel> syncCheckoutPoints({
    required String userId,
    required int currentPoints,
    required int currentTotalEarnedPoints,
    required int pointsUsed,
    required int pointsEarned,
  }) async {
    final updatedPoints =
        (currentPoints - pointsUsed + pointsEarned).clamp(0, 1 << 31);
    final updatedTotalEarned = currentTotalEarnedPoints + pointsEarned;
    final updatedTier = UserModel.getTier(updatedTotalEarned);

    final response = await client
        .from('users')
        .update({
          'loyalty_points': updatedPoints,
          'total_earned_points': updatedTotalEarned,
          'membership_tier': updatedTier,
        })
        .eq('id', userId)
        .select()
        .single();

    return UserModel.fromMap(response);
  }
}