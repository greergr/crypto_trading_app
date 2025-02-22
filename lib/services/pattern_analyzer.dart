import '../models/trading_bot.dart';
import 'dart:math' as math;

class PatternAnalyzer {
  static final PatternAnalyzer _instance = PatternAnalyzer._internal();
  factory PatternAnalyzer() => _instance;
  PatternAnalyzer._internal();

  // تحليل أنماط التداول
  Map<String, dynamic> analyzeTradePatterns(List<Trade> trades) {
    if (trades.isEmpty) return {};

    // تحليل الوقت
    final timePatterns = _analyzeTimePatterns(trades);
    
    // تحليل حجم التداول
    final volumePatterns = _analyzeVolumePatterns(trades);
    
    // تحليل النجاح
    final successPatterns = _analyzeSuccessPatterns(trades);

    return {
      'time_patterns': timePatterns,
      'volume_patterns': volumePatterns,
      'success_patterns': successPatterns,
      'recommendations': _generateRecommendations(
        timePatterns,
        volumePatterns,
        successPatterns,
      ),
    };
  }

  // تحليل أنماط الوقت
  Map<String, dynamic> _analyzeTimePatterns(List<Trade> trades) {
    final hourlyDistribution = List.filled(24, 0);
    final hourlySuccess = List.filled(24, 0);
    
    for (var trade in trades) {
      final hour = trade.timestamp.hour;
      hourlyDistribution[hour]++;
      if (trade.profit > 0) {
        hourlySuccess[hour]++;
      }
    }

    // تحديد أفضل ساعات التداول
    final bestHours = <int>[];
    final worstHours = <int>[];
    
    for (var i = 0; i < 24; i++) {
      if (hourlyDistribution[i] >= 5) {  // نحتاج على الأقل 5 صفقات للتقييم
        final successRate = hourlySuccess[i] / hourlyDistribution[i];
        if (successRate >= 0.6) {
          bestHours.add(i);
        } else if (successRate <= 0.4) {
          worstHours.add(i);
        }
      }
    }

    return {
      'best_hours': bestHours,
      'worst_hours': worstHours,
      'hourly_distribution': hourlyDistribution,
      'hourly_success': hourlySuccess,
    };
  }

  // تحليل أنماط حجم التداول
  Map<String, dynamic> _analyzeVolumePatterns(List<Trade> trades) {
    if (trades.isEmpty) return {};

    final volumes = trades.map((t) => t.amount).toList();
    final avgVolume = volumes.reduce((a, b) => a + b) / volumes.length;
    final stdDev = _calculateStdDev(volumes);

    final volumeCategories = {
      'small': 0,
      'medium': 0,
      'large': 0,
    };

    final successByVolume = {
      'small': 0,
      'medium': 0,
      'large': 0,
    };

    for (var trade in trades) {
      final category = _categorizeVolume(trade.amount, avgVolume, stdDev);
      volumeCategories[category] = (volumeCategories[category] ?? 0) + 1;
      if (trade.profit > 0) {
        successByVolume[category] = (successByVolume[category] ?? 0) + 1;
      }
    }

    return {
      'volume_distribution': volumeCategories,
      'success_by_volume': successByVolume,
      'average_volume': avgVolume,
      'optimal_volume_range': _calculateOptimalVolumeRange(trades),
    };
  }

  // تحليل أنماط النجاح
  Map<String, dynamic> _analyzeSuccessPatterns(List<Trade> trades) {
    if (trades.isEmpty) return {};

    var consecutiveWins = 0;
    var consecutiveLosses = 0;
    var maxConsecutiveWins = 0;
    var maxConsecutiveLosses = 0;
    var currentStreak = 0;
    var isWinningStreak = false;

    final patterns = <String, int>{};

    for (var i = 0; i < trades.length; i++) {
      final trade = trades[i];
      
      // تحليل التتابع
      if (trade.profit > 0) {
        if (currentStreak >= 0) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
        consecutiveWins = math.max(consecutiveWins, currentStreak);
      } else {
        if (currentStreak <= 0) {
          currentStreak--;
        } else {
          currentStreak = -1;
        }
        consecutiveLosses = math.max(consecutiveLosses, -currentStreak);
      }

      // تحليل النمط
      if (i >= 2) {
        final pattern = _createPattern(trades.sublist(i - 2, i + 1));
        patterns[pattern] = (patterns[pattern] ?? 0) + 1;
      }
    }

    return {
      'max_consecutive_wins': maxConsecutiveWins,
      'max_consecutive_losses': maxConsecutiveLosses,
      'common_patterns': _findSignificantPatterns(patterns),
      'current_streak': currentStreak,
      'is_winning_streak': isWinningStreak,
    };
  }

