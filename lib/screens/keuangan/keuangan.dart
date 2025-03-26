import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurul_akbar/controllers/pemasukan_controller.dart';
import 'package:nurul_akbar/models/pemasukan_model.dart';
import 'navigations/navigasi_keuangan.dart';
import 'navigations/navigasi_waktu_keuangan.dart';
import 'tambah_keuangan.dart';

class KeuanganScreen extends StatefulWidget {
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
    fetchDataKeuangan(); // Ambil data saat pertama kali masuk halaman
  }

  // Fungsi untuk mengambil data dari API
  void fetchDataKeuangan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      PemasukanController controller = PemasukanController();
      List<Pemasukan> data = await controller.fetchPemasukan();

      setState(() {
        _dataKeuangan = data.map((p) => {
          "jenisPemasukan": p.jenisPemasukan,
          "tanggal": DateTime.parse(p.tanggal),
          "metodePembayaran": p.metodePembayaran,
          "jumlah": p.jumlah,
        }).toList();
      });
    } catch (e) {
      print("Error Fetching Data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateFilter(int filterIndex, DateTimeRange? range) {
    setState(() {
      _selectedFilter = filterIndex;
      _selectedDateRange = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NavigasiKeuangan(
            selectedTab: _selectedTab,
            onTabChanged: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
          NavigasiWaktuKeuangan(
            selectedFilter: _selectedFilter,
            selectedRange: _selectedDateRange,
            onFilterChanged: _updateFilter,
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _dataKeuangan.isEmpty
                    ? Center(
                        child: Text(
                          "Data tidak ada",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _dataKeuangan.length,
                        itemBuilder: (context, index) {
                          final pemasukan = _dataKeuangan[index];
                          return ListTile(
                            title: Text(
                              pemasukan["jenisPemasukan"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${DateFormat('dd/MM/yyyy').format(pemasukan["tanggal"])} - ${pemasukan["metodePembayaran"]}",
                            ),
                            trailing: Text(
                              "Rp${pemasukan["jumlah"]}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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
          bool result = await showDialog(
            context: context,
            builder: (context) => TambahKeuanganDialog(),
          );
          if (result == true) {
            fetchDataKeuangan(); // Refresh data setelah menambahkan transaksi
          }
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green,
      ),
    );
  }
}
