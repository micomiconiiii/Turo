import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'providers/mentor_registration_provider.dart';

class Credential {
  String title;
  String year;
  String? certificateFileName;
  Uint8List? certificateBytes;

  Credential(
      {required this.title,
      required this.year,
      this.certificateFileName,
      this.certificateBytes});
}

class MentorStep4Credentials extends StatefulWidget {
  const MentorStep4Credentials({super.key});

  @override
  State<MentorStep4Credentials> createState() => _MentorStep4CredentialsState();
}

class _MentorStep4CredentialsState extends State<MentorStep4Credentials> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<MentorRegistrationProvider>();
    if (provider.hourlyRate != null) {
      _rateController.text = provider.hourlyRate!.toString();
    }
    _expertiseController.clear();
  }

  @override
  void dispose() {
    _rateController.dispose();
    _expertiseController.dispose();
    super.dispose();
  }

  void _addExpertiseTag(String tag) {
    if (tag.trim().isEmpty) return;
    final provider = context.read<MentorRegistrationProvider>();

    if (!provider.expertise.contains(tag.trim())) {
      provider.updateExpertise(
        hourlyRate:
            double.tryParse(_rateController.text) ?? provider.hourlyRate ?? 0,
        expertise: [...provider.expertise, tag.trim()],
      );
    }
    _expertiseController.clear();
  }

  void _removeExpertiseTag(String tag) {
    final provider = context.read<MentorRegistrationProvider>();
    provider.updateExpertise(
      hourlyRate:
          double.tryParse(_rateController.text) ?? provider.hourlyRate ?? 0,
      expertise: provider.expertise.where((t) => t != tag).toList(),
    );
  }

  void _onRateChanged(String value) {
    final provider = context.read<MentorRegistrationProvider>();
    final rate = double.tryParse(value) ?? 0;
    provider.updateExpertise(hourlyRate: rate, expertise: provider.expertise);
  }

  void _onNext() {
    final provider = context.read<MentorRegistrationProvider>();

    // Manual Validation before moving on
    if (provider.hourlyRate == null || provider.hourlyRate! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hourly rate must be greater than 0.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (provider.expertise.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one expertise/skill.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to Step 5 (Review)
    provider.nextPage();
  }

  void _removeCredential(int index) {
    final provider = context.read<MentorRegistrationProvider>();
    provider.removeCredential(index);
  }

  Future<void> _showAddCredentialDialog() async {
    final provider = context.read<MentorRegistrationProvider>();
    final titleController = TextEditingController();
    final yearController = TextEditingController();
    FilePickerResult? filePickerResult;

    final result = await showDialog<Credential?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Credential'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: yearController,
                      decoration: const InputDecoration(labelText: 'Year Achieved'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'jpg', 'png'],
                            );
                            setState(() {
                              filePickerResult = result;
                            });
                          },
                          child: const Text('Upload Certificate'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            filePickerResult?.files.single.name ?? 'No file selected',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && yearController.text.isNotEmpty) {
                  final newCredential = Credential(
                    title: titleController.text,
                    year: yearController.text,
                    certificateFileName: filePickerResult?.files.single.name,
                    certificateBytes: filePickerResult?.files.single.bytes,
                  );
                  Navigator.of(context).pop(newCredential);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Title and Year are required.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      provider.addCredential(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MentorRegistrationProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hourly Rate (PHP):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C6A64),
                  ),
                ),
                TextFormField(
                  controller: _rateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'e.g. 500'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your hourly rate.';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid number greater than 0.';
                    }
                    return null;
                  },
                  onChanged: _onRateChanged,
                ),
                const SizedBox(height: 24),

                const Text(
                  'Expertise / Skills:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C6A64),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  children: provider.expertise
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => _removeExpertiseTag(tag),
                        ),
                      )
                      .toList(),
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expertiseController,
                        decoration: const InputDecoration(
                          hintText: 'Add expertise/skill',
                        ),
                        onFieldSubmitted: _addExpertiseTag,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF2C6A64)),
                      onPressed: () =>
                          _addExpertiseTag(_expertiseController.text),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // CREDENTIALS SECTION
                const Text(
                  'Credentials:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C6A64),
                  ),
                ),
                const SizedBox(height: 8),
                if (provider.credentials.isEmpty)
                  const Text('No credentials added yet.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.credentials.length,
                    itemBuilder: (context, index) {
                      final cred = provider.credentials[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(cred.title),
                          subtitle: Text(
                              'Year: ${cred.year}\nFile: ${cred.certificateFileName ?? 'None'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeCredential(index),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.add, color: Color(0xFF2C6A64)),
                  label: const Text('Add Credential', style: TextStyle(color: Color(0xFF2C6A64))),
                  onPressed: _showAddCredentialDialog,
                ),
                const SizedBox(height: 32),

                // NEXT BUTTON (Moves to Step 5)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF2C6A64),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _onNext,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
