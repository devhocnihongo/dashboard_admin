import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/store_detail_dialog.dart';
import 'product_list_page.dart';

class ContentModerationPage extends StatelessWidget {
  const ContentModerationPage({Key? key}) : super(key: key);

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
                    childAspectRatio: 2,
                    crossAxisSpacing: 32,
                    mainAxisSpacing: 24,
                  ),
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    final userData = userDoc.data() as Map<String, dynamic>;
                    final ownerName = userData['name'] ?? '';
                    final ownerUid = userData['uid'] ?? userDoc.id;
                    final userStatus = userData['status'];

                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('stores')
                          .where('ownerUid', isEqualTo: ownerUid)
                          .limit(1)
                          .get(),
                      builder: (context, storeSnapshot) {
                        String storeName = "(Chưa có tên shop)";
                        String address = "(Chưa có địa chỉ)";
                        String description = "(Chưa có mô tả)";
                        String status = "pending";
                        String? imageUrl;
                        String? storeId;
                        if (storeSnapshot.hasData &&
                            storeSnapshot.data!.docs.isNotEmpty) {
                          final store = storeSnapshot.data!.docs.first.data()
                          as Map<String, dynamic>;
                          storeName = store['name'] ?? "(Chưa có tên shop)";
                          address = store['address'] ?? "(Chưa có địa chỉ)";
                          description = store['description'] ?? "(Chưa có mô tả)";
                          status = store['state'] ?? "pending";
                          imageUrl = store['image'];
                          storeId = storeSnapshot.data!.docs.first.id;
                        }

                        String displayStatus;
                        Color displayColor;
                        if (userStatus == false ||
                            userStatus == "inactive" ||
                            userStatus == 0) {
                          displayStatus = "không hoạt động";
                          displayColor = Colors.red;
                        } else {
                          if (status == "active") {
                            displayStatus = "active";
                            displayColor = Colors.green;
                          } else if (status == "pending") {
                            displayStatus = "pending";
                            displayColor = Colors.orange;
                          } else if (status == "locked" || status == "banned") {
                            displayStatus = "khóa";
                            displayColor = Colors.red;
                          } else {
                            displayStatus = status;
                            displayColor = Colors.blueGrey;
                          }
                        }

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
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Chủ shop
                                      Row(
                                        children: [
                                          const Icon(Icons.person, color: Color(0xFF4338CA), size: 16),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              ownerName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF22223B),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Tên shop
                                      Row(
                                        children: [
                                          const Icon(Icons.store, color: Color(0xFFB794F4), size: 16),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              storeName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: Color(0xFF4338CA),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
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
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.info_outline, color: Colors.teal, size: 16),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              description,
                                              style: const TextStyle(fontSize: 13, color: Color(0xFF575757)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.verified, color: Colors.green, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                displayStatus,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: displayColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
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
                                                  status: displayStatus,
                                                  statusColor: displayColor,
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