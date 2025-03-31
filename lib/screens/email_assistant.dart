import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/gemini_service.dart';

class EmailAssistantScreen extends StatefulWidget {
  const EmailAssistantScreen({super.key});

  @override
  State<EmailAssistantScreen> createState() => _EmailAssistantScreenState();
}

class _EmailAssistantScreenState extends State<EmailAssistantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _keyPointsController = TextEditingController();
  String _generatedEmail = '';
  bool _isLoading = false;
  String _tone = 'professional';
  String _purpose = 'proposal';

  Future<void> _generateEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prompt = """
    Write a $_tone email to a client about $_purpose with these key points:
    ${_keyPointsController.text}

    Subject: ${_subjectController.text}

    Structure it with:
    1. Appropriate greeting
    2. Clear purpose statement
    3. Bullet points for key information
    4. Professional closing

    Make it 1-2 paragraphs maximum.
    """;

    final response = await GeminiService.generateContent(prompt);

    setState(() {
      _generatedEmail = response;
      _isLoading = false;
    });
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
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Email Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter subject' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _tone,
                items: const [
                  DropdownMenuItem(
                    value: 'professional',
                    child: Text('Professional'),
                  ),
                  DropdownMenuItem(value: 'friendly', child: Text('Friendly')),
                  DropdownMenuItem(value: 'formal', child: Text('Formal')),
                ],
                onChanged: (value) => setState(() => _tone = value!),
                decoration: const InputDecoration(
                  labelText: 'Tone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _purpose,
                items: const [
                  DropdownMenuItem(
                    value: 'proposal',
                    child: Text('Project Proposal'),
                  ),
                  DropdownMenuItem(
                    value: 'follow-up',
                    child: Text('Follow Up'),
                  ),
                  DropdownMenuItem(
                    value: 'negotiation',
                    child: Text('Negotiation'),
                  ),
                  DropdownMenuItem(
                    value: 'issue',
                    child: Text('Problem Resolution'),
                  ),
                ],
                onChanged: (value) => setState(() => _purpose = value!),
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keyPointsController,
                decoration: const InputDecoration(
                  labelText: 'Key Points to Include',
                  border: OutlineInputBorder(),
                  hintText: 'Separate points with commas',
                ),
                maxLines: 3,
                validator:
                    (value) => value!.isEmpty ? 'Enter key points' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _generateEmail,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Generate Email'),
              ),
              const SizedBox(height: 24),
              if (_generatedEmail.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generated Email:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SelectableText(
                          _generatedEmail,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _generatedEmail),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email copied to clipboard'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
