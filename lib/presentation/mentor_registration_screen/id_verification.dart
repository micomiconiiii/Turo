import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class IDVerificationScreen extends StatefulWidget {
  @override
  _IDVerificationScreenState createState() => _IDVerificationScreenState();
}

class _IDVerificationScreenState extends State<IDVerificationScreen> {
  File? _pickedFile;
  UploadTask? _uploadTask;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_pickedFile == null) {
      return;
    }

    final fileName = 'id_verification/${DateTime.now().millisecondsSinceEpoch}';
    final destination = 'users/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      setState(() {
        _uploadTask = ref.putFile(_pickedFile!);
      });

      final snapshot = await _uploadTask!.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      // TODO: Save the download URL to the user's profile in your database
      print('Download URL: $url');

      setState(() {
        _uploadTask = null;
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ID Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_pickedFile != null)
              Image.file(
                _pickedFile!,
                height: 200,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Pick a file'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Upload file'),
            ),
            if (_uploadTask != null)
              StreamBuilder<TaskSnapshot>(
                stream: _uploadTask!.snapshotEvents,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final progress = snapshot.data!.bytesTransferred / snapshot.data!.totalBytes;
                    return Column(
                      children: [
                        SizedBox(height: 20),
                        LinearProgressIndicator(value: progress),
                        SizedBox(height: 10),
                        Text('${(progress * 100).toStringAsFixed(2)}%'),
                      ],
                    );
                  }
                  return Container();
                },
              ),
          ],
        ),
      ),
    );
  }
}
