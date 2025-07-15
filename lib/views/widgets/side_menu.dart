import 'package:flutter/material.dart';
import '../pages/commission_management_page.dart';

class SideMenu extends StatelessWidget {
  final void Function(int) onMenuSelect;
  final int selectedIndex;

  const SideMenu({
    Key? key,
    required this.onMenuSelect,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text(
              'Admin Panel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            selected: selectedIndex == 0,
            leading: const Icon(Icons.people),
            title: const Text('Quản lý người dùng'),
            onTap: () => onMenuSelect(0),
          ),
          ListTile(
            selected: selectedIndex == 1,
            leading: const Icon(Icons.verified_user),
            title: const Text('Kiểm duyệt nội dung'),
            onTap: () => onMenuSelect(1),
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text("Quản lý hoa hồng"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const CommissionManagementPage(),
              ));
            },
          )
        ],
      ),
    );
  }
}