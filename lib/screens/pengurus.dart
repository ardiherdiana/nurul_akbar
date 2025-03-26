import 'package:flutter/material.dart';

class PengurusScreen extends StatefulWidget {
  @override
  _PengurusScreenState createState() => _PengurusScreenState();
}

class _PengurusScreenState extends State<PengurusScreen> {
  void _showAddEditDialog({String? nama, String? jabatan, String? jobdesk, String? catatan}) {
    TextEditingController namaController = TextEditingController(text: nama ?? "");
    TextEditingController jabatanController = TextEditingController(text: jabatan ?? "");
    TextEditingController jobdeskController = TextEditingController(text: jobdesk ?? "");
    TextEditingController catatanController = TextEditingController(text: catatan ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(nama == null ? "Tambah Pengurus" : "Edit Pengurus"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: namaController, decoration: InputDecoration(labelText: "Nama")),
                TextField(controller: jabatanController, decoration: InputDecoration(labelText: "Jabatan")),
                TextField(controller: jobdeskController, decoration: InputDecoration(labelText: "Jobdesk")),
                TextField(controller: catatanController, decoration: InputDecoration(labelText: "Catatan")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kepengurusan Masjid")),
      body: Center(child: Text("Tidak ada data pengurus")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
