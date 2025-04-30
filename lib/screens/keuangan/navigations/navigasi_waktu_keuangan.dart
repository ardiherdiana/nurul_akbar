import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
      widget.onFilterChanged(0, picked);
    }
  }

  DateTimeRange _getDateRange(int index) {
    DateTime now = DateTime.now();
    if (index == 2) {
      return DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      );
    } else if (index == 3) {
      return DateTimeRange(
        start: DateTime(now.year, now.month - 1, 1),
        end: DateTime(now.year, now.month, 0),
      );
    } else if (index == 4) {
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
      return DateTimeRange(start: startOfWeek, end: endOfWeek);
    }
    return DateTimeRange(start: now, end: now);
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = (screenWidth - 32) / 5;
    String selectedRangeText = widget.selectedRange != null
        ? "${DateFormat('EEEE, d MMMM y', 'id_ID').format(widget.selectedRange!.start)} - ${DateFormat('EEEE, d MMMM y', 'id_ID').format(widget.selectedRange!.end)}"
        : "Pilih Rentang";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.selectedFilter == 0 ? Colors.green : Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
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
          SizedBox(height: 12),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterButton("Semua", 1, buttonWidth),
                _buildFilterButton("Bulan Ini", 2, buttonWidth),
                _buildFilterButton("Bulan Lalu", 3, buttonWidth),
                _buildFilterButton("Minggu Ini", 4, buttonWidth),
                _buildFilterButton("Hari Ini", 5, buttonWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, int index, double width) {
    return SizedBox(
      width: width,
      height: 50,
      child: GestureDetector(
        onTap: () => widget.onFilterChanged(index, _getDateRange(index)),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.selectedFilter == index ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: widget.selectedFilter == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
