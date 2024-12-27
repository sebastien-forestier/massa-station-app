// Flutter imports:
import 'package:flutter/material.dart';

class NoSearchResult extends StatelessWidget {
  final String searchText;
  //final bool isDarkTheme;

  const NoSearchResult({
    super.key,
    //required this.isDarkTheme,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon or Image to depict "no results" scenario
          Icon(
            Icons.search_off, // A built-in "no search results" icon
            size: 100,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Dynamic message showing the search text
          Text(
            'Sorry, we couldn\'t find any results for "$searchText". Please try another term.',
            //textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
