import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/market_analyzer.dart';

class MarketIntelligence {
  static final MarketIntelligence _instance = MarketIntelligence._internal();
  factory MarketIntelligence() => _instance;
  MarketIntelligence._internal();

  late MarketAnalyzer _analyzer;
  Timer? _modelUpdateTimer;
  
  // مصادر الأخبار الموثوقة
  final _newsSources = [
    'cryptopanic.com',
    'coindesk.com',
    'cointelegraph.com',
  ];

  // تهيئة النظام
  Future<void> initialize() async {
    _analyzer = MarketAnalyzer();
    await _analyzer.initialize();
    _startAutoUpdate();
  }

  // بدء التحديث التلقائي
  void _startAutoUpdate() {
    // تحديث النموذج كل 24 ساعة
    _modelUpdateTimer = Timer.periodic(
      const Duration(hours: 24),
      (_) => _updateModel(),
    );
  }

  // تحديث النموذج
  Future<void> _updateModel() async {
    try {
      final lastUpdate = await _getLastUpdateTime();
      final now = DateTime.now();
      
      // تحقق من آخر تحديث
      if (lastUpdate != null && 
          now.difference(lastUpdate).inHours < 24) {
        print('النموذج محدث. آخر تحديث: ${lastUpdate.toString()}');
        return;
      }

      // جمع البيانات التاريخية الجديدة
      final historicalData = await _fetchHistoricalData();
      if (historicalData.isEmpty) {
        throw Exception('لا توجد بيانات تاريخية كافية');
      }
      
      // تحديث النموذج
      await _analyzer.updateModel(historicalData);
      
      // حفظ وقت التحديث
      await _saveLastUpdateTime(now);
      
      print('تم تحديث النموذج بنجاح في ${now.toString()}');
    } catch (e) {
      print('فشل في تحديث النموذج: $e');
      // جدولة محاولة أخرى بعد ساعة
      Timer(const Duration(hours: 1), _updateModel);
    }
  }

  // جمع البيانات التاريخية
  Future<List<Map<String, dynamic>>> _fetchHistoricalData() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 90));
    
    try {
      final binanceData = await _fetchBinanceData(startDate, endDate);
      final newsData = await _fetchHistoricalNews(startDate, endDate);
      final technicalData = await _fetchTechnicalIndicators(startDate, endDate);
      
      return _mergeHistoricalData(binanceData, newsData, technicalData);
    } catch (e) {
      print('فشل في جمع البيانات التاريخية: $e');
      rethrow;
    }
  }

  // دمج البيانات التاريخية
  List<Map<String, dynamic>> _mergeHistoricalData(
    List<Map<String, dynamic>> prices,
    List<Map<String, dynamic>> news,
    List<Map<String, dynamic>> technical,
  ) {
    final mergedData = <Map<String, dynamic>>[];
    
    for (final price in prices) {
      final timestamp = price['timestamp'] as DateTime;
      
      // البحث عن الأخبار المتزامنة
      final relevantNews = news.where((n) {
        final newsTime = n['timestamp'] as DateTime;
        return newsTime.difference(timestamp).inHours.abs() <= 24;
      }).toList();
      
      // البحث عن المؤشرات الفنية المتزامنة
      final relevantTechnical = technical.firstWhere(
        (t) => t['timestamp'] == timestamp,
        orElse: () => <String, dynamic>{},
      );
      
      mergedData.add({
        ...price,
        'news': relevantNews,
        'technical': relevantTechnical,
      });
    }
    
    return mergedData;
  }

  // تحليل الأخبار المهمة
  Future<List<Map<String, dynamic>>> getImportantNews(String symbol) async {
    final news = await _fetchNews(symbol);
    return _filterImportantNews(news);
  }

  // جلب الأخبار
  Future<List<Map<String, dynamic>>> _fetchNews(String symbol) async {
    final allNews = <Map<String, dynamic>>[];
    
    for (final source in _newsSources) {
      try {
        final response = await http.get(
          Uri.parse('https://api.$source/news/$symbol'),
        );
        
        if (response.statusCode == 200) {
          final newsData = json.decode(response.body);
          allNews.addAll(List<Map<String, dynamic>>.from(newsData));
        }
      } catch (e) {
        print('فشل في جلب الأخبار من $source: $e');
      }
    }
    
    return allNews;
  }

  // تصفية الأخبار المهمة
  List<Map<String, dynamic>> _filterImportantNews(
    List<Map<String, dynamic>> news,
  ) {
    // تحليل محتوى الخبر
    final contentAnalyzer = NewsContentAnalyzer();
    
    return news.where((item) {
      // تحليل المحتوى
      final contentScore = contentAnalyzer.analyzeContent(
        item['title'] as String,
        item['content'] as String,
      );
      
      // تحليل المصدر
      final sourceScore = _calculateSourceReliability(
        item['source'] as String,
      );
      
      // تحليل التفاعل
      final engagementScore = _calculateEngagementScore(
        item['engagement'] as Map<String, dynamic>,
      );
      
      // الحساب النهائي
      final finalScore = (contentScore * 0.5) + 
                        (sourceScore * 0.3) + 
                        (engagementScore * 0.2);
                        
      return finalScore > 0.7;
    }).toList();
  }

  // حساب موثوقية المصدر
  double _calculateSourceReliability(String source) {
    // قائمة المصادر مع درجات الموثوقية
    final sourceReliability = {
      'binance': 1.0,
      'coindesk': 0.9,
      'cointelegraph': 0.85,
      'cryptopanic': 0.8,
      // يمكن إضافة المزيد
    };
    
    // البحث عن أعلى درجة موثوقية تتطابق
    double maxReliability = 0.0;
    sourceReliability.forEach((key, value) {
      if (source.toLowerCase().contains(key.toLowerCase())) {
        maxReliability = value > maxReliability ? value : maxReliability;
      }
    });
    
    return maxReliability;
  }

  // حساب درجة التفاعل
  double _calculateEngagementScore(Map<String, dynamic> engagement) {
    final views = engagement['views'] as int? ?? 0;
    final shares = engagement['shares'] as int? ?? 0;
    final comments = engagement['comments'] as int? ?? 0;
    
    // معايير التفاعل
    const viewsThreshold = 5000;
    const sharesThreshold = 500;
    const commentsThreshold = 100;
    
    // حساب النسب
    final viewsScore = views / viewsThreshold;
    final sharesScore = shares / sharesThreshold;
    final commentsScore = comments / commentsThreshold;
    
    // المتوسط المرجح
    return (viewsScore * 0.4) + 
           (sharesScore * 0.4) + 
           (commentsScore * 0.2);
  }

  // إيقاف النظام
  void dispose() {
    _modelUpdateTimer?.cancel();
  }
}
