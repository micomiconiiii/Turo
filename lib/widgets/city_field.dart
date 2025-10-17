import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_typeahead/flutter_typeahead.dart' as typeahead;

class CityField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;

  const CityField({
    Key? key,
    this.controller,
    this.label,
    this.hintText,
  }) : super(key: key);

  @override
  State<CityField> createState() => _CityFieldState();
}

class _CityFieldState extends State<CityField> {
  List<String> _cities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  /// Load the JSON list of Philippine cities from assets
  Future<void> _loadCities() async {
    try {
      final String response =
      await rootBundle.loadString('assets/cities.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _cities = data.cast<String>();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading cities: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return typeahead.TypeAheadField<String>(
      // Show the suggestions box on focus even when the query is empty
      showOnFocus: true,
      suggestionsCallback: (pattern) {
        // When the user hasn't typed anything yet, show the full list so the
        // dropdown appears on focus/tap. Otherwise filter by the typed pattern.
        if (pattern.isEmpty) return _cities.toList();
        return _cities
            .where((city) => city.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSelected: (suggestion) {
        // Update the externally-provided controller if present.
        widget.controller?.text = suggestion;
      },
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No matching city found.',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      // builder builds the actual text field; use TextFormField so it participates in Forms
      builder: (context, textEditingController, focusNode) {
        final controller = widget.controller ?? textEditingController;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.label ?? 'City',
            labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
            hintText: widget.hintText ?? 'Start typing your city...',
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.25)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.25)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.25), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'City is required';
            }
            if (!_cities.contains(value)) {
              return 'Please select a valid city';
            }
            return null;
          },
        );
      },
    );
  }
}
