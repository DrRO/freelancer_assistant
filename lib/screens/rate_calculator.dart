import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

import 'package:flutter/material.dart';

class RateCalculatorScreen extends StatefulWidget {
  const RateCalculatorScreen({super.key});

  @override
  State<RateCalculatorScreen> createState() => _RateCalculatorScreenState();
}

class _RateCalculatorScreenState extends State<RateCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _generatedRate = '';
  bool _isLoading = false;

  // Form fields
  String _experienceLevel = 'intermediate';
  String _projectComplexity = 'medium';
  String _location = '';
  String _skills = '';

  Future<void> _calculateRate() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _generatedRate = ''; // Clear previous results
    });

    final prompt = """
    Suggest an appropriate freelance rate for:
    - Experience: $_experienceLevel
    - Skills: $_skills
    - Location: $_location
    - Project Complexity: $_projectComplexity

    Provide the rate in this exact format:
    [BEGIN_RATE]
    Hourly: \$X-\$Y
    Project: \$Z-\$W
    [END_RATE]

    Include 1-2 sentences justifying the range.
    """;

    try {
      final response = await GeminiService.generateContent(prompt);
      final rate = _extractRate(response);

      setState(() {
        _generatedRate = rate;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _extractRate(String response) {
    const startMarker = '[BEGIN_RATE]';
    const endMarker = '[END_RATE]';

    final startIndex = response.indexOf(startMarker);
    final endIndex = response.indexOf(endMarker);

    if (startIndex == -1 || endIndex == -1) return response;

    return response.substring(startIndex + startMarker.length, endIndex).trim();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField(
                value: _experienceLevel,
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                  DropdownMenuItem(
                    value: 'intermediate',
                    child: Text('Intermediate'),
                  ),
                  DropdownMenuItem(value: 'expert', child: Text('Expert')),
                ],
                onChanged: (value) => setState(() => _experienceLevel = value!),
                decoration: const InputDecoration(
                  labelText: 'Experience Level',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Your Skills (comma separated)',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Enter your skills' : null,
                onSaved: (value) => _skills = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Location (Country/City)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter location' : null,
                onSaved: (value) => _location = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _projectComplexity,
                items: const [
                  DropdownMenuItem(value: 'simple', child: Text('Simple')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'complex', child: Text('Complex')),
                ],
                onChanged:
                    (value) => setState(() => _projectComplexity = value!),
                decoration: const InputDecoration(
                  labelText: 'Project Complexity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _calculateRate,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Calculate Rate'),
              ),
              const SizedBox(height: 24),
              if (_generatedRate.isNotEmpty)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(
                      _generatedRate,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
