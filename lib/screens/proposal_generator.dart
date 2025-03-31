import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

import 'package:flutter/material.dart';

class ProposalGeneratorScreen extends StatefulWidget {
  const ProposalGeneratorScreen({super.key});

  @override
  State<ProposalGeneratorScreen> createState() =>
      _ProposalGeneratorScreenState();
}

class _ProposalGeneratorScreenState extends State<ProposalGeneratorScreen> {
  final TextEditingController _projectDescController = TextEditingController();
  String _generatedProposal = '';
  bool _isLoading = false;
  bool _hasGenerated = false;

  Future<void> _generateProposal() async {
    if (_projectDescController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter project details')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasGenerated = false;
      _generatedProposal = ''; // Clear old response
    });

    try {
      final proposal = await GeminiService.generateContent(
        "Generate a freelance proposal for a Flutter mobile app project "
        "with 3 screens and Firebase backend. Include timeline and cost estimate.",
      );

      setState(() {
        _generatedProposal = proposal;
        _hasGenerated = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    setState(() {
      _projectDescController.clear();
      _generatedProposal = '';
      _hasGenerated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _projectDescController,
            decoration: InputDecoration(
              labelText: 'Describe the project',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed:
                    _projectDescController.text.isEmpty
                        ? null
                        : () {
                          _projectDescController.clear();
                          setState(() {});
                        },
              ),
            ),
            maxLines: 5,
            minLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateProposal,
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.generating_tokens_outlined),
                  label: Text(
                    _isLoading ? 'Generating...' : 'Generate Proposal',
                  ),
                ),
              ),
              if (_hasGenerated) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearFields,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _hasGenerated
                      ? SingleChildScrollView(
                        child: SelectableText(
                          _generatedProposal,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                      : Center(
                        child: Text(
                          'Your generated proposal will appear here',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _projectDescController.dispose();
    super.dispose();
  }
}
