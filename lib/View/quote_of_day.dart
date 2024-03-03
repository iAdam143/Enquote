import 'dart:convert';
import 'package:Enquote/View/RelatedQuotesScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import '../ViewModel/quote_of_the_day_view_model.dart';

class QuoteOfTheDayScreen extends StatefulWidget {
  const QuoteOfTheDayScreen({super.key});

  @override
  _QuoteOfTheDayScreenState createState() => _QuoteOfTheDayScreenState();
}

class _QuoteOfTheDayScreenState extends State<QuoteOfTheDayScreen>
    with SingleTickerProviderStateMixin {
  String backgroundImageUrl =
      'assets/images/dan-meyers-ucmEHogvn1g-unsplash.jpg';
  late Animation<double> _bounceAnimation;
  late QuoteOfTheDayViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    fetchBackgroundImage();
    _viewModel = QuoteOfTheDayViewModel(vsync: this);
    _viewModel.init();

    _bounceAnimation = _viewModel.bounceAnimation;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> fetchBackgroundImage() async {
    const apiKey = '13697105-18ea0075c457264524be9a937';
    const apiUrl = 'https://pixabay.com/api/?key=$apiKey&category=nature';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final images = responseData['hits'] as List<dynamic>;
        if (images.isEmpty) {
          throw Exception("No images found");
        }
        final random = Random();
        final randomIndex = random.nextInt(images.length);
        final selectedImage = images[randomIndex];
        final imageUrl = selectedImage['largeImageURL'];

        setState(() {
          backgroundImageUrl = imageUrl;
        });
      } else {
        throw Exception("Failed to fetch image: ${response.statusCode}");
      }
    } catch (e) {
      // Handle network or API error
      //print("Error fetching background image: $e");
      //can display an error message to the user here if needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                'Quote of the Day',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (BuildContext context, Widget? child) {
                        return Transform.translate(
                          offset: Offset(0.0, -_bounceAnimation.value),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: QuoteCard(
                              viewModel: _viewModel,
                              backgroundImageUrl: backgroundImageUrl,
                            ),
                          ),
                        );
                      },
                    ),
                    const Text(
                      'Shake to Refresh',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    if (backgroundImageUrl.startsWith('http')) {
      return BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(backgroundImageUrl),
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Use a transparent placeholder or a loading indicator
      return const BoxDecoration(
        color: Colors.white,
      );
    }
  }
}

class QuoteCard extends StatelessWidget {
  final QuoteOfTheDayViewModel viewModel;
  final String backgroundImageUrl;

  const QuoteCard(
      {super.key, required this.viewModel, required this.backgroundImageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuoteDetailsScreen(
              quoteText: viewModel.quoteText,
              quoteAuthor: viewModel.quoteAuthor,
              backgroundImageUrl:
                  backgroundImageUrl, // Pass the background image URL
            ),
          ),
        );
      },
      child: Card(
        color: Colors.blue.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                viewModel.quoteText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '- ${viewModel.quoteAuthor} -',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
