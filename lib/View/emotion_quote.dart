import 'package:Enquote/ViewModel/emotion_quote_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmotionQuoteScreen extends StatefulWidget {
  const EmotionQuoteScreen({super.key});

  @override
  _EmotionQuoteScreenState createState() => _EmotionQuoteScreenState();
}

class _EmotionQuoteScreenState extends State<EmotionQuoteScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<EmotionQuoteViewModel>(context, listen: false)
        .fetchBackgroundImage('emotion');
  }

  List<Map<String, String>> quotes1 = [];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EmotionQuoteViewModel>(context);
    final backgroundImageUrl = viewModel.backgroundImageUrl;

    return Scaffold(
      body: Stack(
        children: [
          if (backgroundImageUrl != null && backgroundImageUrl.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(backgroundImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Column(
            children: [
              AppBar(
                title: const Text(
                  'Emotion Quote',
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
              const Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: EmotionQuoteCard(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmotionQuoteCard extends StatelessWidget {
  const EmotionQuoteCard({Key? key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EmotionQuoteViewModel>(context);

    return Card(
      color: Colors.blueGrey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: viewModel.selectedEmotion,
                    items: [
                      if (viewModel.selectedEmotion == null)
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Select Emotion',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ...viewModel.emotions.map((emotion) {
                        return DropdownMenuItem<String>(
                          value: emotion,
                          child: Text(emotion,
                              style: const TextStyle(color: Colors.white)),
                        );
                      }),
                    ],
                    onChanged: (newValue) {
                      viewModel.selectEmotion(newValue);
                      if (newValue != null) {
                        final emotion = newValue.toLowerCase();
                        Provider.of<EmotionQuoteViewModel>(context,
                                listen: false)
                            .fetchBackgroundImage(emotion);
                      }
                    },
                    dropdownColor: Colors.transparent,
                    decoration: InputDecoration(
                      labelText: viewModel.selectedEmotion != null
                          ? 'Emotion'
                          : 'Select Emotion',
                      hintStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    viewModel.fetchQuoteByEmotion(viewModel.selectedEmotion);
                  },
                ),
              ],
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: viewModel.quotes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8.0),
              itemBuilder: (context, index) {
                final quote = viewModel.quotes[index];
                final author = viewModel.authors[index];
                return Card(
                  color: Colors.blue.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          quote.text,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '- ${author.name} -',
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Visibility(
              visible: viewModel.selectedEmotion != null,
              child: ElevatedButton(
                onPressed: () {
                  EmotionQuoteViewModel.fetchQuotes(
                      viewModel, viewModel.selectedEmotion);
                },
                child: const Text('Show More'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
