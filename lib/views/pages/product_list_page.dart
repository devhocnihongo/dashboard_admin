import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductListPage extends StatefulWidget {
  final String storeId;
  final String storeName;
  final String ownerName;
  const ProductListPage({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.ownerName,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int currentPage = 0;
  static const int pageSize = 10;

  @override
  Widget build(BuildContext context) {
    final double tableWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sản phẩm của ${widget.storeName}'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4338CA),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFF),
      body: Center(
        child: SizedBox(
          width: tableWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFFF6F6FF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF64748B).withOpacity(0.08),
                          spreadRadius: 2,
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('products')
                          .where('storeId', isEqualTo: widget.storeId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Column(
                            children: [
                              _tableHeader(),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Chưa có sản phẩm nào.",
                                    style: TextStyle(fontSize: 18, color: Color(0xFF94A3B8)),
                                  ),
                                ),
                              ),
                              _paginationWidget(0, 1), // luôn để ở chân
                            ],
                          );
                        }
                        final products = snapshot.data!.docs;
                        final totalPages = (products.length / pageSize).ceil();
                        final start = currentPage * pageSize;
                        final end = ((currentPage + 1) * pageSize > products.length)
                            ? products.length
                            : (currentPage + 1) * pageSize;
                        final pageProducts = products.sublist(start, end);

                        return Column(
                          children: [
                            _tableHeader(),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: pageProducts.length,
                                  itemBuilder: (context, idx) {
                                    final doc = pageProducts[idx];
                                    final item = doc.data() as Map<String, dynamic>;
                                    final String description = item["description"] ?? '';
                                    final String shortDesc = description.length > 30
                                        ? '${description.substring(0, 30)}...'
                                        : description;
                                    // CỘT TÊN SẢN PHẨM
                                    return Row(
                                      children: [
                                        _cellCM('${start + idx + 1}', width: 40, align: TextAlign.center),
                                        _cellCM(item["category"] ?? '', width: 110),
                                        // SỬA: Dùng Text với ellipsis, maxLines: 1
                                        _cellCM(
                                          Text(
                                            item["name"] ?? '',
                                            style: const TextStyle(fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          width: 170,
                                          isWidget: true,
                                        ),
                                        SizedBox(
                                          width: 70,
                                          height: 50,
                                          child: Center(
                                            child: item["image"] != null && (item["image"] as String).isNotEmpty
                                                ? Image.network(
                                              item["image"],
                                              width: 32,
                                              height: 32,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                            )
                                                : const Icon(Icons.image_not_supported, color: Colors.grey, size: 28),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 220,
                                          child: Text(
                                            shortDesc,
                                            style: const TextStyle(fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        _cellCM(
                                          item["price"] != null
                                              ? "${item["price"].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ"
                                              : "",
                                          width: 110,
                                          align: TextAlign.right,
                                        ),
                                        _cellCM(item["quantity"]?.toString() ?? '', width: 90, align: TextAlign.right),
                                        _cellCM(item["unit"] ?? '', width: 70, align: TextAlign.center),
                                        _cellCM(
                                          _formatCreatedAtShort(item["createdAt"]),
                                          width: 110,
                                          align: TextAlign.center,
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove_red_eye, size: 20, color: Colors.blue),
                                                tooltip: 'Xem chi tiết',
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: Text(item["name"] ?? "Chi tiết sản phẩm"),
                                                      content: SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            if (item["image"] != null && (item["image"] as String).isNotEmpty)
                                                              Image.network(item["image"], width: 150, height: 150),
                                                            const SizedBox(height: 8),
                                                            Text("Danh mục: ${item["category"] ?? ''}"),
                                                            Text("Mô tả: ${item["description"] ?? ''}"),
                                                            Text("Giá: ${item["price"] ?? ''}"),
                                                            Text("Số lượng: ${item["quantity"] ?? ''}"),
                                                            Text("Đơn vị: ${item["unit"] ?? ''}"),
                                                            Text("Ngày tạo: ${_formatCreatedAtShort(item["createdAt"])}"),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text('Đóng'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.check_circle, size: 20, color: Colors.green),
                                                tooltip: 'Duyệt sản phẩm',
                                                onPressed: () {
                                                  // TODO: Cập nhật trạng thái duyệt sản phẩm
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.cancel, size: 20, color: Colors.red),
                                                tooltip: 'Hủy duyệt sản phẩm',
                                                onPressed: () {
                                                  // TODO: Cập nhật trạng thái hủy duyệt sản phẩm
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                            _paginationWidget(currentPage, totalPages),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _tableHeader() {
    return Row(
      children: [
        _cellCM("ID", bold: true, width: 40, align: TextAlign.center),
        _cellCM("Danh mục", bold: true, width: 110),
        _cellCM("Tên sản phẩm", bold: true, width: 170),
        _cellCM("Ảnh", bold: true, width: 70, align: TextAlign.center),
        _cellCM("Mô tả sản phẩm", bold: true, width: 220),
        _cellCM("Giá", bold: true, width: 110, align: TextAlign.right),
        _cellCM("Số lượng", bold: true, width: 90, align: TextAlign.right),
        _cellCM("Đơn vị", bold: true, width: 70, align: TextAlign.center),
        _cellCM("Ngày tạo", bold: true, width: 110, align: TextAlign.center),
        _cellCM("Hành động", bold: true, width: 120, align: TextAlign.center),
      ],
    );
  }

  Widget _paginationWidget(int currentPage, int totalPages) {
    if (totalPages == 0) totalPages = 1;
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: currentPage > 0 ? () => setState(() => this.currentPage--) : null,
          ),
          ...List.generate(totalPages, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentPage == index
                      ? const Color(0xFF4338CA)
                      : Colors.white,
                  foregroundColor: currentPage == index
                      ? Colors.white
                      : const Color(0xFF4338CA),
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  side: BorderSide(
                    color: const Color(0xFF4338CA).withOpacity(0.2),
                  ),
                ),
                onPressed: () => setState(() => this.currentPage = index),
                child: Text('${index + 1}'),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: currentPage < totalPages - 1
                ? () => setState(() => this.currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  String _formatCreatedAtShort(dynamic createdAt) {
    if (createdAt == null) return '';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      return DateFormat('dd/MM/yyyy').format(dt);
    }
    if (createdAt is String) {
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(createdAt)) {
        return createdAt;
      }
      try {
        final dt = DateTime.parse(createdAt);
        return DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {}
      final match = RegExp(r'([A-Za-z]+ \d{1,2}, \d{4})').firstMatch(createdAt);
      if (match != null) {
        final dateStr = match.group(1)!;
        try {
          final date = DateFormat('MMMM d, yyyy', 'en_US').parse(dateStr);
          return DateFormat('dd/MM/yyyy').format(date);
        } catch (_) {}
      }
      return createdAt;
    }
    return createdAt.toString();
  }

  Widget _cellCM(dynamic text,
      {bool bold = false, bool isWidget = false, double width = 140, TextAlign align = TextAlign.left}) {
    return SizedBox(
      width: width,
      child: isWidget
          ? text
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Text(
          text.toString(),
          textAlign: align,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}