import 'package:flutter/material.dart';
import 'package:nurul_akbar/controllers/acara_controller.dart';
import 'package:nurul_akbar/screens/acara/tambah_acara.dart';
import 'package:intl/intl.dart';

class AcaraScreen extends StatefulWidget {
  const AcaraScreen({super.key});

  @override
  State<AcaraScreen> createState() => _AcaraScreenState();
}

class _AcaraScreenState extends State<AcaraScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AcaraController _controller = AcaraController();
  List<Map<String, dynamic>> acaraList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAcara();
  }

  Future<void> _loadAcara() async {
    setState(() => isLoading = true);
    try {
      final acara = await _controller.getAcara();
      setState(() => acaraList = acara);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading acara: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  Future<bool> _hapusAcara(Map<String, dynamic> acara) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Yakin ingin menghapus acara ini?'),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _controller.deleteAcara(acara['id_acara']);
        _loadAcara();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Acara berhasil dihapus')),
        );
        return true;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus acara: $e')),
        );
      }
    }
    return false;
  }

  // Helper method to check if date is within a week
  bool _isWithinOneWeek(DateTime date) {
    final now = DateTime.now();
    final oneWeekFromNow = now.add(Duration(days: 7));
    return date.isAfter(now) && date.isBefore(oneWeekFromNow.add(Duration(days: 1)));
  }

  Widget _buildAcaraCard(Map<String, dynamic> acara) {
    DateTime? tanggal;
    try {
      tanggal = DateTime.parse(acara['tanggal'] ?? '');
    } catch (e) {
      tanggal = null;
    }

    String formattedDate = tanggal != null
        ? DateFormat('dd/MM/yyyy').format(tanggal)
        : acara['tanggal'] ?? '';

    // Calculate status and styling
    String statusText = '';
    Color statusColor = Colors.blue;
    Color borderColor = Colors.blue;
    
    if (tanggal != null) {
      final now = DateTime.now();
      final difference = tanggal.difference(now);
      final days = difference.inDays;
      
      if (difference.isNegative) {
        statusText = 'Selesai';
        statusColor = Colors.grey;
        borderColor = Colors.grey;
      } else if (days == 0) {
        statusText = 'Hari ini';
        statusColor = Colors.green;
        borderColor = Colors.green;
      } else if (days == 1) {
        statusText = 'Besok';
        statusColor = Colors.orange;
        borderColor = Colors.orange;
      } else if (days <= 7) {
        statusText = '$days hari lagi';
        statusColor = Colors.orange;
        borderColor = Colors.orange;
      } else {
        statusText = 'Akan datang';
        statusColor = Colors.blue;
        borderColor = Colors.blue;
      }
    }

    return Dismissible(
      key: Key(acara['id_acara'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
      final confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Yakin ingin menghapus acara ini?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (confirm == true) {
        try {
          bool success = await _controller.deleteAcara(acara['id_acara']);
          if (success) {
            _loadAcara();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Acara berhasil dihapus')),
            );
            return true;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menghapus acara')),
            );
            return false;
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus acara: $e')),
          );
          return false;
        }
      }
      return false;
    },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: borderColor,
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
          subtitle: Text("$formattedDate - ${acara['panitia'] ?? ''}"),
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
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TambahAcara(
                  isEditing: true,
                  editData: acara,
                ),
              ),
            );
            if (result == true) _loadAcara();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter acara for each tab
    final List<Map<String, dynamic>> terdekatList = acaraList.where((acara) {
      final tanggal = DateTime.tryParse(acara['tanggal'] ?? '');
      return tanggal != null && _isWithinOneWeek(tanggal);
    }).toList();

    final List<Map<String, dynamic>> selesaiList = acaraList.where((acara) {
      final tanggal = DateTime.tryParse(acara['tanggal'] ?? '');
      return tanggal != null && tanggal.isBefore(DateTime.now());
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Terdekat'),
                Tab(text: 'Selesai'),
              ],
            ),
          ),
          // Add spacing between navigation tabs and content
          SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Semua Tab
                      acaraList.isEmpty
                          ? Center(
                              child: Text(
                                "Data tidak ada",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(bottom: 16),
                              itemCount: acaraList.length,
                              itemBuilder: (context, index) =>
                                  _buildAcaraCard(acaraList[index]),
                            ),
                      
                      // Terdekat Tab (acara dalam 1 minggu ke depan)
                      terdekatList.isEmpty
                          ? Center(
                              child: Text(
                                "Tidak ada acara dalam 1 minggu ke depan",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(bottom: 16),
                              itemCount: terdekatList.length,
                              itemBuilder: (context, index) => 
                                  _buildAcaraCard(terdekatList[index]),
                            ),
                      
                      // Selesai Tab (acara yang sudah lewat)
                      selesaiList.isEmpty
                          ? Center(
                              child: Text(
                                "Tidak ada acara yang sudah selesai",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(bottom: 16),
                              itemCount: selesaiList.length,
                              itemBuilder: (context, index) =>
                                  _buildAcaraCard(selesaiList[index]),
                            ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahAcara()),
          );
          if (result == true) _loadAcara();
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}