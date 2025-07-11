import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/core/globals/publications/presenter/widgets/image_page.dart';

class PublicationCard extends StatelessWidget {
  final Publication publication;

  const PublicationCard({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (publication.userId != null) {
                          context.go(Paths.externProfile(publication.userId!));
                        }
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(DEFAULT_PROFILE_PIC),
                        foregroundImage: NetworkImage(publication.profileImageUrl),
                        radius: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (publication.userId != null) {
                            context.go(Paths.externProfile(publication.userId!));
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              publication.username,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              relativeDate(publication.createdAt),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PublicationOptionsButton(
                      publicationId: publication.id,
                      publicationUsername: publication.username,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (publication.content.trim().isNotEmpty)
                  _ExpandableText(content: publication.content),

                const SizedBox(height: 8),

                if (publication.attachment != null &&
                    publication.attachment!.trim().isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ImagePreviewScreen(imageUrl: publication.attachment!),
                        ),
                      );
                    },
                    child: Hero(
                      tag: publication.attachment!,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          publication.attachment!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _InteractionButton(
                          icon: Icons.favorite_border,
                          label: '',
                          onPressed: () {
                          },
                        ),
                        const SizedBox(width: 24),
                        _InteractionButton(
                          icon: Icons.chat_bubble_outline,
                          label: publication.comments.toString(),
                          onPressed: () {
                            context.push(Paths.comments, extra: publication);
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      onPressed: () {
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 0.3,
          height: 0,
        ),
      ],
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 14)),
            ]
          ],
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
    final displayText =
        _expanded || !isLong
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