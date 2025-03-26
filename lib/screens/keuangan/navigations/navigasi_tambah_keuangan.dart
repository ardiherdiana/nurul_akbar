import 'package:flutter/material.dart';

class NavigasiTambahKeuangan extends StatefulWidget {
  @override
  _NavigasiTambahKeuanganState createState() => _NavigasiTambahKeuanganState();
}

class _NavigasiTambahKeuanganState extends State<NavigasiTambahKeuangan> {
  bool isPemasukan = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Keuangan")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isPemasukan = true;
                  });
                },
                child: Text("Pemasukan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPemasukan ? Colors.green : Colors.grey,
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isPemasukan = false;
                  });
                },
                child: Text("Pengeluaran"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isPemasukan ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset(0.0, 0.0),
                  ).animate(animation),
                  child: child,
                );
              },
              child: isPemasukan ? FormPemasukan() : FormPengeluaran(),
            ),
          ),
        ],
      ),
    );
  }
}

class FormPemasukan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Form Pemasukan", style: TextStyle(fontSize: 20)));
  }
}

class FormPengeluaran extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Form Pengeluaran", style: TextStyle(fontSize: 20)));
  }
}
