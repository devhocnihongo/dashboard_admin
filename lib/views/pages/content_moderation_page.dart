import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/store_detail_dialog.dart';
import 'product_list_page.dart';

class ContentModerationPage extends StatelessWidget {
  const ContentModerationPage({Key? key}) : super(key: key);

  void _toggleStoreVerify(BuildContext context, String storeId, String currentState) async {
    try {
      final newState = currentState == "verify" ? "pending" : "verify";
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .update({'state': newState});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFF),
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhà Cung Cấp',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4338CA),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'seller')
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Không có nhà cung cấp nào.",
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 18)),
                  );
                }
                final users = userSnapshot.data!.docs;
                return GridView.builder(
                  itemCount: users.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.75,
                    crossAxisSpacing: 64,
                    mainAxisSpacing: 48,
                  ),
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    final userData = userDoc.data() as Map<String, dynamic>;
                    final ownerName = userData['name'] ?? '';
                    final ownerUid = userData['uid'] ?? userDoc.id;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('stores')
                          .where('ownerUid', isEqualTo: ownerUid)
                          .limit(1)
                          .snapshots(),
                      builder: (context, storeSnapshot) {
                        String storeName = "(Chưa có tên shop)";
                        String address = "(Chưa có địa chỉ)";
                        String description = "(Chưa có mô tả)";
                        String? imageUrl;
                        String? storeId;
                        String state = "pending";
                        if (storeSnapshot.hasData &&
                            storeSnapshot.data!.docs.isNotEmpty) {
                          final store = storeSnapshot.data!.docs.first.data()
                          as Map<String, dynamic>;
                          final storeLocation = store['storeLocation'] as Map<String, dynamic>?;
                          storeName = store['name'] ?? "(Chưa có tên shop)";
                          address = storeLocation?['address'] ?? "(Chưa có địa chỉ)";
                          description = store['description'] ?? "(Chưa có mô tả)";
                          imageUrl = store['image'];
                          storeId = storeSnapshot.data!.docs.first.id;
                          state = store['state'] ?? "pending";
                        }

                        final isVerified = state == "verify";

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: storeId != null
                              ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductListPage(
                                  storeId: storeId!,
                                  storeName: storeName,
                                  ownerName: ownerName,
                                ),
                              ),
                            );
                          }
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFE9D8FD),
                                  radius: 34,
                                  backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                                      ? NetworkImage(imageUrl)
                                      : null,
                                  child: (imageUrl == null || imageUrl.isEmpty)
                                      ? const Icon(Icons.storefront, color: Color(0xFFB794F4), size: 32)
                                      : null,
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.person, color: Color(0xFF4338CA), size: 16),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              ownerName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Color(0xFF22223B),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 9),
                                      Row(
                                        children: [
                                          const Icon(Icons.store, color: Color(0xFFB794F4), size: 16),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              storeName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Color(0xFF4338CA),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 9),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              address,
                                              style: const TextStyle(fontSize: 14, color: Color(0xFF575757)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 9),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.info_outline, color: Colors.teal, size: 16),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              description,
                                              style: const TextStyle(fontSize: 14, color: Color(0xFF575757)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.verified, color: Colors.green, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            isVerified ? "Đã duyệt" : "Chưa duyệt",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isVerified ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          // SỬA ĐỔI TẠI ĐÂY:
                                          const Spacer(), // Thay thế SizedBox bằng Spacer
                                          if (storeId != null)
                                            Transform.scale(
                                              scale: 0.55,
                                              child: Switch(
                                                value: isVerified,
                                                onChanged: (val) {
                                                  _toggleStoreVerify(context, storeId!, state);
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => StoreDetailDialog(
                                              ownerName: ownerName,
                                              ownerUid: ownerUid,
                                              storeName: storeName,
                                              address: address,
                                              description: description,
                                              status: isVerified ? "Đã duyệt" : "Chưa duyệt",
                                              statusColor: isVerified ? Colors.green : Colors.red,
                                              imageUrl: imageUrl,
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.remove_red_eye, color: Colors.blue.shade700, size: 19),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Xem chi tiết",
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}