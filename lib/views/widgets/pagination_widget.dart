import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 0
              ? () => onPageChanged(currentPage - 1)
              : null,
        ),
        Text('Trang ${currentPage + 1} / $totalPages'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages - 1
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}