import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ta_lib/ta_lib.dart';
import '../models/market_analysis.dart';
import 'binance_service.dart';

class MarketAnalysisService {
  final BinanceService _binanceService;
  final Duration _modelUpdateInterval = const Duration(hours: 24);
  final Duration _dataUpdateInterval = const Duration(minutes: 5);
  final int _historicalDataDays = 90;
  final int _lstmPredictionHours = 24;
  
  Timer? _modelUpdateTimer;
  Timer? _dataUpdateTimer;
  Map<String, DataFrame> _historicalData = {};
  Map<String, List<double>> _predictions = {};
  DateTime? _lastModelUpdate;
  
  // News sources configuration
  final Map<String, Map<String, dynamic>> _newsSources = {
    'cointelegraph': {
      'url': 'https://cointelegraph.com/api/v1/news',
      'weight': 1.0,
      'reliability': 0.8,
    },
    'coindesk': {
      'url': 'https://www.coindesk.com/api/v1/news',
      'weight': 1.0,
      'reliability': 0.85,
    },
    'bitcoin.com': {
      'url': 'https://news.bitcoin.com/api/v1/news',
      'weight': 0.8,
      'reliability': 0.75,
    },
    'cryptonews': {
      'url': 'https://cryptonews.com/api/v1/news',
      'weight': 0.9,
      'reliability': 0.8,
    },
    'decrypt': {
      'url': 'https://decrypt.co/api/v1/news',
      'weight': 0.9,
      'reliability': 0.85,
    },
  };

  MarketAnalysisService(this._binanceService) {
    _startPeriodicUpdates();
  }

  void _startPeriodicUpdates() {
    // Cancel existing timers
    _modelUpdateTimer?.cancel();
    _dataUpdateTimer?.cancel();

    // Start new update cycles
    _modelUpdateTimer = Timer.periodic(_modelUpdateInterval, (_) => _updateModel());
    _dataUpdateTimer = Timer.periodic(_dataUpdateInterval, (_) => _updateData());

    // Initial updates
    _updateModel();
    _updateData();
  }

  Future<void> _updateModel() async {
    try {
      _lastModelUpdate = DateTime.now();
      await _updateHistoricalData();
      await _updatePredictions();
      await _updateNewsSentiment();
    } catch (e) {
      debugPrint('Error updating market analysis model: $e');
    }
  }

  Future<void> _updateData() async {
    try {
      // Update recent price data and indicators
      for (final symbol in _historicalData.keys) {
        final recentData = await _binanceService.getKlines(
          symbol: symbol,
          interval: '1m',
          limit: 1000, // Last ~16 hours
        );
        
        // Update DataFrame with new data
        final newData = DataFrame.fromMatrix(recentData);
        _historicalData[symbol] = _historicalData[symbol]!.concat(newData);
        
        // Remove duplicate entries and old data
        _cleanHistoricalData(symbol);
      }
    } catch (e) {
      debugPrint('Error updating market data: $e');
    }
  }

  void _cleanHistoricalData(String symbol) {
    try {
      final data = _historicalData[symbol]!;
      
      // Remove duplicates
      final uniqueRows = <List<dynamic>>{};
      final cleanData = data.rows.where((row) => uniqueRows.add(row)).toList();
      
      // Sort by timestamp
      cleanData.sort((a, b) => (a[0] as int).compareTo(b[0] as int));
      
      // Keep only last 90 days of data
      final cutoffTime = DateTime.now().subtract(Duration(days: _historicalDataDays));
      final recentData = cleanData.where(
        (row) => DateTime.fromMillisecondsSinceEpoch(row[0] as int).isAfter(cutoffTime)
      ).toList();
      
      _historicalData[symbol] = DataFrame.fromRows(recentData);
    } catch (e) {
      debugPrint('Error cleaning historical data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchNews() async {
    final allNews = <Map<String, dynamic>>[];
    
    for (final source in _newsSources.entries) {
      try {
        final response = await http.get(Uri.parse(source.value['url']));
        if (response.statusCode == 200) {
          final newsItems = json.decode(response.body) as List;
          for (final item in newsItems) {
            item['source'] = source.key;
            item['reliability'] = source.value['reliability'];
            item['weight'] = source.value['weight'];
            allNews.add(item as Map<String, dynamic>);
          }
        }
      } catch (e) {
        debugPrint('Error fetching news from ${source.key}: $e');
      }
    }
    
    // Sort by timestamp and relevance
    allNews.sort((a, b) {
      final timeA = DateTime.parse(a['publishedAt'] as String);
      final timeB = DateTime.parse(b['publishedAt'] as String);
      return timeB.compareTo(timeA);
    });
    
    return allNews;
  }

  Future<double> _calculateNewsSentiment(Map<String, dynamic> article) async {
    try {
      final text = '${article['title']} ${article['description']}'.toLowerCase();
      
      // Enhanced keyword lists with weights
      final sentimentKeywords = {
        'bullish': 0.8,
        'surge': 0.6,
        'rally': 0.7,
        'breakout': 0.6,
        'adoption': 0.5,
        'partnership': 0.4,
        'upgrade': 0.4,
        'bearish': -0.8,
        'crash': -0.7,
        'dump': -0.6,
        'ban': -0.5,
        'hack': -0.8,
        'scam': -0.9,
        'fraud': -0.9,
      };
      
      double sentiment = 0;
      int matches = 0;
      
      for (final entry in sentimentKeywords.entries) {
        if (text.contains(entry.key)) {
          sentiment += entry.value;
          matches++;
        }
      }
      
      // Normalize sentiment and apply source reliability
      if (matches > 0) {
        sentiment = (sentiment / matches) * 
                   (article['reliability'] as double) * 
                   (article['weight'] as double);
      }
      
      return sentiment.clamp(-1.0, 1.0);
    } catch (e) {
      debugPrint('Error calculating news sentiment: $e');
      return 0.0;
    }
  }

  Future<void> _updateNewsSentiment() async {
    try {
      final news = await _fetchNews();
      double totalSentiment = 0;
      double totalWeight = 0;
      
      for (final article in news) {
        final sentiment = await _calculateNewsSentiment(article);
        final weight = article['weight'] as double;
        
        totalSentiment += sentiment * weight;
        totalWeight += weight;
      }
      
      final averageSentiment = totalWeight > 0 ? totalSentiment / totalWeight : 0;
      debugPrint('Updated news sentiment: $averageSentiment');
    } catch (e) {
      debugPrint('Error updating news sentiment: $e');
    }
  }

  void dispose() {
    _modelUpdateTimer?.cancel();
    _dataUpdateTimer?.cancel();
  }
}
