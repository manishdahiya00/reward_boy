import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reward_boy/utils.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _quizData = [];
  int _currentQuestionIndex = 0;
  String? _selectedOption;
  bool _isCorrect = false;
  int _score = 0;
  Timer? _timer;
  int _timeLeft = 60;
  late AnimationController _animationController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _fetchQuizData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuizData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final securityToken = prefs.getString('token');

    if (userId == null || securityToken == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not logged in';
      });
      return;
    }

    try {
      Map<String, String> allInfo = await Utils.collectAllInfo();
      final dio = Dio();
      final response = await dio.post(
        '${allInfo["baseUrl"]}questions',
        data: {
          "userId": userId,
          "securityToken": securityToken,
          "versionName": allInfo['versionName'] ?? "",
          "versionCode": allInfo['versionCode'] ?? "",
        },
      );

      if (response.statusCode == 201 && response.data['status'] == 200) {
        final questions = response.data['questions'] as List<dynamic>;
        setState(() {
          _quizData = questions.map((question) {
            return {
              'question': question['question'] ?? 'No Question',
              'options': List<String>.from(question['options'] ?? []),
              'correctAnswer': question['correctAnswer'] ?? '',
            };
          }).toList();
          _isLoading = false;
          _startTimer();
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              response.data['message'] ?? 'Failed to load questions';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: Something Went Wrong';
      });
    }
  }

  void _startTimer() {
    _timeLeft = 60;
    _timer?.cancel();
    _animationController.reset();
    _animationController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _moveToNextQuestion();
        }
      });
    });
  }

  void _moveToNextQuestion() {
    _timer?.cancel();
    if (_currentQuestionIndex < _quizData.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _isCorrect = false;
        _startTimer();
      });
    } else {
      _showResultDialog();
    }
  }

  void _checkAnswer(String selectedOption) {
    if (_selectedOption != null) return;

    final correctAnswer =
        _quizData[_currentQuestionIndex]['correctAnswer'] as String;
    setState(() {
      _selectedOption = selectedOption;
      _isCorrect = selectedOption == correctAnswer;
      if (_isCorrect) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _moveToNextQuestion();
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color.fromARGB(255, 36, 33, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
              color: Color.fromARGB(255, 230, 169, 14), width: 3),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.yellow.shade700,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Quiz Completed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Your Score: $_score/${_quizData.length}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 230, 169, 14),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                child: const Text('Done !'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text(
            'Quiz',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text(
            'Quiz',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final question = _quizData[_currentQuestionIndex]['question'] as String;
    final options = _quizData[_currentQuestionIndex]['options'] as List<String>;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Quiz', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${_quizData.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = _selectedOption == option;
                    final isCorrect = isSelected && _isCorrect;
                    final isWrong = isSelected && !_isCorrect;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () => _checkAnswer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCorrect
                              ? Colors.green
                              : isWrong
                                  ? Colors.red
                                  : Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[300],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time Left: $_timeLeft s',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  CircularProgressIndicator(
                    value: _animationController.value,
                    backgroundColor: Colors.grey[700],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 230, 169, 14)),
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
