import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart'; // para Publication
import 'package:mobile/src/comments/presenter/widgets/comment_input_box.dart';

class CommentsModal extends StatelessWidget {
  final Publication post;

  const CommentsModal({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final viewHeight = MediaQuery.of(context).size.height * 0.9;

    return SizedBox(
      height: viewHeight,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          _PostPreview(post: post),
          const Divider(height: 1),
          const Expanded(child: CommentsList()),
          const CommentInputBox(),
        ],
      ),
    );
  }
}

class _PostPreview extends StatelessWidget {
  final Publication post;

  const _PostPreview({required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(post.profileImageUrl),
      ),
      title: Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

class CommentsList extends StatelessWidget {
  const CommentsList({super.key});

  @override
  Widget build(BuildContext context) {
    // Pronto: BLoC builder + scroll infinito
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return const ListTile(
          title: Text("UsuarioX"),
          subtitle: Text("Este es un comentario de ejemplo."),
        );
      },
    );
  }
}
