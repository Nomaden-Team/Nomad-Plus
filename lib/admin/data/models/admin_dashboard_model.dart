class AdminDashboardModel {
  final int pendingOrders;
  final int processingOrders;
  final int readyOrders;
  final int doneOrdersToday;
  final int totalMembers;
  final int totalMenusAvailable;
  final int activeVouchers;
  final int todayRevenue;

  const AdminDashboardModel({
    required this.pendingOrders,
    required this.processingOrders,
    required this.readyOrders,
    required this.doneOrdersToday,
    required this.totalMembers,
    required this.totalMenusAvailable,
    required this.activeVouchers,
    required this.todayRevenue,
  });

  const AdminDashboardModel.empty()
      : pendingOrders = 0,
        processingOrders = 0,
        readyOrders = 0,
        doneOrdersToday = 0,
        totalMembers = 0,
        totalMenusAvailable = 0,
        activeVouchers = 0,
        todayRevenue = 0;
}