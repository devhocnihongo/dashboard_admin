import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardOverviewViewModel extends ChangeNotifier {
  int totalUsers = 0;
  int activeUsers = 0;
  int pendingContents = 0;

  DashboardOverviewViewModel() {
    fetchStats();
  }

  Future<void> fetchStats() async {
    final userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final users = userSnapshot.docs;
    int active = 0;
    for (final doc in users) {
      final data = doc.data();
      if (data['status'] == true) active++;
    }
    final pendingSnapshot = await FirebaseFirestore.instance
        .collection('contents')
        .where('status', isEqualTo: 'pending')
        .get();
    int pending = pendingSnapshot.docs.length;
    totalUsers = users.length;
    activeUsers = active;
    pendingContents = pending;
    notifyListeners();
  }
}

class DashboardOverviewViewModelBuilder extends StatefulWidget {
  final Widget Function(BuildContext, DashboardOverviewViewModel, Widget?) builder;
  const DashboardOverviewViewModelBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  State<DashboardOverviewViewModelBuilder> createState() => _DashboardOverviewViewModelBuilderState();
}

class _DashboardOverviewViewModelBuilderState extends State<DashboardOverviewViewModelBuilder> {
  late DashboardOverviewViewModel vm;
  @override
  void initState() {
    super.initState();
    vm = DashboardOverviewViewModel();
    vm.addListener(_onUpdate);
  }

  @override
  void dispose() {
    vm.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, vm, null);
}