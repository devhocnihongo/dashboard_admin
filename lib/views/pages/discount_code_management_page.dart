import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/discount_code_viewmodel.dart';
import '../../models/discount_code_model.dart';

class DiscountCodeManagementPage extends StatefulWidget {
  const DiscountCodeManagementPage({Key? key}) : super(key: key);

  @override
  State<DiscountCodeManagementPage> createState() => _DiscountCodeManagementPageState();
}

class _DiscountCodeManagementPageState extends State<DiscountCodeManagementPage> {
  String? _selectedType;
  RangeValues? _selectedValueRange;
  int _page = 1;
  final int _pageSize = 4;

  final List<Map<String, dynamic>> _fixedRanges = [
    {"label": "0đ - 250,000đ", "min": 0, "max": 250000},
    {"label": "251,000đ - 750,000đ", "min": 251000, "max": 750000},
    {"label": "751,000đ - 2,250,000đ", "min": 751000, "max": 2250000},
    {"label": "2,251,000đ - 6,750,000đ", "min": 2251000, "max": 6750000},
    {"label": "6,751,000đ - 15,750,000đ", "min": 6751000, "max": 15750000},
  ];
  final List<Map<String, dynamic>> _percentRanges = [
    {"label": "0% - 10%", "min": 0, "max": 10},
    {"label": "11% - 25%", "min": 11, "max": 25},
    {"label": "26% - 45%", "min": 26, "max": 45},
    {"label": "46% - 70%", "min": 46, "max": 70},
    {"label": "71% - 100%", "min": 71, "max": 100},
  ];

  List<DiscountCodeModel> _filtered(List<DiscountCodeModel> list) {
    return list.where((code) {
      if (_selectedType != null && code.discountType != _selectedType) return false;
      if (_selectedValueRange != null) {
        if (code.value < _selectedValueRange!.start || code.value > _selectedValueRange!.end) return false;
      }
      return true;
    }).toList();
  }

  String getDiscountTypeText(String type) {
    switch (type) {
      case "fixed":
        return "Số tiền";
      case "percent":
        return "Phần trăm";
      default:
        return type;
    }
  }

  String getDiscountValueText(DiscountCodeModel code) {
    if (code.discountType == "percent") {
      return "${code.value}%";
    } else {
      return "${NumberFormat("#,###").format(code.value)}đ";
    }
  }

