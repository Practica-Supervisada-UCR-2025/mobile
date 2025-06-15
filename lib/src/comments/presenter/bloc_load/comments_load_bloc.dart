import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:equatable/equatable.dart';

part 'comments_load_event.dart';
part 'comments_load_state.dart';

class CommentsLoadBloc extends Bloc<CommentsLoadEvent, CommentsLoadState> {
  final CommentsRepository repository;
  final String postId;

  CommentsLoadBloc({
    required this.repository,
    required this.postId,
  }) : super(const CommentsLoadInitial()) {
    on<FetchInitialComments>(_onFetchInitialComments);
    on<FetchMoreComments>(_onFetchMoreComments);
  }

  Future<void> _onFetchInitialComments(
    FetchInitialComments event,
    Emitter<CommentsLoadState> emit,
  ) async {
    // -----------------------------
    // MODO PRUEBA CON COMENTARIOS MOCK
    // -----------------------------

    final now = DateTime.now();
    const String fakeProfileBaseUrl = 'https://i.pravatar.cc/150?u=';
    const String fakeAttachmentUrl = 'https://picsum.photos/seed/picsum/400/300';

    final mockComments = List.generate(10, (index) {
      return CommentModel(
        id: '${index + 1}',
        username: 'Usuario${index + 1}',
        content: 'Este es el comentario de prueba número ${index + 1}.',
        createdAt: now.subtract(Duration(minutes: (10 - index) * 5)),
        profileImageUrl: '$fakeProfileBaseUrl${index + 1}',
        attachmentUrl: (index == 0 || index % 3 == 0) ? fakeAttachmentUrl : null,
      );
    });

    emit(CommentsLoaded(
      comments: mockComments,
      hasReachedEnd: true,
      currentIndex: 0,
    ));

    // -----------------------------
    // CÓDIGO ORIGINAL DESACTIVADO TEMPORALMENTE
    // -----------------------------
    
    // try {
    //   final response = await repository.fetchComments(
    //     postId: postId,
    //     startTime: DateTime.fromMillisecondsSinceEpoch(0),
    //   );
    //   emit(CommentsLoaded(
    //     comments: response.comments,
    //     hasReachedEnd: response.comments.length >= response.totalItems,
    //     currentIndex: response.currentIndex,
    //   ));
    // } catch (e) {
    //   emit(CommentsError(message: e.toString()));
    // }
    
  }


  Future<void> _onFetchMoreComments(
    FetchMoreComments event,
    Emitter<CommentsLoadState> emit,
  ) async {
    if (state is! CommentsLoaded || (state as CommentsLoaded).hasReachedEnd) return;

    final currentState = state as CommentsLoaded;

    try {
      final response = await repository.fetchComments(
        postId: postId,
        startTime: currentState.comments.last.createdAt,
      );

      final updatedComments = List<CommentModel>.from(currentState.comments)
        ..addAll(response.comments);

      emit(currentState.copyWith(
        comments: updatedComments,
        hasReachedEnd: updatedComments.length >= response.totalItems,
        currentIndex: response.currentIndex,
      ));
    } catch (e) {
      emit(CommentsError(message: e.toString()));
    }
  }
}
