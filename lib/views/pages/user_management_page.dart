import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String search = "";

  final int _rowsPerPage = 5;
  int _currentPage = 0;

  void _toggleUserStatus(String docId, bool newStatus) {
    FirebaseFirestore.instance.collection('users').doc(docId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFF),
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 30),
          SizedBox(
            width: 350,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm theo tên người dùng...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) {
                setState(() {
                  search = v;
                  _currentPage = 0;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Không có người dùng nào."));
                }

                var docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(search.toLowerCase());
                }).toList();

                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>? ?? {};
                  final bData = b.data() as Map<String, dynamic>? ?? {};
                  final aId = int.tryParse(aData['userId']?.toString() ?? '0') ?? 0;
                  final bId = int.tryParse(bData['userId']?.toString() ?? '0') ?? 0;
                  return aId.compareTo(bId);
                });

                int totalRows = docs.length;
                int totalPages = (totalRows / _rowsPerPage).ceil();
                int start = _currentPage * _rowsPerPage;
                int end = (_currentPage + 1) * _rowsPerPage;
                if (end > totalRows) end = totalRows;
                final pageDocs = docs.sublist(start, end);

                return Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        interactive: true,
                        thickness: 8,
                        radius: const Radius.circular(10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(const Color(0xFFF6F6FF)),
                              dataRowColor: MaterialStateProperty.all(Colors.white),
                              columnSpacing: 22,
                              columns: [
                                DataColumn(label: _headerCell('ID')),
                                DataColumn(label: _headerCell('TÊN NGƯỜI DÙNG')),
                                DataColumn(label: _headerCell('SỐ ĐIỆN THOẠI')),
                                DataColumn(label: _headerCell('EMAIL')),
                                DataColumn(label: _headerCell('NGÀY TẠO')),
                                DataColumn(label: _headerCell('VAI TRÒ')),
                                DataColumn(label: _headerCell('TRẠNG THÁI')),
                                DataColumn(label: _headerCell('HÀNH ĐỘNG')),
                              ],
                              rows: List.generate(
                                pageDocs.length,
                                    (idx) {
                                  final doc = pageDocs[idx];
                                  final data = doc.data() as Map<String, dynamic>? ?? {};
                                  final userId = (data['userId'] ?? '').toString();
                                  final name = data['name'] ?? '';
                                  final phone = data['phone'] ?? '';
                                  final email = data['email'] ?? '';
                                  final role = data['role'] ?? '';
                                  final rawStatus = data['status'];
                                  final bool isActive = (rawStatus is bool)
                                      ? rawStatus
                                      : (rawStatus is String)
                                      ? rawStatus.toLowerCase() == 'true'
                                      : false;
                                  dynamic createdRaw = data['createdAt'] ?? data['created'] ?? '';
                                  String createdStr = '';
                                  if (createdRaw is Timestamp) {
                                    final dt = createdRaw.toDate();
                                    createdStr = DateFormat('dd/MM/yyyy HH:mm').format(dt);
                                  } else if (createdRaw is String) {
                                    createdStr = createdRaw;
                                  }
                                  return DataRow(
                                    cells: [
                                      DataCell(_cell(userId.isNotEmpty
                                          ? userId
                                          : ((start + idx + 1).toString().padLeft(2, '0')))),
                                      DataCell(_cell(name)),
                                      DataCell(_cell(phone)),
                                      DataCell(_cell(email)),
                                      DataCell(_cell(createdStr)),
                                      DataCell(_cell(role)),
                                      DataCell(_statusBadge(
                                        isActive ? "Active" : "Inactive",
                                        isActive ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                                      )),
                                      DataCell(
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                isActive ? Icons.lock_open : Icons.lock,
                                                color: isActive ? Colors.green : Colors.red,
                                              ),
                                              tooltip: isActive ? 'Mở khoá' : 'Khóa',
                                              onPressed: () {
                                                _toggleUserStatus(doc.id, !isActive);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _currentPage > 0
                                  ? () => setState(() => _currentPage--)
                                  : null,
                            ),
                            Text('Trang ${_currentPage + 1} / $totalPages'),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _currentPage < totalPages - 1
                                  ? () => setState(() => _currentPage++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _headerCell(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F6FF),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _cell(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 15,
        color: Colors.black87,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    ),
  );
}

Widget _statusBadge(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}