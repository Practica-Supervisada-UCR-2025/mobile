import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/core.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:mobile/src/comments/data/api/comments_Impl.repository.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

class CommentsPageController {
  final CommentsCreateBloc bloc;

  CommentsPageController({
    required this.bloc,
  });

  void handleCommentSubmitted({String? text, File? image, GifModel? selectedGif}) {
    bloc.add(CommentSubmitted(text: text, image: image, selectedGif: selectedGif));
  }
}

class CommentsPage extends StatefulWidget {
  final Publication publication;

  const CommentsPage({super.key, required this.publication});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _textController = TextEditingController();
  late final CommentsCreateBloc _createBloc;
  late final CommentsLoadBloc _loadBloc;

  @override
  void initState() {
    super.initState();

    final apiService = Provider.of<ApiService>(context, listen: false);
    final commentsRepository = CommentsRepositoryImpl(apiService: apiService);

    _loadBloc = CommentsLoadBloc(
      repository: commentsRepository,
      postId: widget.publication.id.toString(),
    )..add(FetchInitialComments());

    _createBloc = CommentsCreateBloc();
  }

  @override
  void dispose() {
    _textController.dispose();
    _loadBloc.close();
    _createBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unifiedBackgroundColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: unifiedBackgroundColor,
      appBar: AppBar(
        backgroundColor: unifiedBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text("Comments"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _loadBloc),
          BlocProvider.value(value: _createBloc),
        ],
        child: Column(
          children: [
            Expanded(
              child: CommentsList(publication: widget.publication),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  _createBloc.add(CommentTextChanged(text));
                },
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostPreview extends StatelessWidget {
  final Publication publication;
  const PostPreview({super.key, required this.publication});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(publication.profileImageUrl),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  publication.username,
                  style: textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            publication.content,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          if (publication.attachment != null &&
              publication.attachment!.isNotEmpty)
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