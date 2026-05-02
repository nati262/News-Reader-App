import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/news_providers.dart';
import '../widgets/articel_card.dart';
import '../widgets/error_display.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch headlines after first frame so context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NewsProvider>().fetchHeadlines();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Headlines'),
        elevation: 0,
        actions: [
          // Country selector
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: provider.selectedCountry,
                icon: const Icon(Icons.public),
                borderRadius: BorderRadius.circular(8),
                items: NewsProvider.countries.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (code) {
                  if (code != null) {
                    provider.fetchHeadlines(countryCode: code);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(NewsProvider provider) {
    if (provider.headlinesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.headlinesError != null) {
      return ErrorDisplay(
        message: provider.headlinesError!,
        onRetry: () => provider.fetchHeadlines(),
      );
    }

    if (provider.headlines.isEmpty) {
      return const Center(child: Text('No headlines found.'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchHeadlines(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: provider.headlines.length,
        itemBuilder: (_, index) =>
            ArticleCard(article: provider.headlines[index]),
      ),
    );
  }
}
