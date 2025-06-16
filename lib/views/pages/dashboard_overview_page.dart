import 'package:flutter/material.dart';
import '../../viewmodels/dashboard_overview_viewmodel.dart';

class DashboardOverviewPage extends StatelessWidget {
  const DashboardOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardOverviewViewModelBuilder(
      builder: (context, vm, child) {
        return Container(
          color: const Color(0xFFF8FAFF),
          padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  _statCard(
                    value: "${vm.totalUsers}",
                    desc: "Tổng số Người dùng",
                    color: const Color(0xFF6D5DF6),
                  ),
                  const SizedBox(width: 32),
                  _statCard(
                    value: "${vm.activeUsers}",
                    desc: "Người dùng đang hoạt động",
                    color: const Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 32),
                  _statCard(
                    value: "${vm.pendingContents}",
                    desc: "Nội dung chờ xử lý",
                    color: const Color(0xFFF59E42),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard({required String value, required String desc, required Color color}) {
    return Expanded(
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}