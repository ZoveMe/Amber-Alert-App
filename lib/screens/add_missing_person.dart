import 'package:flutter/material.dart';
import '../models/mk_regions.dart';

class AddMissingPersonScreen extends StatefulWidget {
  const AddMissingPersonScreen({super.key});

  @override
  State<AddMissingPersonScreen> createState() => _AddMissingPersonScreenState();
}

class _AddMissingPersonScreenState extends State<AddMissingPersonScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedRegion = MkRegions.all.first;
  String selectedPriority = "HIGH";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Report Missing Person"),
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              // NAME
              TextFormField(
                controller: nameController,
                decoration: _field("Full name"),
                validator: (v) => v!.isEmpty ? "Required field" : null,
              ),

              const SizedBox(height: 12),

              // AGE
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: _field("Age"),
                validator: (v) => v!.isEmpty ? "Required field" : null,
              ),

              const SizedBox(height: 12),

              // REGION PICKER
              DropdownButtonFormField<String>(
                dropdownColor: Colors.black87,
                value: selectedRegion,
                decoration: _field("Region"),
                items: MkRegions.all.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedRegion = v!),
              ),

              const SizedBox(height: 12),

              // PRIORITY PICKER
              DropdownButtonFormField<String>(
                dropdownColor: Colors.black87,
                value: selectedPriority,
                decoration: _field("Priority"),
                items: ["HIGH", "MEDIUM", "LOW"].map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedPriority = v!),
              ),

              const SizedBox(height: 12),

              // LAT
              TextFormField(
                controller: latController,
                keyboardType: TextInputType.number,
                decoration: _field("Latitude"),
                validator: (v) => v!.isEmpty ? "Required field" : null,
              ),

              const SizedBox(height: 12),

              // LNG
              TextFormField(
                controller: lngController,
                keyboardType: TextInputType.number,
                decoration: _field("Longitude"),
                validator: (v) => v!.isEmpty ? "Required field" : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: _field("Description"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitForm,
                child: const Text("Submit Report"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _field(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "name": nameController.text,
      "age": int.tryParse(ageController.text) ?? 0,
      "region": selectedRegion,
      "priority": selectedPriority,
      "last_known_location": {
        "lat": double.tryParse(latController.text),
        "lng": double.tryParse(lngController.text),
      },
      "description": descriptionController.text,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    // TODO: SEND TO FIREBASE OR YOUR BACKEND
    debugPrint("🚨 NEW ALERT REPORT:");
    debugPrint(data.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Missing person report submitted"),
        backgroundColor: Colors.redAccent,
      ),
    );

    Navigator.pop(context);
  }
}
