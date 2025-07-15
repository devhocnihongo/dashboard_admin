import 'package:dashboard_admin/views/pages/commission_management_page.dart';
import 'package:flutter/material.dart';
import 'dashboard_overview_page.dart';
import 'user_management_page.dart';
import 'content_moderation_page.dart';
import 'discount_code_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final VoidCallback? onLogout;
  const AdminDashboardPage({Key? key, this.onLogout}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  final _pages = [
    const DashboardOverviewPage(),
    const UserManagementPage(),
    const ContentModerationPage(),
    const DiscountCodeManagementPage(),
    const CommissionManagementPage(),
  ];

  final _pageTitles = [
    "Tổng quan Dashboard",
    "Quản lý Người dùng",
    "Kiểm duyệt Nội dung",
    "Quản lý Mã Giảm Giá",
    "Tiền Hoa Hồng"
  ];

  void _onSelectMenu(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildMenuItem({required int index, required IconData icon, required String label}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onSelectMenu(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFF4F8DFD)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
              : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey[800]),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Row(
        children: [
          Container(
            width: 240,
            color: Colors.white,
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: const [
                    SizedBox(width: 16),
                    Icon(Icons.account_circle, color: Color(0xFF6D5DF6), size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                buildMenuItem(index: 0, icon: Icons.dashboard_rounded, label: "Dashboard"),
                buildMenuItem(index: 1, icon: Icons.people_alt_outlined, label: "Quản lý Người dùng"),
                buildMenuItem(index: 2, icon: Icons.edit_note, label: "Kiểm duyệt Nội dung"),
                buildMenuItem(index: 3, icon: Icons.card_giftcard, label: "Mã Giảm Giá"),
                buildMenuItem(index: 4, icon: Icons.attach_money, label: "Tiền Hoa Hồng"),
                const Spacer(),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  height: 80,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
                      Text(
                        _pageTitles[_selectedIndex],
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            "Admin",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFF1F5F9),
                            child: Icon(Icons.settings, color: Color(0xFF6D5DF6)),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              backgroundColor: const Color(0xFFF8FAFF),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.logout, color: Color(0xFF2563EB)),
                            label: const Text("Đăng xuất", style: TextStyle(color: Color(0xFF2563EB))),
                            onPressed: () {
                              if (widget.onLogout != null) widget.onLogout!();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(child: _pages[_selectedIndex]),
                // Footer
                const SizedBox(height: 10),
                const Text(
                  "Admin Dashboard © 2025 - Agrimarket",
                  style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}