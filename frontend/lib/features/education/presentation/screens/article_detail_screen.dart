import 'package:flutter/material.dart';
import '../../data/education_data.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  static const _categoryColors = {
    'Health': Color(0xFF00BCD4),
    'Nutrition': Color(0xFF4CAF50),
    'Psychology': Color(0xFFFF9800),
    'Safety': Color(0xFFE91E63),
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[article.category] ?? const Color(0xFF7C4DFF);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0A2E),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      article.category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero emoji
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            article.imageEmoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        article.tag,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Read time
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white38,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.readTime,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Container(height: 1, color: Colors.white10),
                    const SizedBox(height: 20),

                    // Content
                    _buildContent(article.content, color),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String content, Color accentColor) {
    final lines = content.trim().split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (trimmed.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              trimmed.substring(3),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: Text(
              trimmed.substring(4),
              style: TextStyle(
                color: accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('- **')) {
        // Bold bullet
        final rest = trimmed.substring(2);
        final boldEnd = rest.indexOf('**', 2);
        if (boldEnd > 0) {
          final boldText = rest.substring(2, boldEnd);
          final normalText = rest.substring(boldEnd + 2);
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: boldText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: normalText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else if (trimmed.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    trimmed.substring(2),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trimmed.split('.').first}. ',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    trimmed.substring(trimmed.indexOf('.') + 1).trim(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              trimmed,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
