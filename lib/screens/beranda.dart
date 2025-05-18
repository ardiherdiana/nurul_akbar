import 'package:flutter/material.dart';
import 'package:nurul_akbar/components/navigation.dart';
import 'keuangan/keuangan.dart';
import 'acara/acara.dart';
import 'pengurus/pengurus.dart';
import 'package:nurul_akbar/controllers/acara_controller.dart';
import 'package:intl/intl.dart';
import 'package:nurul_akbar/controllers/pemasukan_controller.dart';
import 'package:nurul_akbar/controllers/pengeluaran_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurul_akbar/screens/login.dart';

class BerandaScreen extends StatefulWidget {
  @override
  _BerandaState createState() => _BerandaState();
}

class _BerandaState extends State<BerandaScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final PemasukanController _pemasukanController = PemasukanController();
  final PengeluaranController _pengeluaranController = PengeluaranController();
  
  List<dynamic> _pemasukan = [];
  double _saldo = 0;
  double _pemasukanBulanIni = 0;
  double _pengeluaranBulanIni = 0;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    try {
      final pemasukan = await _pemasukanController.fetchPemasukan();
      final pengeluaran = await _pengeluaranController.fetchPengeluaran();

      // Calculate financial data
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);

      double totalPemasukan = 0;
      double totalPemasukanBulanIni = 0;
      for (var p in pemasukan) {
        double jumlah = p.jumlah.toDouble(); // Convert int to double
        totalPemasukan += jumlah;
        
        final tanggal = DateTime.parse(p.tanggal);
        if (tanggal.year == currentMonth.year && tanggal.month == currentMonth.month) {
          totalPemasukanBulanIni += jumlah;
        }
      }

      double totalPengeluaran = 0;
      double totalPengeluaranBulanIni = 0;
      for (var p in pengeluaran) {
        double jumlah = p.jumlah.toDouble();
        totalPengeluaran += jumlah;
        
        final tanggal = DateTime.parse(p.tanggal);
        if (tanggal.year == currentMonth.year && tanggal.month == currentMonth.month) {
          totalPengeluaranBulanIni += jumlah;
        }
      }

      setState(() {
        _saldo = totalPemasukan - totalPengeluaran;
        _pemasukanBulanIni = totalPemasukanBulanIni;
        _pengeluaranBulanIni = totalPengeluaranBulanIni;
      });
    } catch (e) {
      print('Error loading financial data: $e');
    }
  }

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
          style: TextStyle(color: Colors.white),textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Refresh financial data when switching pages
          _loadFinancialData();
        },
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildMainContent(),
          KeuanganScreen(onDataChanged: () {
            // Callback to refresh financial data when changes occur in KeuanganScreen
            _loadFinancialData();
          }),
          AcaraScreen(),
          PengurusScreen(),
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
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
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
        ),
        IconButton(
          icon: Icon(Icons.logout, color: Colors.red),
          onPressed: () async {
            final confirm = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Konfirmasi Logout'),
                content: Text('Apakah Anda yakin ingin keluar?'),
                actions: [
                  TextButton(
                    child: Text('Batal', style: TextStyle(color: Colors.grey)),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: Text('Logout', style: TextStyle(color: Colors.green)),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false,
              );
            }
          },
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
    final formatCurrency = NumberFormat("#,##0", "id_ID");
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Saldo",
            style: TextStyle(
              fontSize: 16,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Rp ${formatCurrency.format(_saldo)}",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Pemasukan",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Rp ${formatCurrency.format(_pemasukanBulanIni)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Pengeluaran",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Rp ${formatCurrency.format(_pengeluaranBulanIni)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventSummary() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AcaraController().getAcara(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 64,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 64,
            child: Center(
              child: Text(
                'Error loading events: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 64,
            child: Center(
              child: Text(
                'Tidak ada acara yang akan datang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }

        // Sort and filter upcoming events
        final now = DateTime.now();
        final upcomingEvents = snapshot.data!
            .where((acara) {
              final tanggal = DateTime.tryParse(acara['tanggal'] ?? '');
              return tanggal != null && tanggal.isAfter(now);
            })
            .toList()
          ..sort((a, b) {
              final dateA = DateTime.parse(a['tanggal']);
              final dateB = DateTime.parse(b['tanggal']);
              return dateA.compareTo(dateB);
            });

        // Take only the first 3 events
        final eventsToShow = upcomingEvents.take(3).toList();

        return Column(
          children: [
            ...eventsToShow.map((acara) {
              DateTime? tanggal = DateTime.tryParse(acara['tanggal'] ?? '');
              String statusText = '';
              Color statusColor = Colors.blue;
              
              if (tanggal != null) {
                final difference = tanggal.difference(now);
                final days = difference.inDays;
                
                if (days == 0) {
                  statusText = 'Hari ini';
                  statusColor = Colors.green;
                } else if (days == 1) {
                  statusText = 'Besok';
                  statusColor = Colors.orange;
                } else if (days <= 7) {
                  statusText = '$days hari lagi';
                  statusColor = Colors.orange;
                } else {
                  statusText = 'Akan datang';
                  statusColor = Colors.blue;
                }
              }

              return Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      color: statusColor,
                      width: 4,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    acara['nama_acara'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${DateFormat('dd/MM/yyyy').format(tanggal!)} - ${acara['panitia'] ?? ''}"
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () => _onItemTapped(2), // Navigate to Acara tab
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lihat semua acara',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.green, size: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

 
}