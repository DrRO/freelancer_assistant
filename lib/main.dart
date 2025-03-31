import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freelancer_assistant/screens/email_assistant.dart';
import 'package:freelancer_assistant/screens/proposal_generator.dart';
import 'package:freelancer_assistant/screens/rate_calculator.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freelancer Assistant',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const FreelancerAssistantApp(),
    );
  }
}

class FreelancerAssistantApp extends StatefulWidget {
  const FreelancerAssistantApp({super.key});

  @override
  State<FreelancerAssistantApp> createState() => _FreelancerAssistantAppState();
}

class _FreelancerAssistantAppState extends State<FreelancerAssistantApp> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Freelancer Assistant'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Proposals'),
              Tab(text: 'Rate Calculator'),
              Tab(text: 'Email Assistant'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProposalGeneratorScreen(),
            RateCalculatorScreen(),
            EmailAssistantScreen(),
          ],
        ),
      ),
    );
  }
}
