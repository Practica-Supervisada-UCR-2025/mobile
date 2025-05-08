import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: const _TopActions(),
      ),
      body: Column(
        children: [
          Expanded(
            child: _PostTextField(textController: _textController),
          ),
          const _BottomBar(),
        ],
      ),
    );
  }
}

class _TopActions extends StatelessWidget {
  const _TopActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // Action to post the content
          },
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Post',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        )
      ],
    );
  }
}

class _PostTextField extends StatelessWidget {
  final TextEditingController textController;

  const _PostTextField({required this.textController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: textController,
        maxLines: null,
        maxLength: 300,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'What’s on your mind?',
          border: InputBorder.none,
          counterText: '',
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: () {
              // Aquí luego iría el image_picker
            },
          ),
        ],
      ),
    );
  }
}
