import 'package:get/get.dart';

import '../../core/app_state.dart';
import '../../data/models/user_model.dart';

class LoyaltyController extends GetxController {
  final AppStateController appState = Get.find<AppStateController>();

  UserModel get user => appState.user;

  int get points => user.loyaltyPoints;
  int get totalEarned => user.totalEarnedPoints;
  String get tier => user.membershipTier.toLowerCase();

  double get multiplier {
    switch (tier) {
      case 'platinum':
        return 2.0;
      case 'gold':
        return 1.5;
      default:
        return 1.0;
    }
  }

  int get nextTierThreshold {
    switch (tier) {
      case 'bronze':
        return 100;
      case 'silver':
        return 300;
      case 'gold':
        return 800;
      default:
        return totalEarned;
    }
  }

  double get progress {
    switch (tier) {
      case 'bronze':
        return (totalEarned / 100).clamp(0.0, 1.0);
      case 'silver':
        return ((totalEarned - 100) / 200).clamp(0.0, 1.0);
      case 'gold':
        return ((totalEarned - 300) / 500).clamp(0.0, 1.0);
      case 'platinum':
        return 1.0;
      default:
        return 0.0;
    }
  }

  String get tierLabel => UserModel.getTierLabel(tier);
  String get tierIcon => UserModel.getTierIcon(tier);

  String get benefitText {
    return '${multiplier}x poin setiap pembelian';
  }
}