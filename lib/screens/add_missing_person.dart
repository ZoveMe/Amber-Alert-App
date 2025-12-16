import 'package:flutter/material.dart';
import '../models/mk_regions.dart';
import '../models/alert.dart';
import '../services/rabbitmq_service.dart';

class AddMissingPersonScreen extends StatefulWidget {
  const AddMissingPersonScreen({super.key});

  @override
  State<AddMissingPersonScreen> createState() =>
      _AddMissingPersonScreenState();
}

class _AddMissingPersonScreenState extends State<AddMissingPersonScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedRegion = MkRegions.all.first;
  String selectedPriority = 'HIGH';

  /// 🔁 Region → map center
  final Map<String, Offset> regionCenters = {
    'Скопски': Offset(41.9981, 21.4254),
    'Пелагониски': Offset(41.0300, 21.3400),
    'Полог': Offset(41.8000, 20.9000),
    'Југозападен': Offset(41.2000, 20.7000),
    'Југоисточен': Offset(41.4000, 22.6000),
    'Вардарски': Offset(41.6000, 21.9000),
    'Источен': Offset(41.9000, 22.4000),
    'Североисточен': Offset(42.1000, 21.9000),
  };

  /// 🧠 Converts UI region to routing-safe value
  String normalizeRegion(String region) {
    return region
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('ски', '')
        .replaceAll('ен', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Report Missing Person'),
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _textField(
                controller: nameController,
                label: 'Full name',
                required: true,
              ),
              const SizedBox(height: 12),

              _textField(
                controller: ageController,
                label: 'Age',
                keyboardType: TextInputType.number,
                required: true,
              ),
              const SizedBox(height: 12),

              _regionDropdown(),
              const SizedBox(height: 12),

              _priorityDropdown(),
              const SizedBox(height: 12),

              _textField(
                controller: descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitForm,
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: required ? (v) => v!.isEmpty ? 'Required field' : null : null,
      decoration: _fieldDecoration(label),
    );
  }

  Widget _regionDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.black87,
      value: selectedRegion,
      decoration: _fieldDecoration('Region'),
      items: MkRegions.all
          .map(
            (r) => DropdownMenuItem(
          value: r,
          child: Text(r, style: const TextStyle(color: Colors.white)),
        ),
      )
          .toList(),
      onChanged: (v) => setState(() => selectedRegion = v!),
    );
  }

  Widget _priorityDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.black87,
      value: selectedPriority,
      decoration: _fieldDecoration('Priority'),
      items: const ['HIGH', 'MEDIUM', 'LOW']
          .map(
            (p) => DropdownMenuItem(
          value: p,
          child: Text(p, style: const TextStyle(color: Colors.white)),
        ),
      )
          .toList(),
      onChanged: (v) => setState(() => selectedPriority = v!),
    );
  }

  InputDecoration _fieldDecoration(String label) {
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

  // ---------------- SUBMIT ----------------

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final center = regionCenters[selectedRegion]!;

    final alert = Alert(
      alertId: DateTime.now().millisecondsSinceEpoch.toString(),
      region: selectedRegion,
      city: nameController.text,
      lat: center.dx,
      lng: center.dy,
      description: descriptionController.text,
      priority: selectedPriority.toLowerCase(),
      createdAt: DateTime.now(),
    );

    final routingKey =
        'alert.${selectedPriority.toLowerCase()}.${MkRegions.toRouting(selectedRegion)}';




    try {
      await RabbitMQService.publishAlert(alert, routingKey);
      Navigator.pop(context, alert);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send alert: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
