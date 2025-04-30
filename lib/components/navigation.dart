import 'package:flutter/material.dart';

class Navigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Navigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Keuangan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Acara',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Pengurus',
        ),
      ],
    );
  }
}