import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurul_akbar/controllers/pemasukan_controller.dart';

class PemasukanForm extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? editData;

  PemasukanForm({
    this.isEditing = false,
    this.editData,
  });

  @override
  _PemasukanFormState createState() => _PemasukanFormState();
}

class _PemasukanFormState extends State<PemasukanForm> {
  final PemasukanController _controller = PemasukanController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController namaDonaturController = TextEditingController();  // Changed from namaController
  TextEditingController tanggalController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

  String? metodePembayaran;
  String? jenisPemasukan;
  bool _isLoading = false;

  int? adminId;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    
    if (widget.isEditing && widget.editData != null) {
      namaDonaturController.text = widget.editData!['namaDonatur'] ?? '';
      tanggalController.text = widget.editData!['tanggal'] ?? '';
      jumlahController.text = widget.editData!['jumlah'] ?? '';
      jenisPemasukan = widget.editData!['jenisPemasukan'] ?? '';
      metodePembayaran = widget.editData!['metodePembayaran'] ?? '';
      catatanController.text = widget.editData!['catatan'] ?? '';  // Will show in form when editing
    }
  }

  Future<void> _loadAdminInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminIdStr = prefs.getString('adminId');

    if (adminIdStr != null) {
      setState(() {
        adminId = int.tryParse(adminIdStr);
      });
    }
  }

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success;
      if (widget.isEditing) {
        success = await _controller.updatePemasukan(
          widget.editData!['id'],
          adminId ?? 0,
          namaDonaturController.text,  // Changed from namaController
          tanggalController.text,
          int.parse(jumlahController.text),
          jenisPemasukan!,
          metodePembayaran!,
          catatanController.text,
        );
      } else {
        success = await _controller.addPemasukan(
          adminId ?? 0,
          namaDonaturController.text,  // Changed from namaController
          tanggalController.text,
          int.parse(jumlahController.text),
          jenisPemasukan!,
          metodePembayaran!,
          catatanController.text,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? widget.isEditing 
              ? "Pemasukan berhasil diperbarui"
              : "Pemasukan berhasil ditambahkan"
            : "Gagal ${widget.isEditing ? 'memperbarui' : 'menambahkan'} pemasukan"
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
      labelStyle: TextStyle(color: Colors.green),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isEditing ? AppBar(
        title: Text('Edit Pemasukan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ) : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaDonaturController,  // Changed from namaController
                decoration: _inputDecoration("Nama Donatur", icon: Icons.person),  // Updated label
                validator: (value) => (value == null || value.isEmpty)
                    ? "Nama donatur wajib diisi"  // Updated validation message
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: tanggalController,
                readOnly: true,
                decoration:
                    _inputDecoration("Tanggal", icon: Icons.calendar_today),
                onTap: _selectDate,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Tanggal wajib diisi"
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                decoration:
                    _inputDecoration("Jumlah (Rp)", icon: Icons.attach_money),
                validator: (value) => (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null)
                    ? "Jumlah harus angka"
                    : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration:
                    _inputDecoration("Jenis Pemasukan", icon: Icons.category),
                value: jenisPemasukan,
                items: ["Zakat", "Sedekah", "Pendanaan"]
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => jenisPemasukan = value),
                validator: (value) =>
                    value == null ? "Jenis pemasukan wajib dipilih" : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration:
                    _inputDecoration("Metode Pembayaran", icon: Icons.payment),
                value: metodePembayaran,
                items: ["QRIS", "Transfer Bank", "Offline"]
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => metodePembayaran = value),
                validator: (value) =>
                    value == null ? "Metode pembayaran wajib dipilih" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: catatanController,
                maxLines: 4,
                minLines: 3,
                decoration: _inputDecoration("Catatan (Opsional)")
                    .copyWith(
                  alignLabelWithHint: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Batal", style: TextStyle(color: Colors.red)),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Simpan", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
