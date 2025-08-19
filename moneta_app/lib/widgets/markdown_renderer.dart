import 'package:flutter/material.dart';

/// A simple markdown renderer widget for financial advice text
class MarkdownRenderer extends StatelessWidget {
  final String text;
  final TextStyle? defaultStyle;

  const MarkdownRenderer({super.key, required this.text, this.defaultStyle});

  @override
  Widget build(BuildContext context) {
    final style = defaultStyle ?? Theme.of(context).textTheme.bodyLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _parseMarkdown(text, style, context),
    );
  }

  List<Widget> _parseMarkdown(
    String text,
    TextStyle? baseStyle,
    BuildContext context,
  ) {
    final widgets = <Widget>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Handle headers
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              line.substring(2),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              line.substring(3),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              line.substring(4),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      // Handle bullet points
      else if (line.startsWith('- ') || line.startsWith('• ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: baseStyle),
                Expanded(child: Text(line.substring(2), style: baseStyle)),
              ],
            ),
          ),
        );
      }
      // Handle numbered lists
      else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Text(line, style: baseStyle),
          ),
        );
      }
      // Handle bold text
      else if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              line.substring(2, line.length - 2),
              style: baseStyle?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      // Handle code blocks
      else if (line.startsWith('```')) {
        final codeLines = <String>[];
        i++; // Skip the opening ```
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              codeLines.join('\n'),
              style: TextStyle(
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
      }
      // Handle regular text with inline formatting
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: _buildRichText(line, baseStyle, context),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildRichText(
    String text,
    TextStyle? baseStyle,
    BuildContext context,
  ) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*|`(.*?)`');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Add normal text before the match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      // Add formatted text
      if (match.group(1) != null) {
        // Bold text **text**
        spans.add(
          TextSpan(
            text: match.group(1),
            style: baseStyle?.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      } else if (match.group(2) != null) {
        // Italic text *text*
        spans.add(
          TextSpan(
            text: match.group(2),
            style: baseStyle?.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(3) != null) {
        // Code text `text`
        spans.add(
          TextSpan(
            text: match.group(3),
            style: baseStyle?.copyWith(
              fontFamily: 'monospace',
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    // If no formatting was found, just return a simple Text widget
    if (spans.isEmpty) {
      return Text(text, style: baseStyle);
    }

    return RichText(text: TextSpan(children: spans));
  }
}
