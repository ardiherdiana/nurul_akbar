import 'package:flutter/material.dart';
import 'package:nurul_akbar/screens/pengurus/tambah_pengurus.dart';
import 'package:nurul_akbar/controllers/pengurus_controller.dart';
import 'package:nurul_akbar/models/pengurus_model.dart';
import 'dart:convert';  // Add this import

class PengurusScreen extends StatefulWidget {
  @override
  _PengurusScreenState createState() => _PengurusScreenState();
}

class _PengurusScreenState extends State<PengurusScreen> {
  final PengurusController _controller = PengurusController();
  bool _isLoading = false;
  List<Pengurus> _allPengurus = [];
  List<Pengurus> _filteredPengurus = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterPengurus);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _controller.fetchPengurus();
      setState(() {
        _allPengurus = data;
        _filteredPengurus = data;
        _isLoading = false;
      });

      // Log all image URLs after loading data
      for (var pengurus in data) {
        print(
            'Loaded pengurus: ${pengurus.namaPengurus}, Image URL: ${pengurus.fotoPengurus}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _filterPengurus() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPengurus = _allPengurus.where((pengurus) {
        return pengurus.namaPengurus.toLowerCase().contains(query) ||
            pengurus.jabatan.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Pengurus...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Daftar Pengurus',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _filteredPengurus.isEmpty
                        ? Center(child: Text('Tidak ada data pengurus'))
                        : ListView.builder(
                            itemCount: _filteredPengurus.length,
                            itemBuilder: (context, index) {
                              final data = _filteredPengurus[index];
                              return Dismissible(
                                key: Key(data.idPengurus.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Icon(Icons.delete, color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  final confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Konfirmasi'),
                                      content: Text('Yakin ingin menghapus pengurus ini?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Batal'),
                                          onPressed: () => Navigator.pop(context, false),
                                        ),
                                        TextButton(
                                          child: Text('Hapus', style: TextStyle(color: Colors.red)),
                                          onPressed: () => Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await _controller.deletePengurus(data.idPengurus);
                                      _loadData();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Pengurus berhasil dihapus')),
                                      );
                                      return true;
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Gagal menghapus pengurus: $e')),
                                      );
                                      return false;
                                    }
                                  }
                                  return false;
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    onTap: () => _editPengurus(data),
                                    leading: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.grey[200],
                                      child: data.fotoPengurus.isNotEmpty
                                          ? Builder(
                                              builder: (context) {
                                                try {
                                                  String cleanBase64 = data.fotoPengurus
                                                      .replaceAll(RegExp(r'\s+'), '')
                                                      .replaceAll(RegExp(r'data:image\/[^;]+;base64,'), '');
                                                  return ClipOval(
                                                    child: Image.memory(
                                                      base64Decode(cleanBase64),
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        print('Error loading image: $error');
                                                        return Icon(Icons.person, color: Colors.grey);
                                                      },
                                                    ),
                                                  );
                                                } catch (e) {
                                                  print('Error decoding base64: $e');
                                                  return Icon(Icons.person, color: Colors.grey);
                                                }
                                              },
                                            )
                                          : Icon(Icons.person, color: Colors.grey),
                                    ),
                                    title: Text(
                                      data.namaPengurus,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      data.jobdesk,
                                      style: TextStyle(color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue),
                                      ),
                                      child: Text(
                                        data.jabatan,
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPengurus,
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _addPengurus() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TambahPengurus()),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _editPengurus(Pengurus data) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahPengurus(
          isEditing: true,
          editData: {
            'id_pengurus': data.idPengurus,
            'id_admin': data.idAdmin,
            'foto_pengurus': data.fotoPengurus,
            'nama_pengurus': data.namaPengurus,
            'jabatan': data.jabatan,
            'jobdesk': data.jobdesk,
            'catatan': data.catatan,
          },
        ),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<bool> _confirmDelete(Pengurus data) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Yakin ingin menghapus pengurus ini?'),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _controller.deletePengurus(data.idPengurus);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengurus berhasil dihapus')),
        );
        return true;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus pengurus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}