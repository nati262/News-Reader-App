import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/news_providers.dart';
import '../widgets/articel_card.dart';
import '../widgets/error_display.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search() {
    _focusNode.unfocus();
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    context.read<NewsProvider>().searchArticles(query);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Search News'), elevation: 0),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Search articles...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                provider.clearSearch();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _search, child: const Text('Search')),
              ],
            ),
          ),

          // Results
          Expanded(child: _buildResults(provider)),
        ],
      ),
    );
  }

  Widget _buildResults(NewsProvider provider) {
    if (provider.searchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.searchError != null) {
      return ErrorDisplay(message: provider.searchError!, onRetry: _search);
    }

    if (provider.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Search for articles by keyword',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: provider.searchResults.length,
      itemBuilder: (_, index) =>
          ArticleCard(article: provider.searchResults[index]),
    );
  }
}
