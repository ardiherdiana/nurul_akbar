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
    double buttonWidth = MediaQuery.of(context).size.width / 3 - 16;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
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
              left: widget.selectedTab == 0
                  ? 0
                  : widget.selectedTab == 1
                      ? buttonWidth + 8
                      : (buttonWidth * 2) + 16,
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
                _buildTabButton("Semua", 0),
                _buildTabButton("Pemasukan", 1),
                _buildTabButton("Pengeluaran", 2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTabChanged(index),
        child: Container(
          alignment: Alignment.center,
          height: 50,
          child: Text(
            title,
            style: TextStyle(
              color: widget.selectedTab == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
