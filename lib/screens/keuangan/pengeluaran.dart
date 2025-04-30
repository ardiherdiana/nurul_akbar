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

  bool _isLoading = false;
  int? adminId;
  String _selectedMetodePembayaran = 'Cash'; // Add this line
  final List<String> _metodePembayaran = ['Cash', 'Transfer Bank']; // Add this line

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    
    if (widget.isEditing && widget.editData != null) {
      tujuanController.text = widget.editData!['tujuan'] ?? '';
      tanggalController.text = widget.editData!['tanggal'] ?? '';
      jumlahController.text = widget.editData!['jumlah'] ?? '';
      catatanController.text = widget.editData!['catatan'] ?? '';
      _selectedMetodePembayaran = widget.editData!['metodePembayaran'] ?? 'Cash'; // Add this line
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
        success = await _controller.updatePengeluaran(
          widget.editData!['id'],
          adminId ?? 0,
          tanggalController.text,
          int.parse(jumlahController.text),
          tujuanController.text,
          catatanController.text,
          _selectedMetodePembayaran, // Add this parameter
        );
      } else {
        success = await _controller.addPengeluaran(
          adminId ?? 0,
          tanggalController.text,
          int.parse(jumlahController.text),
          tujuanController.text,
          catatanController.text,
          _selectedMetodePembayaran,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? widget.isEditing 
              ? "Pengeluaran berhasil diperbarui"
              : "Pengeluaran berhasil ditambahkan"
            : "Gagal ${widget.isEditing ? 'memperbarui' : 'menambahkan'} pengeluaran"
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
      prefixIcon: icon != null ? Icon(icon, color: Colors.red) : null,
      labelStyle: TextStyle(color: Colors.red),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isEditing ? AppBar(
        title: Text('Edit Pengeluaran'),
        backgroundColor: Colors.red,
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
                controller: tujuanController,
                decoration: _inputDecoration("Tujuan Pengeluaran", icon: Icons.shopping_cart),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Tujuan pengeluaran wajib diisi"
                    : null,
              ),
              SizedBox(height: 12),
              // Add payment method dropdown after tanggal field
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
                value: _selectedMetodePembayaran,
                decoration: _inputDecoration("Metode Pembayaran", icon: Icons.payment),
                items: _metodePembayaran.map((String method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMetodePembayaran = newValue;
                    });
                  }
                },
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
