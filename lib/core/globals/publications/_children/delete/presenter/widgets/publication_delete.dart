import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';

class DeleteBottomSheet extends StatefulWidget {
  final String publicationId;

  const DeleteBottomSheet({super.key, required this.publicationId});

  @override
  State<DeleteBottomSheet> createState() => _DeleteBottomSheetState();
}

class _DeleteBottomSheetState extends State<DeleteBottomSheet> {
  late PublicationBloc _publicationBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _publicationBloc = context.read<PublicationBloc>();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<DeletePublicationBloc, DeletePublicationState>(
      builder: (context, state) {
        Widget content;

        if (state is DeletePublicationSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _publicationBloc.add(HidePublication(widget.publicationId));
            }
          });

          content = FeedbackContent(
            icon: Icons.check_circle_outline,
            color: Colors.green,
            title: "Post deleted",
            message: "The post was deleted successfully.",
            onClose: _close,
          );
        } else if (state is DeletePublicationFailure) {
          content = FeedbackContent(
            icon: Icons.cancel_outlined,
            color: Colors.red,
            title: "Failed to delete",
            message: state.error,
            onClose: _close,
          );
        } else {
          final isLoading = state is DeletePublicationLoading;

          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(
                Icons.delete_outline,
                color: theme.colorScheme.primary,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                "Delete post?",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to delete this post?\nThis action cannot be undone.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: "Confirm Delete",
                  isLoading: isLoading,
                  isEnabled: !isLoading,
                  onPressed: () {
                    context.read<DeletePublicationBloc>().add(
                      DeletePublicationRequest(
                        publicationId: widget.publicationId,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: content,
          ),
        );
      },
    );
  }
}