  void _goToPage(int page, int totalPage) {
    setState(() {
      if (page >= 1 && page <= totalPage) _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiscountCodeViewModel(),
      child: Consumer<DiscountCodeViewModel>(
        builder: (context, vm, child) {
          final filteredList = _filtered(vm.discountCodes);
          final totalPage = (filteredList.length / _pageSize).ceil().clamp(1, 999);
          final start = (_page - 1) * _pageSize;
          final end = (_page * _pageSize).clamp(0, filteredList.length);
          final pageList = filteredList.sublist(start, end);

          return Container(
            color: const Color(0xFFF8FAFF),
            padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Quản lý Mã Giảm Giá',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                    ),
                    const Spacer(),
                    _buildFilter(context),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFFF6F6FF),
                        foregroundColor: const Color(0xFF4338CA),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Thêm mã', style: TextStyle(fontWeight: FontWeight.w500)),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => DiscountCodeFormDialog(
                          onSave: (code) => vm.addDiscountCode(code),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: pageList.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, idx) {
                            final code = pageList[idx];
                            return ListTile(
                              leading: Icon(Icons.card_giftcard, color: Colors.green),
                              title: Text(
                                '${code.code} - Giá trị: ${getDiscountValueText(code)}',
                              ),
                              subtitle: Text(
                                  'Loại: ${getDiscountTypeText(code.discountType)}\n'
                                      'HSD: ${DateFormat("dd/MM/yyyy").format(code.expiredDate)} | Tối thiểu: ${NumberFormat("#,###").format(code.minOrder)}đ\n'
                                      '${code.storeId == null ? "Áp dụng toàn sàn" : "Áp dụng cho Store: ${code.storeId}"}'
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => DiscountCodeFormDialog(
                                        discountCode: code,
                                        onSave: (newCode) => vm.updateDiscountCode(newCode),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => vm.deleteDiscountCode(code.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (totalPage > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                tooltip: "Trang trước",
                                onPressed: _page > 1 ? () => _goToPage(_page - 1, totalPage) : null,
                              ),
                              Text(
                                'Trang $_page / $totalPage',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                tooltip: "Trang sau",
                                onPressed: _page < totalPage ? () => _goToPage(_page + 1, totalPage) : null,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilter(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedType,
              hint: const Text("Tất cả"),
              icon: const Icon(Icons.arrow_drop_down, size: 22),
              style: const TextStyle(fontSize: 15, color: Colors.black),
              items: const [
                DropdownMenuItem(value: null, child: Text("Tất cả")),
                DropdownMenuItem(value: "fixed", child: Text("Số tiền")),
                DropdownMenuItem(value: "percent", child: Text("Phần trăm")),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedType = val;
                  _selectedValueRange = null;
                  _page = 1;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RangeValues>(
              value: _selectedValueRange,
              hint: const Text("Khoảng giá trị"),
              icon: const Icon(Icons.arrow_drop_down, size: 22),
              style: const TextStyle(fontSize: 15, color: Colors.black),
              items: [
                if (_selectedType == null || _selectedType == "fixed")
                  ..._fixedRanges.map((r) => DropdownMenuItem<RangeValues>(
                    value: RangeValues(r["min"] * 1.0, r["max"] * 1.0),
                    child: Text(r["label"]),
                  )),
                if (_selectedType == null || _selectedType == "percent")
                  ..._percentRanges.map((r) => DropdownMenuItem<RangeValues>(
                    value: RangeValues(r["min"] * 1.0, r["max"] * 1.0),
                    child: Text(r["label"]),
                  )),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedValueRange = val;
                  _page = 1;
                });
              },
            ),
          ),
        ),
        if (_selectedType != null || _selectedValueRange != null)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: IconButton(
              tooltip: "Xóa lọc",
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                setState(() {
                  _selectedType = null;
                  _selectedValueRange = null;
                  _page = 1;
                });
              },
            ),
          ),
      ],
    );
  }
}

class DiscountCodeFormDialog extends StatefulWidget {
  final DiscountCodeModel? discountCode;
  final Function(DiscountCodeModel) onSave;

  const DiscountCodeFormDialog({Key? key, this.discountCode, required this.onSave}) : super(key: key);

  @override
  State<DiscountCodeFormDialog> createState() => _DiscountCodeFormDialogState();
}

class _DiscountCodeFormDialogState extends State<DiscountCodeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeCtrl, _valueCtrl, _minOrderCtrl, _limitCtrl, _storeCtrl;
  String _discountType = "fixed";
  DateTime _startDate = DateTime.now(), _expiredDate = DateTime.now().add(const Duration(days: 30));
  int _used = 0;

  @override
  void initState() {
    super.initState();
    final c = widget.discountCode;
    _codeCtrl = TextEditingController(text: c?.code ?? '');
    _valueCtrl = TextEditingController(text: c?.value.toString() ?? '');
    _minOrderCtrl = TextEditingController(text: c?.minOrder.toString() ?? '');
    _limitCtrl = TextEditingController(text: c?.limit.toString() ?? '1');
    _storeCtrl = TextEditingController(text: c?.storeId ?? '');
    _discountType = c?.discountType ?? "fixed";
    _startDate = c?.startDate ?? DateTime.now();
    _expiredDate = c?.expiredDate ?? DateTime.now().add(const Duration(days: 30));
    _used = c?.used ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF6F6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, minWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 30),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Chỉnh sửa mã giảm giá",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _codeCtrl,
                    decoration: InputDecoration(
                      labelText: "Mã giảm giá",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(fontSize: 17),
                    validator: (v) => v == null || v.trim().isEmpty ? "Bắt buộc nhập mã" : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          value: _discountType,
                          items: const [
                            DropdownMenuItem(value: "fixed", child: Text("Số tiền")),
                            DropdownMenuItem(value: "percent", child: Text("Phần trăm")),
                          ],
                          onChanged: (val) => setState(() => _discountType = val as String),
                          decoration: InputDecoration(
                            labelText: "Loại giảm giá",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _valueCtrl,
                          decoration: InputDecoration(
                            labelText: _discountType == "fixed" ? "Giá trị (VND)" : "Giá trị (%)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          style: const TextStyle(fontSize: 17),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || int.tryParse(v) == null ? "Nhập số" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _minOrderCtrl,
                    decoration: InputDecoration(
                      labelText: "Giá trị đơn tối thiểu (VND)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(fontSize: 17),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? "Nhập số" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _limitCtrl,
                    decoration: InputDecoration(
                      labelText: "Số lần sử dụng tối đa",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(fontSize: 17),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? "Nhập số" : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _dateField(
                          label: "Ngày bắt đầu",
                          date: _startDate,
                          onChanged: (d) => setState(() => _startDate = d),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _dateField(
                          label: "Ngày hết hạn",
                          date: _expiredDate,
                          onChanged: (d) => setState(() => _expiredDate = d),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _storeCtrl,
                    decoration: InputDecoration(
                      labelText: "Áp dụng cho cửa hàng (để trống = toàn sàn)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Hủy", style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: const Color(0xFF4338CA),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final code = DiscountCodeModel(
                              id: widget.discountCode?.id ?? '',
                              code: _codeCtrl.text.trim(),
                              creatorRole: "admin",
                              discountType: _discountType,
                              expiredDate: _expiredDate,
                              limit: int.parse(_limitCtrl.text.trim()),
                              minOrder: int.parse(_minOrderCtrl.text.trim()),
                              promotionId: null,
                              startDate: _startDate,
                              storeId: _storeCtrl.text.trim().isEmpty ? null : _storeCtrl.text.trim(),
                              used: _used,
                              value: int.parse(_valueCtrl.text.trim()),
                            );
                            widget.onSave(code);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Lưu", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(DateFormat("dd/MM/yyyy").format(date), style: const TextStyle(fontSize: 17)),
      ),
    );
  }
}