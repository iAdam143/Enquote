import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shake/shake.dart';

class QuoteOfTheDayViewModel {
  late AnimationController animationController;
  late Animation<double> bounceAnimation;

  String quoteText = '';
  String quoteAuthor = '';
  late ShakeDetector detector;

  QuoteOfTheDayViewModel({required TickerProvider vsync}) {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );
    bounceAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void init() async {
    await fetchQuoteOfTheDay();

    detector = ShakeDetector.autoStart(onPhoneShake: () {
      fetchQuoteFromAnotherAPI();
    });

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      }
    });
  }

  void dispose() {
    detector.stopListening();
    animationController.dispose();
  }

  Future<void> fetchQuoteOfTheDay() async {
    // First API request
    final response = await http.get(
      Uri.parse('https://zenquotes.io/api/today'),
      // Add headers or any other necessary configurations for the second API
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      quoteText = data[0]['q'];
      quoteAuthor = data[0]['a'];
      animationController.reset();
      animationController.forward();
    } else {
      print('Failed to fetch quote from the first API. Trying another API.');

      // If the first API fails, try another API
      await fetchQuoteFromAnotherAPI();
    }
  }

  Future<void> fetchQuoteFromAnotherAPI() async {
    // Second API request (ZenQuotes)
    final response = await http.get(
      Uri.parse('https://favqs.com/api/qotd'),
      headers: {
        'Authorization': 'c5a9b8025c339f358e334a91122da235',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      quoteText = data['quote']['body'];
      quoteAuthor = data['quote']['author'];
      animationController.reset();

      animationController.forward();
    } else {
      print('Failed to fetch quote from the second API as well.');
    }
  }
}
