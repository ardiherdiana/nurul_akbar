import 'package:flutter/material.dart';
import 'package:nurul_akbar/controllers/pemasukan_controller.dart';
import 'package:nurul_akbar/models/pemasukan_model.dart';

class PemasukanForm extends StatefulWidget {
  @override
  _PemasukanFormState createState() => _PemasukanFormState();
}

class _PemasukanFormState extends State<PemasukanForm> {
  final PemasukanController _controller = PemasukanController();

  TextEditingController idAdminController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  String? metodePembayaran;
  String? jenisPemasukan;

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        tanggalController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitData() async {
    if (namaController.text.isEmpty ||
        tanggalController.text.isEmpty ||
        jumlahController.text.isEmpty ||
        metodePembayaran == null ||
        jenisPemasukan == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Semua kolom harus diisi")));
      return;
    }
    try {
      bool success = await _controller.addPemasukan(
        int.parse(idAdminController.text),
        namaController.text,
        tanggalController.text,
        int.parse(jumlahController.text),
        jenisPemasukan!,
        metodePembayaran!,
        catatanController.text,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Pemasukan berhasil ditambahkan")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menambahkan pemasukan")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: idAdminController,
          decoration: InputDecoration(labelText: "ID Admin"),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: namaController,
          decoration: InputDecoration(labelText: "Nama"),
        ),
        TextField(
          controller: tanggalController,
          decoration: InputDecoration(labelText: "Tanggal"),
          readOnly: true,
          onTap: _selectDate,
        ),
        TextField(
          controller: jumlahController,
          decoration: InputDecoration(labelText: "Jumlah (Rp)"),
          keyboardType: TextInputType.number,
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: "Jenis Pemasukan"),
          value: jenisPemasukan,
          items: ["Zakat", "Sedekah", "Donasi"]
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              jenisPemasukan = value;
            });
          },
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: "Metode Pembayaran"),
          value: metodePembayaran,
          items: ["QRIS", "Transfer Bank", "Offline"]
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              metodePembayaran = value;
            });
          },
        ),
        TextField(
          controller: catatanController,
          decoration: InputDecoration(labelText: "Catatan"),
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Batal", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: _submitData,
          child: Text("Simpan"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }
}
