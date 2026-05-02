//news provider
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/api_exception.dart';
import '../services/api_services.dart';

class NewsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ── Headlines ──────────────────────────────────────────────────────────────
  List<Article> _headlines = [];
  bool _headlinesLoading = false;
  String? _headlinesError;
  String _selectedCountry = 'us';

  List<Article> get headlines => _headlines;
  bool get headlinesLoading => _headlinesLoading;
  String? get headlinesError => _headlinesError;
  String get selectedCountry => _selectedCountry;

  // ── Search ─────────────────────────────────────────────────────────────────
  List<Article> _searchResults = [];
  bool _searchLoading = false;
  String? _searchError;

  List<Article> get searchResults => _searchResults;
  bool get searchLoading => _searchLoading;
  String? get searchError => _searchError;

  // ── Supported countries ────────────────────────────────────────────────────
  static const Map<String, String> countries = {
    'us': '🇺🇸 United States',
    'gb': '🇬🇧 United Kingdom',
    'in': '🇮🇳 India',
    'au': '🇦🇺 Australia',
    'ca': '🇨🇦 Canada',
    'de': '🇩🇪 Germany',
    'fr': '🇫🇷 France',
  };

  // ── Public Methods ─────────────────────────────────────────────────────────

  Future<void> fetchHeadlines({String? countryCode}) async {
    if (countryCode != null) _selectedCountry = countryCode;
    _headlinesLoading = true;
    _headlinesError = null;
    notifyListeners();

    try {
      _headlines = await _apiService.fetchTopHeadlines(_selectedCountry);
    } catch (e) {
      _headlinesError = _friendlyError(e);
    } finally {
      _headlinesLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchArticles(String query) async {
    if (query.trim().isEmpty) return;
    _searchLoading = true;
    _searchError = null;
    _searchResults = [];
    notifyListeners();

    try {
      _searchResults = await _apiService.searchArticles(query.trim());
    } catch (e) {
      _searchError = _friendlyError(e);
    } finally {
      _searchLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchError = null;
    notifyListeners();
  }

  // ── Error Mapping ──────────────────────────────────────────────────────────

  String _friendlyError(Object e) {
    if (e is SocketException) return 'No internet connection';
    if (e is TimeoutException) return 'Request timed out. Please try again.';
    if (e is ApiException) return 'Error ${e.statusCode}: ${e.message}';
    if (e is FormatException) return 'Unexpected data format received';
    return 'An unexpected error occurred: ${e.toString()}';
  }
}
