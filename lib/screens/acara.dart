import 'package:flutter/material.dart';
import '../controllers/acara_controller.dart';
import '../models/acara_model.dart';

class AcaraScreen extends StatefulWidget {
  @override
  _AcaraScreenState createState() => _AcaraScreenState();
}

class _AcaraScreenState extends State<AcaraScreen> {
  final AcaraController _controller = AcaraController();
  final TextEditingController idAcaraController = TextEditingController();
  final TextEditingController idAdminController = TextEditingController();
  final TextEditingController namaAcaraController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController panitiaController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  List<Acara> _acaraList = [];

  @override
  void initState() {
    super.initState();
    _fetchAcara();
  }

  void _fetchAcara() async {
    try {
      List<Acara> acara = await _controller.fetchAcara();
      setState(() {
        _acaraList = acara;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil data acara.")),
      );
    }
  }

  void _tambahAcara() async {
    final int idAcara = int.tryParse(idAcaraController.text) ?? 0;
    final int idAdmin = int.tryParse(idAdminController.text) ?? 0;
    final String namaAcara = namaAcaraController.text;
    final String tanggal = tanggalController.text;
    final String panitia = panitiaController.text;
    final String catatan = catatanController.text;

    if (idAcara > 0 && idAdmin > 0 && namaAcara.isNotEmpty) {
      bool success = await _controller.addAcara(
        idAdmin,
        namaAcara,
        tanggal,
        panitia,
        catatan,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Acara berhasil ditambahkan!")),
        );
        Navigator.pop(context);
        _fetchAcara();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambahkan acara.")),
        );
      }
    }
  }

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Acara"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: idAcaraController,
                    decoration: InputDecoration(labelText: "ID Acara")),
                TextField(
                    controller: idAdminController,
                    decoration: InputDecoration(labelText: "ID Admin")),
                TextField(
                    controller: namaAcaraController,
                    decoration: InputDecoration(labelText: "Nama Acara")),
                TextField(
                    controller: tanggalController,
                    decoration: InputDecoration(labelText: "Tanggal")),
                TextField(
                    controller: panitiaController,
                    decoration: InputDecoration(labelText: "Panitia")),
                TextField(
                    controller: catatanController,
                    decoration: InputDecoration(labelText: "Catatan")),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: _tambahAcara,
              child: Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Acara")),
      body: _acaraList.isEmpty
          ? Center(child: Text("Tidak ada acara"))
          : ListView.builder(
              itemCount: _acaraList.length,
              itemBuilder: (context, index) {
                final acara = _acaraList[index];
                return ListTile(
                  title: Text(acara.namaAcara),
                  subtitle: Text(
                      "Tanggal: \${acara.tanggal} | Panitia: \${acara.panitia}"),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInputDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
