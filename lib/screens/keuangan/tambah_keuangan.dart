import 'package:flutter/material.dart';
import 'pemasukan.dart';
import 'pengeluaran.dart';

class TambahKeuanganScreen extends StatefulWidget {
  @override
  _TambahKeuanganScreenState createState() => _TambahKeuanganScreenState();
}

class _TambahKeuanganScreenState extends State<TambahKeuanganScreen> {
  bool isPemasukan = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Data Keuangan", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isPemasukan = true;
                      });
                    },
                    child: Text("Pemasukan", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPemasukan ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isPemasukan = false;
                      });
                    },
                    child: Text("Pengeluaran", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isPemasukan ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: isPemasukan ? PemasukanForm() : PengeluaranForm(),
            ),
          ],
        ),
      ),
    );
  }
}
