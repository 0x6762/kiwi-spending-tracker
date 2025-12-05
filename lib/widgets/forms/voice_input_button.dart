import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../models/expense.dart';
import '../../repositories/expense_repository.dart';
import '../../repositories/category_repository.dart';

class VoiceInputButton extends StatefulWidget {
  final ExpenseRepository repository;
  final CategoryRepository categoryRepo;
  final Function()? onExpenseAdded;

  const VoiceInputButton({
    super.key,
    required this.repository,
    required this.categoryRepo,
    this.onExpenseAdded,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  bool _speechEnabled = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<bool> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      _showError(
          'Microphone permission is permanently denied. Please enable it in app settings.');
      return false;
    }

    _showError('Microphone permission is required for voice input.');
    return false;
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        print('Speech error: $errorNotification');
        setState(() {
          _isListening = false;
          _isProcessing = false;
        });
        _showError(
            'Error with speech recognition: ${errorNotification.errorMsg}');
      },
    );
    setState(() {});
  }

  void _listen() async {
    if (!await _requestPermission()) {
      return;
    }

    if (!_speechEnabled) {
      _showError('Speech recognition not available');
      return;
    }

    setState(() {
      _isProcessing = false;
      _lastWords = '';
    });

    if (!_isListening) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
            print('Recognized words: $_lastWords');
          });

          // Only process when we have the final result
          if (result.finalResult && !_isProcessing) {
            _processVoiceInput();
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  void _processVoiceInput() async {
    if (_lastWords.isEmpty || _isProcessing) return;
    _isProcessing = true;

    // Convert input to lowercase for easier matching
    final input = _lastWords.toLowerCase();

    // Try to extract amount using regex, looking for numbers after "spent" or at the start
    final amountRegex = RegExp(
        r'(?:spent |spend |)\$?(\d+(?:[.,]\d{1,2})?)\s+(?:on\s+|for\s+|)?(.+)');
    final match = amountRegex.firstMatch(input);

    if (match == null) {
      _showError(
          'Could not understand the format. Please say something like "Spent 25 on beer"');
      _isProcessing = false;
      return;
    }

    double? amount = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (amount == null) {
      _showError('Invalid amount format');
      _isProcessing = false;
      return;
    }

    // Get the description from the second capture group
    String description = match.group(2)?.trim() ?? 'Voice expense';

    // Create and save the new expense
    final expense = Expense(
      id: const Uuid().v4(),
      title: description,
      amount: amount,
      date: DateTime.now(),
      categoryId: 'other', // Default category ID
      createdAt: DateTime.now(),
      accountId: 'checking', // Default account
    );

    await widget.repository.addExpense(expense);
    if (widget.onExpenseAdded != null) {
      widget.onExpenseAdded!();
    }

    // Close dialog
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Voice Input',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            _isListening
                ? _lastWords.isEmpty
                    ? 'Listening...'
                    : _lastWords
                : 'Tap the microphone and say something like:\n"Spent 25 on groceries"',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Material(
            color: _isListening
                ? theme.colorScheme.error
                : theme.colorScheme.surfaceContainerLowest,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _listen,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  size: 32,
                  color: _isListening
                      ? theme.colorScheme.onError
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
