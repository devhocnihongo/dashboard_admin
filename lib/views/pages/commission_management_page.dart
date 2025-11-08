import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/commission_model.dart';
import '../../viewmodels/commission_viewmodel.dart';

class CommissionManagementPage extends StatefulWidget {
  const CommissionManagementPage({super.key});

  @override
  State<CommissionManagementPage> createState() =>
      _CommissionManagementPageState();
}

class _CommissionManagementPageState extends State<CommissionManagementPage> {
  final CommissionViewModel _viewModel = CommissionViewModel();
  final currencyFormatter =
  NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tiền Hoa hồng'),
        foregroundColor: const Color(0xFF4338CA),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalRevenueWidget(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Danh sách hoa hồng chờ xác nhận (theo từng Store)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<Map<String, List<Commission>>>(
              stream: _viewModel.waitingCommissionsByStoreStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }
                final data = snapshot.data;
                if (data == null || data.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không có khoản hoa hồng nào đang chờ.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: data.entries.map((entry) {
                    final storeName = entry.key;
                    final commissions = entry.value;
                    final total = commissions.fold<int>(
                        0, (sum, c) => sum + c.commissionAmount);
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Text(
                              storeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Chip(
                              label: Text(
                                'Tổng: ${currencyFormatter.format(total)}',
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          ],
                        ),
                        initiallyExpanded: true,
                        children: commissions.map((commission) {
                          return ListTile(
                            title: Text(
                              'Số tiền: ${currencyFormatter.format(commission.commissionAmount)}',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hạn thanh toán: ${DateFormat('dd/MM/yyyy').format(commission.dueDate)}'),
                                if (commission.orderAmount > 0)
                                  Text('Giá trị đơn hàng: ${currencyFormatter.format(commission.orderAmount)}'),
                                if (commission.orderIds.isNotEmpty)
                                  Text('OrderIds: ${commission.orderIds.join(", ")}'),
                              ],
                            ),
                            trailing: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Xác nhận'),
                              onPressed: () => _showConfirmationDialog(commission),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRevenueWidget() {
    return StreamBuilder<int>(
      stream: _viewModel.totalRevenueStream,
      builder: (context, snapshot) {
        final totalRevenue = snapshot.data ?? 0;
        return Center(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'TỔNG DOANH THU ĐÃ THU ĐƯỢC',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currencyFormatter.format(totalRevenue),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(Commission commission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận Thanh toán'),
          content: Text(
              'Bạn có chắc chắn muốn xác nhận hoa hồng cho cửa hàng "${commission.storeName}" đã được thanh toán?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Xác nhận'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _viewModel.confirmPayment(commission.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xác nhận thanh toán thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Xác nhận thất bại: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}