  // توليد التوصيات
  List<String> _generateRecommendations(
    Map<String, dynamic> timePatterns,
    Map<String, dynamic> volumePatterns,
    Map<String, dynamic> successPatterns,
  ) {
    final recommendations = <String>[];

    // توصيات الوقت
    if (timePatterns['best_hours']?.isNotEmpty) {
      recommendations.add(
        'أفضل أوقات التداول هي: ${_formatHours(timePatterns['best_hours'])}'
      );
    }
    if (timePatterns['worst_hours']?.isNotEmpty) {
      recommendations.add(
        'تجنب التداول في: ${_formatHours(timePatterns['worst_hours'])}'
      );
    }

    // توصيات الحجم
    if (volumePatterns['optimal_volume_range'] != null) {
      final range = volumePatterns['optimal_volume_range'];
      recommendations.add(
        'الحجم الأمثل للتداول: ${range['min']} إلى ${range['max']}'
      );
    }

    // توصيات النمط
    if (successPatterns['common_patterns']?.isNotEmpty) {
      recommendations.add('الأنماط الأكثر نجاحاً:');
      for (var pattern in successPatterns['common_patterns']) {
        recommendations.add('- ${_describePattern(pattern)}');
      }
    }

    return recommendations;
  }

  // حساب الانحراف المعياري
  double _calculateStdDev(List<double> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    return math.sqrt(squaredDiffs.reduce((a, b) => a + b) / values.length);
  }

  // تصنيف حجم التداول
  String _categorizeVolume(double volume, double avg, double stdDev) {
    if (volume < avg - stdDev) return 'small';
    if (volume > avg + stdDev) return 'large';
    return 'medium';
  }

  // حساب النطاق الأمثل للحجم
  Map<String, double> _calculateOptimalVolumeRange(List<Trade> trades) {
    final successfulTrades = trades.where((t) => t.profit > 0).toList();
    if (successfulTrades.isEmpty) return {};

    final volumes = successfulTrades.map((t) => t.amount).toList();
    final avg = volumes.reduce((a, b) => a + b) / volumes.length;
    final stdDev = _calculateStdDev(volumes);

    return {
      'min': avg - stdDev,
      'max': avg + stdDev,
    };
  }

  // إنشاء نمط من سلسلة صفقات
  String _createPattern(List<Trade> trades) {
    return trades.map((t) => t.profit > 0 ? 'W' : 'L').join('');
  }

  // العثور على الأنماط المهمة
  List<Map<String, dynamic>> _findSignificantPatterns(Map<String, int> patterns) {
    final significantPatterns = patterns.entries
        .where((e) => e.value >= 5)  // نحتاج على الأقل 5 تكرارات
        .map((e) => {
          'pattern': e.key,
          'occurrences': e.value,
        })
        .toList();

    significantPatterns.sort((a, b) => b['occurrences'].compareTo(a['occurrences']));
    return significantPatterns.take(5).toList();
  }

  // تنسيق الساعات للعرض
  String _formatHours(List<int> hours) {
    return hours.map((h) => '${h.toString().padLeft(2, '0')}:00').join(', ');
  }

  // وصف النمط
  String _describePattern(Map<String, dynamic> pattern) {
    final patternStr = pattern['pattern'];
    final occurrences = pattern['occurrences'];
    
    String description = '';
    if (patternStr == 'WWW') {
      description = 'ثلاث صفقات رابحة متتالية';
    } else if (patternStr == 'LLL') {
      description = 'ثلاث صفقات خاسرة متتالية';
    } else if (patternStr == 'WLW') {
      description = 'ربح-خسارة-ربح';
    } else {
      description = patternStr.split('')
          .map((c) => c == 'W' ? 'ربح' : 'خسارة')
          .join('-');
    }
    
    return '$description (تكرر $occurrences مرات)';
  }
}
