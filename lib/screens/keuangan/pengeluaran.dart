import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurul_akbar/controllers/pengeluaran_controller.dart';

class PengeluaranForm extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? editData;

  PengeluaranForm({
    this.isEditing = false,
    this.editData,
  });

  @override
  _PengeluaranFormState createState() => _PengeluaranFormState();
}

class _PengeluaranFormState extends State<PengeluaranForm> {
  final PengeluaranController _controller = PengeluaranController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController tujuanController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

  String? metodePembayaran;
  bool _isLoading = false;
  int? adminId;

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    
    if (widget.isEditing && widget.editData != null) {
      tujuanController.text = widget.editData!['tujuan'] ?? '';
      tanggalController.text = widget.editData!['tanggal'] ?? '';
      jumlahController.text = widget.editData!['jumlah'] ?? '';
      catatanController.text = widget.editData!['catatan'] ?? '';
      metodePembayaran = widget.editData!['metodePembayaran'] ?? '';
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        tanggalController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.red) : null,
      labelStyle: TextStyle(color: Colors.grey),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success;
      if (widget.isEditing) {
        success = await _controller.updatePengeluaran(
          widget.editData!['id'],
          adminId ?? 0,
          tanggalController.text,
          int.parse(jumlahController.text),
          tujuanController.text,
          metodePembayaran!,
          catatanController.text,
        );
      } else {
        success = await _controller.addPengeluaran(
          adminId ?? 0,
          tanggalController.text,
          int.parse(jumlahController.text),
          tujuanController.text,
          metodePembayaran!,
          catatanController.text,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? widget.isEditing 
              ? "Pengeluaran berhasil diperbarui"
              : "Pengeluaran berhasil ditambahkan"
            : "Gagal ${widget.isEditing ? 'memperbarui' : 'menambahkan'} pengeluaran"
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      if (success) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isEditing ? AppBar(
        title: Text('Edit Pengeluaran'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ) : null,
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 12),
              TextFormField(
                controller: tujuanController,
                cursorColor: Colors.red,
                decoration: _inputDecoration("Tujuan Pengeluaran", icon: Icons.shopping_cart),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Tujuan pengeluaran wajib diisi"
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: tanggalController,
                readOnly: true,
                decoration: _inputDecoration("Tanggal", icon: Icons.calendar_today),
                onTap: _selectDate,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Tanggal wajib diisi"
                    : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration:
                    _inputDecoration("Metode Pembayaran", icon: Icons.payment),
                value: metodePembayaran,
                items: ["Cash", "Transfer Bank"]
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => metodePembayaran = value),
                validator: (value) =>
                    value == null ? "Metode pembayaran wajib dipilih" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Jumlah (Rp)", icon: Icons.attach_money),
                validator: (value) => (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null)
                    ? "Jumlah harus angka"
                    : null,
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
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
