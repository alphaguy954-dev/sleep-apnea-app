import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/session_result.dart';
import 'results_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File?   _selectedFile;
  bool    _isLoading = false;
  String? _errorMessage;
  String  _statusText = '';

  Future<void> _pickFile() async {
    setState(() { _errorMessage = null; });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _errorMessage = null;
      });
    }
  }

  Future<void> _analyzeFile() async {
    if (_selectedFile == null) {
      setState(() { _errorMessage = 'Please select a CSV file first.'; });
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; _statusText = 'Uploading data...'; });

    try {
      setState(() { _statusText = 'Running ML model...'; });
      final result = await ApiService.predict(_selectedFile!);

      setState(() { _statusText = 'Analysis complete!'; });
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ResultsScreen(result: result)),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading   = false;
        _statusText  = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Sleep Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            // Required columns info
            _SectionCard(
              title: 'Required CSV Columns',
              child: Column(
                children: [
                  _ColRow('HR',        'Heart Rate (bpm)'),
                  _ColRow('SpO2',      'Blood Oxygen Saturation (%)'),
                  _ColRow('RMSSD',     'HRV metric (ms)'),
                  _ColRow('SDNN',      'HRV metric (ms)'),
                  _ColRow('SpO2drop',  'Minute-to-minute SpO2 change (%)'),
                  const SizedBox(height: 8),
                  Text('One row per minute of overnight recording.',
                      style: TextStyle(fontSize: 12,
                          color: AppTheme.textSecond,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // File picker
            GestureDetector(
              onTap: _isLoading ? null : _pickFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: _selectedFile != null
                      ? AppTheme.primary.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedFile != null
                        ? AppTheme.primary
                        : const Color(0xFFBDBDBD),
                    width: _selectedFile != null ? 2 : 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      size: 52,
                      color: _selectedFile != null
                          ? AppTheme.primary
                          : const Color(0xFFBDBDBD),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFile != null
                          ? _selectedFile!.path.split('/').last
                          : 'Tap to select CSV file',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _selectedFile != null
                            ? AppTheme.primary
                            : AppTheme.textSecond,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedFile != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecond),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _pickFile,
                        child: const Text('Change file'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Error
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Analyze button
            if (_isLoading)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 14),
                  Text(_statusText,
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.w500)),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _selectedFile != null ? _analyzeFile : null,
                icon: const Icon(Icons.biotech_rounded),
                label: const Text('Analyze Sleep Data'),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppTheme.primary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ColRow extends StatelessWidget {
  final String col, desc;
  const _ColRow(this.col, this.desc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(col,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    fontFamily: 'monospace')),
          ),
          const SizedBox(width: 10),
          Text(desc, style: const TextStyle(fontSize: 13, color: AppTheme.textSecond)),
        ],
      ),
    );
  }
}
