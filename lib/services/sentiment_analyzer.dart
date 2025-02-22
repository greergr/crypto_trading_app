import 'dart:convert';
import 'package:http/http.dart' as http;

enum SentimentType {
  positive,
  negative,
  neutral
}

class SentimentAnalysis {
  final SentimentType type;
  final double score;
  final DateTime timestamp;

  SentimentAnalysis({
    required this.type,
    required this.score,
    required this.timestamp,
  });
}

class SentimentAnalyzer {
  static final SentimentAnalyzer _instance = SentimentAnalyzer._internal();
  factory SentimentAnalyzer() => _instance;
  SentimentAnalyzer._internal();

  static const _newsEndpoint = 'https://api.example.com/crypto/news';  // يجب تغييره لعنوان API حقيقي
  static const _twitterEndpoint = 'https://api.example.com/crypto/tweets';  // يجب تغييره لعنوان API حقيقي

  Future<SentimentAnalysis> analyzeCryptoSentiment(String symbol) async {
    try {
      // تحليل الأخبار
      final newsData = await _fetchNews(symbol);
      final newsSentiment = await _analyzeNewsData(newsData);

      // تحليل تويتر
      final twitterData = await _fetchTweets(symbol);
      final twitterSentiment = await _analyzeTweetData(twitterData);

      // دمج النتائج
      final combinedScore = (newsSentiment + twitterSentiment) / 2;
      
      return SentimentAnalysis(
        type: _getSentimentType(combinedScore),
        score: combinedScore,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('فشل في تحليل المشاعر: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchNews(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$_newsEndpoint?symbol=$symbol'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['articles'],
        );
      } else {
        throw Exception('فشل في جلب الأخبار');
      }
    } catch (e) {
      throw Exception('فشل في جلب الأخبار: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTweets(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$_twitterEndpoint?symbol=$symbol'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['tweets'],
        );
      } else {
        throw Exception('فشل في جلب التغريدات');
      }
    } catch (e) {
      throw Exception('فشل في جلب التغريدات: $e');
    }
  }

  Future<double> _analyzeNewsData(List<Map<String, dynamic>> newsData) async {
    // تنفيذ خوارزمية تحليل المشاعر على الأخبار
    // هذا مجرد مثال بسيط، يجب استخدام خوارزمية أكثر تعقيداً في الواقع
    double totalScore = 0;
    int count = 0;

    for (final article in newsData) {
      final title = article['title'] as String;
      final content = article['content'] as String;
      
      // تحليل بسيط باستخدام الكلمات المفتاحية
      final score = _analyzeText(title) * 0.6 + _analyzeText(content) * 0.4;
      
      totalScore += score;
      count++;
    }

    return count > 0 ? totalScore / count : 0;
  }

  Future<double> _analyzeTweetData(List<Map<String, dynamic>> tweetData) async {
    // تنفيذ خوارزمية تحليل المشاعر على التغريدات
    double totalScore = 0;
    int count = 0;

    for (final tweet in tweetData) {
      final text = tweet['text'] as String;
      final score = _analyzeText(text);
      
      totalScore += score;
      count++;
    }

    return count > 0 ? totalScore / count : 0;
  }

  double _analyzeText(String text) {
    // قائمة الكلمات الإيجابية والسلبية
    const positiveWords = [
      'bullish', 'up', 'gain', 'profit', 'growth',
      'strong', 'success', 'positive', 'buy', 'moon',
    ];

    const negativeWords = [
      'bearish', 'down', 'loss', 'crash', 'weak',
      'fail', 'negative', 'sell', 'dump', 'risk',
    ];

    text = text.toLowerCase();
    int positiveCount = 0;
    int negativeCount = 0;

    for (final word in text.split(' ')) {
      if (positiveWords.contains(word)) positiveCount++;
      if (negativeWords.contains(word)) negativeCount++;
    }

    final totalWords = text.split(' ').length;
    if (totalWords == 0) return 0;

    return (positiveCount - negativeCount) / totalWords;
  }

  SentimentType _getSentimentType(double score) {
    if (score > 0.1) return SentimentType.positive;
    if (score < -0.1) return SentimentType.negative;
    return SentimentType.neutral;
  }
}
