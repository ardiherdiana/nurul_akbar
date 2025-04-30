import 'package:flutter/material.dart';

class NavigasiKeuangan extends StatefulWidget {
  final Function(int) onTabChanged;
  final int selectedTab;

  const NavigasiKeuangan({
    Key? key,
    required this.onTabChanged,
    required this.selectedTab,
  }) : super(key: key);

  @override
  _NavigasiKeuanganState createState() => _NavigasiKeuanganState();
}

class _NavigasiKeuanganState extends State<NavigasiKeuangan> {
  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen width and divide it evenly for the buttons
    double buttonWidth = (MediaQuery.of(context).size.width - 32) / 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          // Animasi indikator tab yang dipilih
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: widget.selectedTab * buttonWidth,
            child: Container(
              width: buttonWidth,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // Tombol navigasi
          Row(
            children: [
              _buildTabButton("Semua", 0, buttonWidth),
              _buildTabButton("Pemasukan", 1, buttonWidth),
              _buildTabButton("Pengeluaran", 2, buttonWidth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, double width) {
    return GestureDetector(
      onTap: () => widget.onTabChanged(index),
      child: Container(
        width: width,
        height: 50,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: widget.selectedTab == index ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}