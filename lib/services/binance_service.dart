import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/trade_type.dart';
import '../utils/logger.dart';
import 'api_key_service.dart';

class BinanceService {
  final APIKeyService _apiKeyService;
  final Logger _logger = Logger('BinanceService');
  final String _baseUrl;

  BinanceService(this._apiKeyService)
      : _baseUrl = _apiKeyService.isTestnet
            ? 'https://testnet.binance.vision/api'
            : 'https://api.binance.com/api';

  Future<Map<String, dynamic>> validateApiKeys() async {
    try {
      final response = await _sendRequest(
        '/v3/account',
        method: 'GET',
        signed: true,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'API keys are valid'};
      } else {
        return {
          'success': false,
          'message': 'Invalid API keys: ${response.body}',
        };
      }
    } catch (e) {
      _logger.e('Error validating API keys: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<double> getCurrentPrice(String symbol) async {
    try {
      final response = await _sendRequest(
        '/v3/ticker/price',
        method: 'GET',
        queryParameters: {'symbol': symbol},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return double.parse(data['price']);
      } else {
        throw Exception('Failed to get current price');
      }
    } catch (e) {
      _logger.e('Error getting current price: $e');
      rethrow;
    }
  }

  Future<List<double>> getHistoricalPrices(String symbol) async {
    try {
      final response = await _sendRequest(
        '/v3/klines',
        method: 'GET',
        queryParameters: {
          'symbol': symbol,
          'interval': '1h',
          'limit': '24',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((kline) => double.parse(kline[4] as String)).toList();
      } else {
        throw Exception('Failed to get historical prices');
      }
    } catch (e) {
      _logger.e('Error getting historical prices: $e');
      rethrow;
    }
  }

  Future<void> placeTrade(
    String symbol,
    TradeType type,
    double quantity, {
    double? stopLoss,
    double? takeProfit,
  }) async {
    try {
      // Place the main order
      final mainOrderResponse = await _sendRequest(
        '/v3/order',
        method: 'POST',
        signed: true,
        queryParameters: {
          'symbol': symbol,
          'side': type.toString(),
          'type': 'MARKET',
          'quantity': quantity.toString(),
        },
      );

      if (mainOrderResponse.statusCode != 200) {
        throw Exception('Failed to place main order: ${mainOrderResponse.body}');
      }

      final mainOrder = json.decode(mainOrderResponse.body);
      final filledPrice = double.parse(mainOrder['fills'][0]['price']);

      // Place stop loss if specified
      if (stopLoss != null) {
        await _sendRequest(
          '/v3/order',
          method: 'POST',
          signed: true,
          queryParameters: {
            'symbol': symbol,
            'side': type == TradeType.buy ? 'SELL' : 'BUY',
            'type': 'STOP_LOSS_LIMIT',
            'quantity': quantity.toString(),
            'stopPrice': stopLoss.toString(),
            'price': stopLoss.toString(),
            'timeInForce': 'GTC',
          },
        );
      }

      // Place take profit if specified
      if (takeProfit != null) {
        await _sendRequest(
          '/v3/order',
          method: 'POST',
          signed: true,
          queryParameters: {
            'symbol': symbol,
            'side': type == TradeType.buy ? 'SELL' : 'BUY',
            'type': 'LIMIT',
            'quantity': quantity.toString(),
            'price': takeProfit.toString(),
            'timeInForce': 'GTC',
          },
        );
      }
    } catch (e) {
      _logger.e('Error placing trade: $e');
      rethrow;
    }
  }

  Future<http.Response> _sendRequest(
    String path, {
    required String method,
    bool signed = false,
    Map<String, String>? queryParameters,
  }) async {
    try {
      var params = Map<String, String>.from(queryParameters ?? {});

      if (signed) {
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        params['timestamp'] = timestamp;
        
        final apiKey = await _apiKeyService.getApiKey();
        final secretKey = await _apiKeyService.getSecretKey();
        
        final queryString = Uri(queryParameters: params).query;
        final signature = _generateSignature(queryString, secretKey);
        params['signature'] = signature;

        if (method == 'GET') {
          final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: params);
          return await http.get(
            uri,
            headers: {'X-MBX-APIKEY': apiKey},
          );
        } else {
          final uri = Uri.parse('$_baseUrl$path');
          return await http.post(
            uri,
            headers: {'X-MBX-APIKEY': apiKey},
            body: params,
          );
        }
      } else {
        final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: params);
        return await http.get(uri);
      }
    } catch (e) {
      _logger.e('Error sending request: $e');
      rethrow;
    }
  }

  String _generateSignature(String queryString, String secretKey) {
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final digest = hmac.convert(utf8.encode(queryString));
    return digest.toString();
  }
}
