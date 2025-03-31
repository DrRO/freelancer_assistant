import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freelancer_assistant/screens/email_assistant.dart';
import 'package:freelancer_assistant/screens/proposal_generator.dart';
import 'package:freelancer_assistant/screens/rate_calculator.dart';
import 'package:freelancer_assistant/services/gemini_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with error boundary
  runApp(
    ErrorBoundary(
      child: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return ErrorFallback(error: snapshot.error.toString());
            }
            return const MyApp();
          }
          return const LoadingScreen();
        },
      ),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    await dotenv.load(fileName: '.env');
    await GeminiService.initialize();

    // Test Gemini API
    final testOutput = await GeminiService.generateContent(
      'Write a short story about AI.',
    );
    debugPrint('✅ Test Output: $testOutput');
  } catch (e) {
    debugPrint('❌ Initialization failed: $e');
    throw Exception('Configuration error: ${e.toString()}');
  }
}

class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ErrorFallback extends StatelessWidget {
  final String error;

  const ErrorFallback({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Initialization Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => main(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Initializing App...'),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Freelancer Assistant',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Freelancer Assistant'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.description), text: 'Proposal Generator'),
              Tab(icon: Icon(Icons.calculate), text: 'Rate Calculator'),
              Tab(icon: Icon(Icons.email), text: 'Email Assistant'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              ProposalGeneratorScreen(),
              RateCalculatorScreen(),
              EmailAssistantScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
