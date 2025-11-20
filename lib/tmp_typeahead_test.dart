import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TmpTypeAheadExample extends StatelessWidget {
  const TmpTypeAheadExample({super.key});

  @override
  Widget build(BuildContext context) {
    return typeAheadExample();
  }

  Widget typeAheadExample() {
    return TypeAheadField<String>(
      suggestionsCallback: (pattern) async => <String>[],
      itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
      onSelected: (s) {},
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(labelText: 'Demo'),
        );
      },
    );
  }
}
