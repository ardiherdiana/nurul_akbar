import 'package:flutter/material.dart';

class PengeluaranForm extends StatefulWidget {
  @override
  _PengeluaranFormState createState() => _PengeluaranFormState();
}

class _PengeluaranFormState extends State<PengeluaranForm> {
  TextEditingController idPengeluaranController = TextEditingController();
  TextEditingController idAdminController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController tujuanController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        tanggalController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: idPengeluaranController,
          decoration: InputDecoration(labelText: "ID Pengeluaran"),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: idAdminController,
          decoration: InputDecoration(labelText: "ID Admin"),
          keyboardType: TextInputType.number,
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
        TextField(
          controller: tujuanController,
          decoration: InputDecoration(labelText: "Tujuan"),
        ),
        TextField(
          controller: catatanController,
          decoration: InputDecoration(labelText: "Catatan"),
        ),
      ],
    );
  }
}
