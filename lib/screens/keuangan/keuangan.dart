// Tetap bagian import-nya sama
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurul_akbar/controllers/pemasukan_controller.dart';
import 'package:nurul_akbar/controllers/pengeluaran_controller.dart';
import 'package:nurul_akbar/models/pemasukan_model.dart';
import 'package:nurul_akbar/models/pengeluaran_model.dart';
import 'navigations/navigasi_keuangan.dart';
import 'navigations/navigasi_waktu_keuangan.dart';
import 'pemasukan.dart';
import 'pengeluaran.dart';
import 'tambah_keuangan.dart';

class KeuanganScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;
  
  const KeuanganScreen({Key? key, this.onDataChanged}) : super(key: key);
  
  @override
  _KeuanganState createState() => _KeuanganState();
}

class _KeuanganState extends State<KeuanganScreen> {
  int _selectedTab = 0;
  int _selectedFilter = 1;
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  List<Map<String, dynamic>> _dataKeuangan = [];

  @override
  void initState() {
    super.initState();
    fetchDataKeuangan();
  }

  Future<void> fetchDataKeuangan() async {
    setState(() => _isLoading = true);
    try {
      PemasukanController pemasukanController = PemasukanController();
      PengeluaranController pengeluaranController = PengeluaranController();

      List<Pemasukan> dataPemasukan =
          await pemasukanController.fetchPemasukan();
      List<Map<String, dynamic>> pemasukanList = dataPemasukan
          .map((p) => {
                "id": p.idPemasukan,
                "type": "pemasukan",
                "nama": p.namaDonatur,
                "jenis_pemasukan": p.jenisPemasukan,
                "tanggal": DateTime.parse(p.tanggal),
                "metodePembayaran": p.metodePembayaran,
                "jumlah": p.jumlah,
                "catatan": p.catatan,  // Add this line to include catatan
              })
          .toList();

      List<Pengeluaran> dataPengeluaran =
          await pengeluaranController.fetchPengeluaran();
      List<Map<String, dynamic>> pengeluaranList = dataPengeluaran
          .map((p) => {
                "id": p.idPengeluaran,
                "type": "pengeluaran",
                "nama": p.tujuan,
                "tanggal": DateTime.parse(p.tanggal),
                "metodePembayaran": p.metodePembayaran, // Changed from "-" to actual field
                "jumlah": p.jumlah,
              })
          .toList();

      List<Map<String, dynamic>> mergedData = [
        ...pemasukanList,
        ...pengeluaranList
      ]..sort((a, b) => b["tanggal"].compareTo(a["tanggal"]));

      setState(() {
        _dataKeuangan = mergedData;
      });
    } catch (e) {
      print("Error Fetching Data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _hapusData(Map<String, dynamic> transaksi) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi"),
        content: Text("Yakin ingin menghapus data ini?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Hapus", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirm) {
      try {
        if (transaksi["type"] == "pemasukan") {
          await PemasukanController().deletePemasukan(transaksi["id"]);
        } else {
          await PengeluaranController().deletePengeluaran(transaksi["id"]);
        }
        
        setState(() {
          _dataKeuangan.removeWhere((item) => item["id"] == transaksi["id"]);
        });
        
        // Call the callback to update the saldo
        widget.onDataChanged?.call();
        
        return true;
      } catch (e) {
        print("Gagal hapus data: $e");
      }
    }
    return false; // Penghapusan batal atau gagal
  }

  List<Map<String, dynamic>> _getFilteredData() {
    List<Map<String, dynamic>> filteredList = _dataKeuangan;

    if (_selectedDateRange != null) {
      filteredList = filteredList.where((item) {
        DateTime tanggal = item["tanggal"];
        return tanggal.isAfter(
                _selectedDateRange!.start.subtract(Duration(days: 1))) &&
            tanggal.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
      }).toList();
    }

    if (_selectedTab == 1) {
      return filteredList.where((item) => item["type"] == "pemasukan").toList();
    } else if (_selectedTab == 2) {
      return filteredList
          .where((item) => item["type"] == "pengeluaran")
          .toList();
    }

    return filteredList;
  }

  void _updateFilter(int filterIndex, DateTimeRange? range) {
    setState(() {
      _selectedFilter = filterIndex;
      _selectedDateRange = (filterIndex == 1) ? null : range;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredData = _getFilteredData();

    double totalPemasukan = _dataKeuangan
        .where((item) => item["type"] == "pemasukan")
        .fold(0.0, (sum, item) => sum + item["jumlah"]);

    double totalPengeluaran = _dataKeuangan
        .where((item) => item["type"] == "pengeluaran")
        .fold(0.0, (sum, item) => sum + item["jumlah"]);

    double saldo = totalPemasukan - totalPengeluaran;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(
                      icon: Icons.account_balance_wallet,
                      label: "Saldo",
                      amount: saldo,
                      color: Colors.blue,
                    ),
                    _buildSummaryCard(
                      icon: Icons.arrow_downward,
                      label: "Pemasukan",
                      amount: totalPemasukan,
                      color: Colors.green,
                    ),
                    _buildSummaryCard(
                      icon: Icons.arrow_upward,
                      label: "Pengeluaran",
                      amount: totalPengeluaran,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          NavigasiKeuangan(
            selectedTab: _selectedTab,
            onTabChanged: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
          SizedBox(height: 10),
          NavigasiWaktuKeuangan(
            selectedFilter: _selectedFilter,
            selectedRange: _selectedDateRange,
            onFilterChanged: _updateFilter,
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredData.isEmpty
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
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final transaksi = filteredData[index];
                          bool isPemasukan = transaksi["type"] == "pemasukan";

                          return Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              await _hapusData(transaksi);
                              return false;
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  left: BorderSide(
                                    color: isPemasukan ? Colors.green : Colors.red,
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
                                  isPemasukan 
                                      ? "${transaksi["nama"]} - ${transaksi["jenis_pemasukan"]}"
                                      : transaksi["nama"],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "${DateFormat('dd/MM/yyyy').format(transaksi["tanggal"])} - ${transaksi["metodePembayaran"]}",
                                ),
                                trailing: Text(
                                  "${isPemasukan ? "+" : "-"} Rp${NumberFormat("#,##0", "id_ID").format(transaksi["jumlah"])}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isPemasukan ? Colors.green : Colors.red,
                                  ),
                                ),
                                onTap: () async {
                                  if (isPemasukan) {
                                    Map<String, dynamic> editData = {
                                      'id': transaksi["id"],
                                      'namaDonatur': transaksi["nama"],
                                      'tanggal': DateFormat('yyyy-MM-dd').format(transaksi["tanggal"]),
                                      'jumlah': transaksi["jumlah"].toString(),
                                      'jenisPemasukan': transaksi["jenis_pemasukan"],
                                      'metodePembayaran': transaksi["metodePembayaran"] ?? "QRIS", // Set default if null
                                      'catatan': transaksi["catatan"] ?? '',
                                    };
                                    
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PemasukanForm(
                                          isEditing: true,
                                          editData: editData,
                                        ),
                                      ),
                                    );
                                    
                                    if (result == true) {
                                      fetchDataKeuangan();
                                      if (widget.onDataChanged != null) {
                                        widget.onDataChanged!();
                                      }
                                    }
                                  } else {
                                    Map<String, dynamic> editData = {
                                      'id': transaksi["id"],
                                      'tujuan': transaksi["nama"],
                                      'tanggal': DateFormat('yyyy-MM-dd')
                                          .format(transaksi["tanggal"]),
                                      'jumlah': transaksi["jumlah"].toString(),
                                      'catatan': transaksi["catatan"] ?? '',
                                      'metodePembayaran': transaksi["metodePembayaran"],
                                    };
                                    
                                    bool? result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PengeluaranForm(
                                          isEditing: true,
                                          editData: editData,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      fetchDataKeuangan();
                                    }
                                  }
                                }
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await showDialog(
            context: context,
            builder: (context) => TambahKeuanganScreen(),
          );
          if (result == true) {
            fetchDataKeuangan();
          }
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 1.5),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text(
                "Rp${NumberFormat("#,##0", "id_ID").format(amount)}",
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
