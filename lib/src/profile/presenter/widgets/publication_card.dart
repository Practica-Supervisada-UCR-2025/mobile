import 'package:flutter/material.dart';
import 'package:mobile/src/profile/profile.dart';

class PublicationCard extends StatelessWidget {
  final Publication publication;

  const PublicationCard({
    super.key,
    required this.publication,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(publication.profileImageUrl),
                    radius: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          publication.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatDate(publication.createdAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // No action for now
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// Content text with "See more"
              _ExpandableText(content: publication.content),

              const SizedBox(height: 8),

              /// Attachment
              if (publication.attachment != null && publication.attachment!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    publication.attachment!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 8),

              /// Reactions & Comments
              Row(
                children: const [
                  Icon(Icons.favorite_border, size: 20),
                  SizedBox(width: 4),
                  Text('0'),
                  SizedBox(width: 16),
                  Icon(Icons.chat_bubble_outline, size: 20),
                  SizedBox(width: 4),
                  Text('0'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays >= 30) {
      final months = diff.inDays ~/ 30;
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'just now';
    }
  }
}

class _ExpandableText extends StatefulWidget {
  final String content;

  const _ExpandableText({required this.content});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;
  static const int _limit = 250;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.content.length > _limit;
    final displayText = _expanded || !isLong
        ? widget.content
        : '${widget.content.substring(0, _limit)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayText),
        if (isLong)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              _expanded ? 'See less' : 'See more',
              style: const TextStyle(fontSize: 14),
            ),
          ),
      ],
    );
  }
}
