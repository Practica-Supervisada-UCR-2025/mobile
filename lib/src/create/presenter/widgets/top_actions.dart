import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/src/create/presenter/bloc/bloc.dart';

class TopActions extends StatelessWidget {
  const TopActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();

            Future.delayed(Duration(milliseconds: 150), () {
              if (context.mounted) {
                context.pop();
              }
            });
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
        const Spacer(),
        BlocConsumer<CreatePostBloc, CreatePostState>(
          listener: (context, state) {
            if (state is PostSubmitFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('There was an error creating the post. Please try again.'),
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
                  context.pop();
                }
              });
            }
          },
          builder: (context, state) {
            if (state is PostSubmitting) {
              return const CircularProgressIndicator();
            }
            
            final isEnabled = state.isValid;

            return TextButton(
              onPressed: isEnabled ? () {
                final bloc = context.read<CreatePostBloc>();
                bloc.add(PostSubmitted(
                  text: state.text,
                  image: state.image,
                  selectedGif: state.selectedGif,
                ));
              } : null,
              style: TextButton.styleFrom(
                backgroundColor: isEnabled ? AppColors.primary 
                : AppColors.getDisabledPostButtonColor(Theme.of(context).brightness),
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
