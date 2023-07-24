import 'package:flutter/material.dart';

class Article {
  final String title;
  final String description;

  Article({required this.title, required this.description});
}

class ScrapScreen extends StatelessWidget {
  final List<Article> articles = [
    Article(
      title: "Article 1",
      description: "This is the description of Article 1.",
    ),
    Article(
      title: "Article 2",
      description: "This is the description of Article 2.",
    ),
    Article(
      title: "Article 3",
      description: "This is the description of Article 3.",
    ),
    // Add more articles as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(articles[index].title),
            subtitle: Text(articles[index].description),
            onTap: () {
              // You can add navigation to the article detail page here if needed
              // For this example, we will just print the article title to the console.
              print("Article title: ${articles[index].title}");
            },
          );
        },
      ),
    );
  }
}
