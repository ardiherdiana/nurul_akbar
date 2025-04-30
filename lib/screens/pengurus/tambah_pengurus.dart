import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurul_akbar/controllers/pengurus_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:convert';

class TambahPengurus extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? editData;

  TambahPengurus({
    this.isEditing = false,
    this.editData,
  });

  @override
  _TambahPengurusState createState() => _TambahPengurusState();
}

class _TambahPengurusState extends State<TambahPengurus> {
  Uint8List? _webImageBytes;
  XFile? _pickedFile;
  final PengurusController _controller = PengurusController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  TextEditingController namaPengurusController = TextEditingController();
  TextEditingController jabatanController = TextEditingController();
  TextEditingController jobdeskController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

  String? _selectedImage;
  bool _isLoading = false;
  int? adminId;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();

    if (widget.isEditing && widget.editData != null) {
      _selectedImage = widget.editData!['foto_pengurus'];
      namaPengurusController.text = widget.editData!['nama_pengurus'] ?? '';
      jabatanController.text = widget.editData!['jabatan'] ?? '';
      jobdeskController.text = widget.editData!['jobdesk'] ?? '';
      catatanController.text = widget.editData!['catatan'] ?? '';
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Reduce quality to ensure smaller file size
        maxWidth: 800,    // Limit image dimensions
      );
      
      if (image != null) {
        if (kIsWeb) {
          // Handle web platform
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _pickedFile = image;
            _selectedImage = null; // Clear any previous selected image
            _imageChanged = true;
          });
          print('Web image selected: ${image.name}, size: ${bytes.length} bytes');
        } else {
          // Handle mobile platform
          setState(() {
            _pickedFile = image;
            _selectedImage = null; // Clear any previous selected image
            _imageChanged = true;
          });
          print('Mobile image selected: ${image.path}');
          
          // Log file size for debugging
          final fileSize = await File(image.path).length();
          print('Image file size: ${fileSize} bytes');
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> _prepareImageData() async {
    try {
      if (_pickedFile != null && _imageChanged) {
        List<int> imageBytes;
        if (kIsWeb) {
          imageBytes = _webImageBytes!;
        } else {
          imageBytes = await File(_pickedFile!.path).readAsBytes();
        }
        
        // Make sure the image is not too large
        if (imageBytes.length > 1024 * 1024) {
          print('Image is large (${imageBytes.length} bytes), consider compressing');
        }
        
        String base64Image = base64Encode(imageBytes);
        print('Image prepared successfully: ${imageBytes.length} bytes, base64 length: ${base64Image.length}');
        return {
          'data': base64Image,
        };
      }
      return null;
    } catch (e) {
      print('Error preparing image data: $e');
      return null;
    }
  }

  Widget _buildImageWidget() {
    if (_pickedFile != null && _imageChanged) {
      if (kIsWeb && _webImageBytes != null) {
        return Image.memory(
          _webImageBytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading web image: $error');
            return _buildErrorWidget();
          },
        );
      } else if (!kIsWeb) {
        return Image.file(
          File(_pickedFile!.path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading local image: $error');
            return _buildErrorWidget();
          },
        );
      }
    } else if (_selectedImage != null && widget.isEditing) {
      try {
        // Handle if the image is already a base64 string
        if (_selectedImage!.contains(';base64,')) {
          final parts = _selectedImage!.split(';base64,');
          final imageData = parts[1];
          return Image.memory(
            base64Decode(imageData),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading base64 image: $error');
              return _buildErrorWidget();
            },
          );
        } else {
          // Try to decode directly
          return Image.memory(
            base64Decode(_selectedImage!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading base64 image: $error');
              return _buildErrorWidget();
            },
          );
        }
      } catch (e) {
        print('Error decoding base64 image: $e');
        return _buildErrorWidget();
      }
    }
    
    // Default placeholder
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 50,
          color: Colors.grey,
        ),
        SizedBox(height: 8),
        Text(
          'Pilih Foto',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Ensure we have an admin ID
      if (adminId == null) {
        throw Exception('Admin ID tidak ditemukan. Silakan login kembali.');
      }
      
      // Prepare image data if needed
      dynamic imageData = await _prepareImageData();
      print('Image data prepared for submission: ${imageData != null ? 'Yes' : 'No'}');

      bool success;
      if (widget.isEditing) {
        // Get current image for editing
        String currentImageUrl = '';
        if (!_imageChanged && _selectedImage != null) {
          currentImageUrl = _selectedImage!;
          print('Using existing image for update: ${currentImageUrl.substring(0, 30)}...');
        }
        
        success = await _controller.updatePengurus(
          widget.editData!['id_pengurus'],
          adminId!,
          imageData, // Pass the image data or null
          currentImageUrl, // Current image
          namaPengurusController.text,
          jabatanController.text,
          jobdeskController.text,
          catatanController.text,
        );
      } else {
        success = await _controller.addPengurus(
          adminId!,
          imageData, // Pass the image data or null
          namaPengurusController.text,
          jabatanController.text,
          jobdeskController.text,
          catatanController.text,
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
      print('Error saving data: $e');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Pengurus' : 'Tambah Pengurus'),
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
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: ClipOval(
                        child: _buildImageWidget(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 20,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: namaPengurusController,
                decoration:
                    _inputDecoration("Nama Pengurus", icon: Icons.person),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Nama pengurus wajib diisi"
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: jabatanController,
                decoration: _inputDecoration("Jabatan", icon: Icons.work),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Jabatan wajib diisi"
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: jobdeskController,
                decoration: _inputDecoration("Jobdesk", icon: Icons.assignment),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Jobdesk wajib diisi"
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: catatanController,
                maxLines: 4,
                minLines: 3,
                decoration: _inputDecoration("Catatan (Opsional)").copyWith(
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
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
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

  @override
  void dispose() {
    namaPengurusController.dispose();
    jabatanController.dispose();
    jobdeskController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 40, color: Colors.red),
        SizedBox(height: 8),
        Text(
          'Error loading image',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ],
    );
  }
}