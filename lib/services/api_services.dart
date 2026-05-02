import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/article.dart';
import 'api_exception.dart';

class ApiService {
  static const String _baseUrl = 'https://newsapi.org';
  static const Duration _timeout = Duration(seconds: 15);

  String get _apiKey => dotenv.env['NEWS_API_KEY'] ?? '';

  /// Fetches top headlines for a given country code (e.g. 'us', 'gb').
  Future<List<Article>> fetchTopHeadlines(String countryCode) async {
    final uri = Uri.parse(
      '$_baseUrl/v2/top-headlines?country=$countryCode&apiKey=$_apiKey',
    );
    return _get(uri);
  }

  /// Searches articles by keyword across all sources.
  Future<List<Article>> searchArticles(String query) async {
    final uri = Uri.parse(
      '$_baseUrl/v2/everything?q=${Uri.encodeComponent(query)}&apiKey=$_apiKey&pageSize=20',
    );
    return _get(uri);
  }

  Future<List<Article>> _get(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        final msg = body['message'] ?? 'Unknown server error';
        throw ApiException(statusCode: response.statusCode, message: msg);
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> articlesJson = data['articles'] ?? [];

      return articlesJson
          .map((json) => Article.fromJson(json))
          .where((a) => a.title != '[Removed]' && a.url.isNotEmpty)
          .toList();
    } on SocketException {
      throw const SocketException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please try again.');
    } on FormatException {
      throw const FormatException('Unexpected data format received');
    }
    // ApiException and generic exceptions bubble up naturally
  }
}
