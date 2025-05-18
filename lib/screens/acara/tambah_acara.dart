import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurul_akbar/controllers/acara_controller.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TambahAcara extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? editData;

  TambahAcara({
    this.isEditing = false,
    this.editData,
  });

  @override
  _AcaraFormState createState() => _AcaraFormState();
}

class _AcaraFormState extends State<TambahAcara> {
  final AcaraController _controller = AcaraController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int? adminId;
  String? username;

  TextEditingController namaAcaraController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController waktuController = TextEditingController();
  TextEditingController tempatController = TextEditingController();
  TextEditingController panitiaController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _base64Image;
  
  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    
    if (widget.isEditing && widget.editData != null) {
      namaAcaraController.text = widget.editData!['nama_acara'] ?? '';
      tanggalController.text = widget.editData!['tanggal'] ?? '';
      waktuController.text = widget.editData!['waktu'] ?? '';
      tempatController.text = widget.editData!['tempat'] ?? '';
      panitiaController.text = widget.editData!['panitia'] ?? '';
      catatanController.text = widget.editData!['catatan'] ?? '';
      
      // Memastikan foto sebelumnya dimuat saat mode edit
      if (widget.editData!['foto_acara'] != null && widget.editData!['foto_acara'].toString().isNotEmpty) {
        setState(() {
          _base64Image = widget.editData!['foto_acara'];
          print("Foto acara dimuat: ${_base64Image!.substring(0, 20)}..."); // Debug print
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      
      // Convert to base64
      final bytes = await _imageFile!.readAsBytes();
      _base64Image = base64Encode(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Acara' : 'Tambah Acara'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Widget foto dalam bentuk lingkaran dengan tombol edit
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _imageFile != null
                            ? kIsWeb
                                ? Image.network(
                                    _imageFile!.path,
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                  )
                                : Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                  )
                            : _base64Image != null
                                ? Image.memory(
                                    base64Decode(_base64Image!),
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate,
                                          size: 50, color: Colors.green),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tambah Foto',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    // Tombol pensil untuk mengupload foto baru
                    Positioned(
                      right: 0,
                      bottom: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: _pickImage,
                          iconSize: 20,
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ),
                    ),
                    // Label Edit Foto Acara khusus untuk mode edit
                    if (widget.isEditing)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -30,
                        child: Text(
                          'Edit Foto Acara',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: namaAcaraController,
                decoration: _inputDecoration("Nama Acara", icon: Icons.event),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Nama acara wajib diisi"
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
              TextFormField(
                controller: waktuController,
                readOnly: true,
                decoration: _inputDecoration("Waktu", icon: Icons.access_time),
                onTap: _selectTime,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Waktu wajib diisi"
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: tempatController,
                decoration: _inputDecoration("Tempat", icon: Icons.location_on),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Tempat wajib diisi"
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: panitiaController,
                decoration: _inputDecoration("Panitia", icon: Icons.people),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Panitia wajib diisi"
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
                      backgroundColor: Colors.green,
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

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success;
      if (widget.isEditing) {
        success = await _controller.updateAcara(
          widget.editData!['id_acara'],
          adminId ?? 0,
          namaAcaraController.text,
          tanggalController.text,
          waktuController.text,
          tempatController.text,
          panitiaController.text,
          catatanController.text,
          _base64Image,
        );
      } else {
        success = await _controller.addAcara(
          adminId ?? 0,
          namaAcaraController.text,
          tanggalController.text,
          waktuController.text,
          tempatController.text,
          panitiaController.text,
          catatanController.text,
          _base64Image,
        );
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error saving data: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
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
  void dispose() {
    namaAcaraController.dispose();
    tanggalController.dispose();
    waktuController.dispose();
    tempatController.dispose();
    panitiaController.dispose();
    catatanController.dispose();
    super.dispose();
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
  
  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        waktuController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }
}