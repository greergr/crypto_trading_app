import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsArticle {
  final String title;
  final String content;
  final String source;
  final DateTime publishedAt;
  final double sentiment;

  NewsArticle({
    required this.title,
    required this.content,
    required this.source,
    required this.publishedAt,
    required this.sentiment,
  });
}

class NewsService {
  final String _apiKey = 'YOUR_NEWS_API_KEY'; // Replace with your actual API key
  final String _baseUrl = 'https://newsapi.org/v2';
  
  List<NewsArticle> _cachedNews = [];
  DateTime? _lastUpdate;
  
  static const Duration _cacheTimeout = Duration(minutes: 15);

  Future<List<NewsArticle>> getLatestNews(String symbol) async {
    if (_shouldUpdateCache()) {
      await _updateNewsCache(symbol);
    }
    return _cachedNews;
  }

  bool _shouldUpdateCache() {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > _cacheTimeout;
  }

  Future<void> _updateNewsCache(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/everything?q=$symbol+crypto&sortBy=publishedAt&language=en&apiKey=$_apiKey'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cachedNews = _parseNewsResponse(data);
        _lastUpdate = DateTime.now();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating news cache: $e');
      // Keep using old cache if update fails
    }
  }

  List<NewsArticle> _parseNewsResponse(Map<String, dynamic> data) {
    final articles = data['articles'] as List;
    return articles.map((article) {
      // Simple sentiment analysis based on title keywords
      final sentiment = _calculateSimpleSentiment(article['title']);
      
      return NewsArticle(
        title: article['title'],
        content: article['description'] ?? '',
        source: article['source']['name'] ?? 'Unknown',
        publishedAt: DateTime.parse(article['publishedAt']),
        sentiment: sentiment,
      );
    }).toList();
  }

  double _calculateSimpleSentiment(String text) {
    final positiveWords = [
      'bull', 'bullish', 'gain', 'gains', 'positive', 'up', 'upward',
      'rise', 'rising', 'higher', 'increase', 'growth', 'growing',
      'strong', 'strength', 'opportunity', 'optimistic', 'success',
    ];

    final negativeWords = [
      'bear', 'bearish', 'loss', 'losses', 'negative', 'down', 'downward',
      'fall', 'falling', 'lower', 'decrease', 'decline', 'declining',
      'weak', 'weakness', 'risk', 'pessimistic', 'fail', 'failure',
    ];

    text = text.toLowerCase();
    int positiveCount = positiveWords.where((word) => text.contains(word)).length;
    int negativeCount = negativeWords.where((word) => text.contains(word)).length;
    
    if (positiveCount == 0 && negativeCount == 0) return 0.5;
    return positiveCount / (positiveCount + negativeCount);
  }

  Future<double> getAverageSentiment() async {
    if (_cachedNews.isEmpty) return 0.5;
    
    final totalSentiment = _cachedNews.fold<double>(
      0,
      (sum, article) => sum + article.sentiment,
    );
    
    return totalSentiment / _cachedNews.length;
  }
}
