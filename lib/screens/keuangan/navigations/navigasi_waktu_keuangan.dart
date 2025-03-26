import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NavigasiWaktuKeuangan extends StatefulWidget {
  final Function(int, DateTimeRange?) onFilterChanged;
  final int selectedFilter;
  final DateTimeRange? selectedRange;

  const NavigasiWaktuKeuangan({
    Key? key,
    required this.onFilterChanged,
    required this.selectedFilter,
    required this.selectedRange,
  }) : super(key: key);

  @override
  _NavigasiWaktuKeuanganState createState() => _NavigasiWaktuKeuanganState();
}

class _NavigasiWaktuKeuanganState extends State<NavigasiWaktuKeuangan> {
  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: widget.selectedRange,
    );

    if (picked != null) {
      widget.onFilterChanged(0, picked); // 0 untuk "Pilih Rentang"
    }
  }

  Widget _buildFilterButton(String title, int index) {
    bool isSelected = widget.selectedFilter == index;
    return GestureDetector(
      onTap: () => widget.onFilterChanged(index, null),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String selectedRangeText = widget.selectedRange != null
        ? "${DateFormat('dd/MM/yyyy').format(widget.selectedRange!.start)} - ${DateFormat('dd/MM/yyyy').format(widget.selectedRange!.end)}"
        : "Pilih Rentang";

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: widget.selectedFilter == 0 ? Colors.green : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  selectedRangeText,
                  style: TextStyle(
                    color: widget.selectedFilter == 0 ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildFilterButton("Semua", 1),
            _buildFilterButton("Bulan Ini", 2),
            _buildFilterButton("Bulan Lalu", 3),
            _buildFilterButton("Minggu Ini", 4),
            _buildFilterButton("Hari Ini", 5),
          ],
        ),
      ),
    );
  }
}
