import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/create/presenter/bloc/bloc.dart';
import 'widgets.dart';

class TopActions extends StatelessWidget {
  const TopActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            final bloc = context.read<CreatePostBloc>();
            final state = bloc.state;

            final hasContent =
                state.text.isNotEmpty ||
                state.image != null ||
                state.selectedGif != null;

            if (hasContent) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return const CancelBottomSheet();
                },
              );
            } else {
              context.pop();
            }
          },
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        BlocConsumer<CreatePostBloc, CreatePostState>(
          listener: (context, state) {
            if (state is PostSubmitFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'There was an error creating the post. Please try again.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is PostSubmitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post successfully created!'),
                  backgroundColor: Colors.green,
                ),
              );

              Future.delayed(const Duration(milliseconds: 300), () {
                if (context.mounted) {
                  context.go(
                    Paths.profile,
                    extra: {'refresh': DateTime.now().millisecondsSinceEpoch},
                  );
                }
              });
            }
          },
          builder: (context, state) {
            if (state is PostSubmitting) {
              return const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              );
            }

            final isEnabled = state.isValid;

            return TextButton(
              onPressed:
                  isEnabled
                      ? () {
                        final bloc = context.read<CreatePostBloc>();
                        bloc.add(
                          PostSubmitted(
                            text: state.text,
                            image: state.image,
                            selectedGif: state.selectedGif,
                          ),
                        );
                      }
                      : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    isEnabled
                        ? AppColors.primary
                        : AppColors.getDisabledPostButtonColor(
                          Theme.of(context).brightness,
                        ),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Post',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            );
          },
        ),
      ],
    );
  }
}
