import 'package:flutter/material.dart';

import '../services/gemini_service.dart';

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

  Future<void> _generateProposal() async {
    setState(() => _isLoading = true);
    final prompt = """
    Generate a professional freelance proposal for a project with these details:
    Project Description: ${_projectDescController.text}
    
    Make it concise, highlight expertise, and include a call to action.
    """;

    final response = await GeminiService.generateContent(prompt);
    setState(() {
      _generatedProposal = response;
      _isLoading = false;
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
            decoration: const InputDecoration(
              labelText: 'Describe the project',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _generateProposal,
            child:
                _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Generate Proposal'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(child: Text(_generatedProposal)),
          ),
        ],
      ),
    );
  }
}
