import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddEditBookScreen extends StatefulWidget {
  const AddEditBookScreen({super.key});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  
  bool _isAvailable = true; 
  File? _selectedImage;
  bool _isLoading = false;

  // Cyber-Orchid Palette
  static const Color violet = Color(0xFFA855F7);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color obsidianBg = Color(0xFF0B0E14);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _finalizeArchive() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    String imageUrl = "";

    try {
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance.ref().child('covers/${const Uuid().v4()}.jpg');
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('books').add({
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'isbn': _isbnController.text.trim(),
        'quantity': int.parse(_qtyController.text),
        'status': _isAvailable ? 'Available' : 'Issued',
        'coverUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Volume Successfully Indexed"),
            backgroundColor: violet,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Critical Error: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Improvement: Hide keyboard on tap
        child: Stack(
          children: [
            // Background Visuals
            Positioned(top: -100, right: -50, child: _blurOrb(300, violet.withOpacity(0.12))),
            Positioned(bottom: -50, left: -50, child: _blurOrb(200, cyan.withOpacity(0.08))),
            
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("ARCHIVE PROTOCOL", style: TextStyle(color: cyan, letterSpacing: 4, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const Text("Catalog New Volume", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 35),
                          
                          _buildImageSelector(),
                          const SizedBox(height: 35),

                          _buildInput(_titleController, "Book Name", Icons.auto_stories_outlined),
                          const SizedBox(height: 20),
                          _buildInput(_authorController, "Author Name", Icons.history_edu_rounded),
                          const SizedBox(height: 20),
                          
                          Row(
                            children: [
                              Expanded(child: _buildInput(_isbnController, "ISBN-13", Icons.fingerprint_rounded, isNum: true)),
                              const SizedBox(width: 15),
                              Expanded(child: _buildInput(_qtyController, "Stock Qty", Icons.inventory_2_outlined, isNum: true)),
                            ],
                          ),
                          const SizedBox(height: 30),

                          _buildAvailabilityToggle(),

                          const SizedBox(height: 45),
                          _buildFinalizeButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Floating Close Button
            Positioned(
              top: 40, 
              left: 20, 
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 28), 
                onPressed: () => Navigator.pop(context)
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160, width: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: violet.withOpacity(0.4), width: 1.5),
          boxShadow: _selectedImage != null ? [BoxShadow(color: violet.withOpacity(0.2), blurRadius: 15)] : null,
          image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
        ),
        child: _selectedImage == null 
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: violet, size: 30),
                SizedBox(height: 8),
                Text("SCAN COVER", style: TextStyle(color: violet, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ) 
          : null,
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.015),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: _isAvailable ? cyan : Colors.white24, size: 20),
              const SizedBox(width: 15),
              Text(_isAvailable ? "Ready for Circulation" : "Mark as Issued", 
                style: TextStyle(color: _isAvailable ? Colors.white : Colors.white38, fontSize: 14)),
            ],
          ),
          Switch(
            value: _isAvailable,
            activeColor: cyan,
            activeTrackColor: violet.withOpacity(0.2),
            onChanged: (val) => setState(() => _isAvailable = val),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String l, IconData i, {bool isNum = false}) {
    return TextFormField(
      controller: c,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: l, labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        floatingLabelStyle: const TextStyle(color: cyan, fontWeight: FontWeight.bold),
        prefixIcon: Icon(i, color: violet, size: 20),
        filled: true, fillColor: Colors.white.withOpacity(0.01),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: violet, width: 1.5)),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Protocol Required';
        if (isNum && int.tryParse(v) == null) return 'Numeric Data Required';
        return null;
      },
    );
  }

  Widget _buildFinalizeButton() {
    return SizedBox(
      width: double.infinity, height: 60,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: violet.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: violet, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          onPressed: _isLoading ? null : _finalizeArchive,
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: obsidianBg, strokeWidth: 2)) 
            : const Text("FINALIZE ARCHIVAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ),
      ),
    );
  }

  Widget _blurOrb(double s, Color c) => Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: c));
}