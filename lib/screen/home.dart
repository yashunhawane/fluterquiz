import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class QuizData {
  String question;
  List<String> correctAnswers;
  List<String> incorrectAnswers;
  String? selectedAnswer;
  QuizData(
      {required this.question,
      required this.correctAnswers,
      required this.incorrectAnswers,
      this.selectedAnswer});
}

class _HomeState extends State<Home> {
  final List<QuizData> quizData = [];

  @override
  void initState() {
    super.initState();
    fetchQuizData();
  }

  Future<void> fetchQuizData() async {
    print("Fetching data...");
    final response = await http.get(
      Uri.parse('https://opentdb.com/api.php?amount=20'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> results = body['results'];
      setState(() {
        quizData.clear(); // Clear existing data
        for (var result in results) {
          List<String> correctAnswers = [result['correct_answer']];
          List<String> incorrectAnswers =
              List<String>.from(result['incorrect_answers']);
          quizData.add(
            QuizData(
              question: result['question'],
              correctAnswers: correctAnswers,
              incorrectAnswers: incorrectAnswers,
            ),
          );
        }
      });
      print("Data fetched successfully.");
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Quiz",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: quizData.length,
        itemBuilder: (context, index) {
          List<String> allAnswers = [];
          allAnswers.addAll(quizData[index].correctAnswers);
          allAnswers.addAll(quizData[index].incorrectAnswers);

          return Card(
            elevation: 4,
            color: const Color.fromARGB(255, 172, 142, 255),
            margin: const EdgeInsets.fromLTRB(10, 15, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Q-${quizData[index].question}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: allAnswers.map((answer) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            quizData[index].selectedAnswer = answer;
                          });
                        },
                        child: Text(
                          answer,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: quizData[index].selectedAnswer == answer
                                ? (quizData[index]
                                        .correctAnswers
                                        .contains(answer)
                                    ? FontWeight
                                        .bold // Style correct answer as bold
                                    : FontWeight
                                        .normal) // Style incorrect answer as normal
                                : FontWeight.normal,
                            color: quizData[index].selectedAnswer == answer
                                ? (quizData[index]
                                        .correctAnswers
                                        .contains(answer)
                                    ? Colors.green // Color correct answer green
                                    : Colors.red) // Color incorrect answer red
                                : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
