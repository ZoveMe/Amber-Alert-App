import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/mk_regions.dart';

class AddAlertScreen extends StatefulWidget {
  const AddAlertScreen({super.key});

  @override
  State<AddAlertScreen> createState() => _AddAlertScreenState();
}

class _AddAlertScreenState extends State<AddAlertScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _lat = TextEditingController();
  final TextEditingController _lng = TextEditingController();

  String? _selectedRegion;
  String? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Missing Person"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _inputField("Full Name", _name),
              _numberField("Age", _age),
              _inputField("Description", _description, maxLines: 3),

              const SizedBox(height: 16),
              _dropdown(
                "Select Region",
                MkRegions.all,
                    (val) => setState(() => _selectedRegion = val),
              ),

              const SizedBox(height: 16),
              _dropdown(
                "Priority Level",
                ["HIGH", "MEDIUM", "LOW"],
                    (val) => setState(() => _selectedPriority = val),
              ),

              const SizedBox(height: 16),
              _numberField("Latitude", _lat),
              _numberField("Longitude", _lng),

              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 55),
                ),
                onPressed: _submitForm,
                child: const Text(
                  "FILE MISSING PERSON REPORT",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) =>
        v == null || v.isEmpty ? "$label is required" : null,
        style: const TextStyle(color: Colors.white),
        decoration: _decoration(label),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: (v) =>
        v == null || v.isEmpty ? "$label is required" : null,
        style: const TextStyle(color: Colors.white),
        decoration: _decoration(label),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.grey[900],
      decoration: _decoration(label),
      items: items
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(e, style: const TextStyle(color: Colors.white)),
      ))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Select $label" : null,
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final json = {
      "alert_id": DateTime.now().millisecondsSinceEpoch.toString(),
      "name": _name.text.trim(),
      "age": int.parse(_age.text.trim()),
      "last_known_location": {
        "lat": double.parse(_lat.text.trim()),
        "lng": double.parse(_lng.text.trim()),
      },
      "region": _selectedRegion!,
      "priority": _selectedPriority!,
      "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "description": _description.text.trim(),
    };

    debugPrint("📤 SENDING ALERT JSON:\n$json");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Missing person report submitted"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, json);
  }
}
