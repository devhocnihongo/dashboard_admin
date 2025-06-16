import 'package:flutter/material.dart';

class StoreDetailDialog extends StatelessWidget {
  final String ownerName;
  final String ownerUid;
  final String storeName;
  final String address;
  final String description;
  final String status;
  final Color statusColor;
  final String? imageUrl;

  const StoreDetailDialog({
    super.key,
    required this.ownerName,
    required this.ownerUid,
    required this.storeName,
    required this.address,
    required this.description,
    required this.status,
    required this.statusColor,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 110),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 480,
        child: Padding(
          padding: const EdgeInsets.all(28.0),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFE9D8FD),
                    radius: 38,
                    backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                        ? NetworkImage(imageUrl!)
                        : null,
                    child: (imageUrl == null || imageUrl!.isEmpty)
                        ? const Icon(Icons.store_mall_directory, color: Color(0xFFB794F4), size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 18),
                _kv('Chủ cửa hàng', ownerName),
                _kv('UID', ownerUid),
                _kv('Tên cửa hàng', storeName),
                _kv('Địa chỉ', address),
                _kv('Mô tả', description),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 120, child: Text("Trạng thái:", style: TextStyle(fontWeight: FontWeight.bold))),
                    Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4338CA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text("$key:", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}