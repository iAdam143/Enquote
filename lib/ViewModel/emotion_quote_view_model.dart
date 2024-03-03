import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Quote {
  final String text;

  Quote({required this.text});
}

class Author {
  final String name;

  Author({required this.name});
}

class EmotionQuoteViewModel extends ChangeNotifier {
  static const pixabayApiKey = '13697105-18ea0075c457264524be9a937';
  static const pixabayApiUrl = 'https://pixabay.com/api/';

  final List<String> emotions = ['Happiness', 'Motivation', 'Love', 'Sadness'];
  String? selectedEmotion;
  List<Quote> quotes = [];
  List<Author> authors = [];

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? _backgroundImageUrl;

  String? get backgroundImageUrl => _backgroundImageUrl;

  Future<void> fetchBackgroundImage(String emotion) async {
    final apiUrl =
        '$pixabayApiUrl?key=$pixabayApiKey&q=$emotion&orientation=horizontal';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hits = data['hits'];
      if (hits != null && hits is List && hits.isNotEmpty) {
        final random = Random();
        final randomIndex = random.nextInt(hits.length);
        final imageUrl = hits[randomIndex]['largeImageURL'];

        // Notify listeners only if the image URL changes
        if (imageUrl != _backgroundImageUrl) {
          _backgroundImageUrl = imageUrl;
          notifyListeners();
        }
      }
    }
  }

  Future<void> fetchQuoteByEmotion(String? emotion) async {
    if (emotion == null) {
      return;
    }

    final url =
        'https://favqs.com/api/quotes?filter=${Uri.encodeComponent(emotion)}';

    _isLoading = true;
    notifyListeners();

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token c5a9b8025c339f358e334a91122da235',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['quotes'] != null && data['quotes'].length > 0) {
        final quotesData = data['quotes'].toList();

        // Shuffle the quotes randomly
        quotesData.shuffle(Random());

        final List<Map<String, dynamic>> quotesDataList = quotesData.cast<
            Map<String,
                dynamic>>(); // Explicitly cast to List<Map<String, dynamic>>

        quotes =
            quotesDataList.map((quote) => Quote(text: quote['body'])).toList();
        authors = quotesDataList
            .map((quote) => Author(name: quote['author']))
            .toList();
      } else {
        quotes = [Quote(text: 'No quotes found for this emotion.')];
        authors = [];
      }
    } else {
      print('Failed to fetch quote by emotion.');
    }

    _isLoading = false;
    notifyListeners();
  }

  static Future<void> fetchQuotes(
      EmotionQuoteViewModel viewModel, String? selectedEmotion) async {
    final response = await http.get(Uri.parse(
        'https://api.quotable.io/search/quotes?limit=15&fuzzyMaxEdits=3&query=${Uri.encodeComponent(selectedEmotion!)}'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];

      // Shuffle the list of quotes randomly
      results.shuffle(Random());

      // Take the first 5 quotes from the shuffled list
      final List<Map<String, String>> newQuotes =
          List<Map<String, String>>.from(
        results.take(5).map((quote) {
          return {
            'text': quote['content'].toString() ?? 'No content',
            'author': quote['author'].toString() ?? 'Unknown author',
          };
        }),
      );

      viewModel.quotes.addAll(
        newQuotes.map((quote) => Quote(text: quote['text'] ?? 'No content')),
      );
      viewModel.authors.addAll(
        newQuotes.map((quote) => Author(name: quote['author'] ?? 'No Content')),
      );

      // Notify listeners after updating the quotes
      viewModel.notifyListeners();
    } else {
      throw Exception('Failed to load quotes');
    }
  }

  void selectEmotion(String? emotion) {
    selectedEmotion = emotion;
    fetchQuoteByEmotion(selectedEmotion);
  }
}
