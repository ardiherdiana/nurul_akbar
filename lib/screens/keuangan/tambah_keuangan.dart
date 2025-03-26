import 'package:flutter/material.dart';
import 'pemasukan.dart';
import 'pengeluaran.dart';

class TambahKeuanganDialog extends StatefulWidget {
  @override
  _TambahKeuanganDialogState createState() => _TambahKeuanganDialogState();
}

class _TambahKeuanganDialogState extends State<TambahKeuanganDialog> {
  bool isPemasukan = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Tambah Data Keuangan"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            SizedBox(height: 10),
            isPemasukan ? PemasukanForm() : PengeluaranForm(),
          ],
        ),
      ),
      
    );
  }
}
