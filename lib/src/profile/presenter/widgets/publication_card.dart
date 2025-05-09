import 'package:flutter/material.dart';

class PublicationCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onDelete;

  const PublicationCard({
    super.key,
    required this.post,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = post['createdAt'] as DateTime;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatDate(createdAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
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
              Text(post['text']),
              const SizedBox(height: 8),

              // Sample attached if there is one
              if (post['attachments'].isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post['attachments'].first,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.favorite_border, size: 20),
                  const SizedBox(width: 4),
                  Text('${post['reactions']}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.chat_bubble_outline, size: 20),
                  const SizedBox(width: 4),
                  Text('${post['comments']}'),
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
