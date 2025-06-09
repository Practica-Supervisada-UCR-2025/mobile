import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/comments/presenter/widgets/comment_input_box.dart';

class CommentsPage extends StatelessWidget {
  final Publication publication;

  const CommentsPage({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comentarios"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _PostPreview(publication: publication),
          const Divider(height: 1),
          const Expanded(child: CommentsList()),
          const CommentInputBox(),
        ],
      ),
    );
  }
}

class _PostPreview extends StatelessWidget {
  final Publication publication;

  const _PostPreview({required this.publication});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(publication.profileImageUrl),
      ),
      title: Text(publication.username, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            publication.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (publication.attachment != null && publication.attachment!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
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
        ],
      ),
    );
  }
}

class CommentsList extends StatelessWidget {
  const CommentsList({super.key});

  @override
  Widget build(BuildContext context) {
    // Luego lo conectamos a bloc
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        return const ListTile(
          leading: CircleAvatar(),
          title: Text("Usuario123"),
          subtitle: Text("Este es un comentario de prueba"),
        );
      },
    );
  }
}
