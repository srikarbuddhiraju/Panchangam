import 'package:flutter/material.dart';
import '../../core/city_lookup/city_lookup.dart';
import '../../core/city_lookup/models/city_data.dart';
import '../../core/utils/app_strings.dart';

/// Search dialog for selecting a city from the bundled database.
class CityPickerDialog extends StatefulWidget {
  const CityPickerDialog({super.key});

  /// Show the dialog and return the selected [CityData], or null if dismissed.
  static Future<CityData?> show(BuildContext context) {
    return showDialog<CityData>(
      context: context,
      builder: (_) => const CityPickerDialog(),
    );
  }

  @override
  State<CityPickerDialog> createState() => _CityPickerDialogState();
}

class _CityPickerDialogState extends State<CityPickerDialog> {
  final TextEditingController _controller = TextEditingController();
  List<CityData> _results = CityLookup.search('', limit: 30);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _results = CityLookup.search(query, limit: 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: S.city,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final city = _results[index];
                return ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(city.name),
                  subtitle: Text(city.state),
                  onTap: () => Navigator.of(context).pop(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
