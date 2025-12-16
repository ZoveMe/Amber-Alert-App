import 'package:flutter/material.dart';
import '../models/mk_regions.dart';
import '../models/alert.dart';

class AddMissingPersonScreen extends StatefulWidget {
  final Function(Alert)? onAlertSubmitted; // Koristam callbeck zaso pri swipe kako strana mora da se zacuva alertot,a pri klik na feature card vidov deka koristis Navtigator.push async za zacuvuvanje na alertot

  const AddMissingPersonScreen({super.key, this.onAlertSubmitted});

  @override
  State<AddMissingPersonScreen> createState() => _AddMissingPersonScreenState();
}

class _AddMissingPersonScreenState extends State<AddMissingPersonScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  String selectedRegion = MkRegions.all.first;
  String selectedPriority = "HIGH";
  final Map<String, Offset> regionCenters = {
    "Скопски": const Offset(41.9981, 21.4254),
    "Пелагониски": const Offset(41.0300, 21.3400),
    "Полог": const Offset(41.8000, 20.9000),
    "Југозападен": const Offset(41.2000, 20.7000),
    "Југоисточен": const Offset(41.4000, 22.6000),
    "Вардарски": const Offset(41.6000, 21.9000),
    "Источен": const Offset(41.9000, 22.4000),
    "Североисточен": const Offset(42.1000, 21.9000),
  };

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
                style: const TextStyle(color: Colors.white),
                decoration: _field("Full name"),
                validator: (v) => v!.isEmpty ? "Required field" : null,
              ),

              const SizedBox(height: 12),

              // AGE
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
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



              const SizedBox(height: 12),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
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

    final center = regionCenters[selectedRegion]!;

    final alert = Alert(
      alertId: DateTime.now().millisecondsSinceEpoch.toString(),
      region: selectedRegion,
      city: nameController.text, // label shown on map
      lat: center.dx,
      lng: center.dy,
      description: descriptionController.text,
      priority: selectedPriority.toLowerCase(), // high | medium | low
      createdAt: DateTime.now(),
    );
    if (widget.onAlertSubmitted != null) {
      widget.onAlertSubmitted!(alert);
    }

    Navigator.pop(context, alert);
  }



}
