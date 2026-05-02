class Article {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String sourceName;
  final String? author;
  final String publishedAt;

  Article({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.sourceName,
    this.author,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No description available.',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      sourceName: json['source']?['name'] ?? 'Unknown Source',
      author: json['author'],
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}
