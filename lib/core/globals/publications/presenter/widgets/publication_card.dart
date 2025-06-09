import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/comments/presenter/page/comments_page.dart';
import 'package:mobile/src/comments/presenter/widgets/comments_modal.dart';


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
      child: Container(
        decoration: BoxDecoration(
          border: Border (
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 0.3,
            ),
          )
        ),
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
                    backgroundImage: NetworkImage(DEFAULT_PROFILE_PIC),
                    foregroundImage: NetworkImage(publication.profileImageUrl),
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
                          relativeDate(publication.createdAt),
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

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, size: 20),
                    onPressed: () {
                    },
                  ),
                  Text(publication.likes.toString()),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CommentsPage(publication: publication),
                        ),
                      );
                    },
                  ),
                  Text(publication.comments.toString()),
                ],
              ),

              const SizedBox(height: 8),

              /// Share button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () {
                      // futuro: manejar compartir
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
