import 'package:flutter/material.dart';

import '../models/alert.dart';
import '../models/mk_regions.dart';
import '../services/rabbitmq_service.dart';

class AddMissingPersonScreen extends StatefulWidget {
  final Function(Alert)? onAlertSubmitted;

  const AddMissingPersonScreen({
    super.key,
    this.onAlertSubmitted,
  });

  @override
  State<AddMissingPersonScreen> createState() =>
      _AddMissingPersonScreenState();
}

class _AddMissingPersonScreenState extends State<AddMissingPersonScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedRegion = MkRegions.all.first;
  String _selectedPriority = 'HIGH';

  /// Approximate region centers (lat, lng)
  final Map<String, Offset> _regionCenters = {
    'Скопски': const Offset(41.9981, 21.4254),
    'Пелагониски': const Offset(41.0300, 21.3400),
    'Полог': const Offset(41.8000, 20.9000),
    'Југозападен': const Offset(41.2000, 20.7000),
    'Југоисточен': const Offset(41.4000, 22.6000),
    'Вардарски': const Offset(41.6000, 21.9000),
    'Источен': const Offset(41.9000, 22.4000),
    'Североисточен': const Offset(42.1000, 21.9000),
  };

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
                controller: _nameController,
                label: 'Full name',
                required: true,
              ),
              const SizedBox(height: 12),

              _textField(
                controller: _ageController,
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
                controller: _descriptionController,
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

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

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
      style: const TextStyle(color: Colors.white),
      validator: required
          ? (v) => v == null || v.isEmpty ? 'Required field' : null
          : null,
      decoration: _inputDecoration(label),
    );
  }

  Widget _regionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRegion,
      dropdownColor: Colors.black87,
      decoration: _inputDecoration('Region'),
      items: MkRegions.all
          .map(
            (region) => DropdownMenuItem(
          value: region,
          child: Text(
            region,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      )
          .toList(),
      onChanged: (v) => setState(() => _selectedRegion = v!),
    );
  }

  Widget _priorityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      dropdownColor: Colors.black87,
      decoration: _inputDecoration('Priority'),
      items: const ['HIGH', 'MEDIUM', 'LOW']
          .map(
            (p) => DropdownMenuItem(
          value: p,
          child: Text(
            p,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      )
          .toList(),
      onChanged: (v) => setState(() => _selectedPriority = v!),
    );
  }

  InputDecoration _inputDecoration(String label) {
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

  // ---------------------------------------------------------------------------
  // Submit logic → RabbitMQ → Firebase → Notification
  // ---------------------------------------------------------------------------

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final center = _regionCenters[_selectedRegion]!;

    final alert = Alert(
      alertId: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      region: _selectedRegion,
      lat: center.dx,
      lng: center.dy,
      description: _descriptionController.text,
      priority: _selectedPriority.toLowerCase(),
      createdAt: DateTime.now(),
    );

    widget.onAlertSubmitted?.call(alert);

    final routingKey =
        'alert.${alert.priority}.${MkRegions.toRouting(_selectedRegion)}';

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
