import 'package:flutter/material.dart';
import 'package:nurul_akbar/components/navigation.dart';
import 'keuangan/keuangan.dart';
import 'acara.dart';
import 'pengurus.dart';
import 'profil.dart';

class BerandaScreen extends StatefulWidget {
  @override
  _BerandaState createState() => _BerandaState();
}

class _BerandaState extends State<BerandaScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Masjid Jamie Nurul Akbar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildMainContent(),
          KeuanganScreen(),
          AcaraScreen(),
          PengurusScreen(),
          ProfilScreen()
        ],
      ),
      bottomNavigationBar: Navigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserProfile(),
          const SizedBox(height: 20),
          _buildSectionTitle("Ringkasan Keuangan Masjid", 1, Icons.edit),
          _buildFinancialSummary(),
          _buildSectionTitle("Ringkasan Acara Masjid", 2, Icons.edit),
          _buildEventSummary(),
          _buildSectionTitle("Ringkasan Kepengurusan Masjid", 3, Icons.edit),
          _buildManagementSummary(),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/images/ardi-pm.png'),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Assalamu'alaikum, Ardi!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Semoga harimu penuh berkah!", style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, int navIndex, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(icon, color: Colors.grey),
            onPressed: () {
              _onItemTapped(navIndex);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Saldo Saat Ini:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Rp 150.500.000",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pemasukan Bulan Ini:",
                        style: TextStyle(fontSize: 14)),
                    Text("Rp 3.000.000",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pengeluaran Bulan Ini:",
                        style: TextStyle(fontSize: 14)),
                    Text("Rp 2.000.000",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSummary() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.green),
        title: const Text("Kajian Rutin"),
        subtitle: const Text("Jumat, 12:30 WIB"),
      ),
    );
  }

  Widget _buildManagementSummary() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.people, color: Colors.green),
        title: const Text("Pengurus Masjid"),
        subtitle: const Text("Ketua: Ust. Ahmad | Bendahara: Pak Budi"),
      ),
    );
  }
}
