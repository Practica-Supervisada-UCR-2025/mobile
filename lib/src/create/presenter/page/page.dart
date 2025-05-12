import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/create/create.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _textController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleImageSelected(File? image) {
    setState(() {
      _selectedImage = image;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePostBloc(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const TopActions(),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PostTextField(textController: _textController),
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: PostImage(
                          image: _selectedImage,
                          onRemove: _removeImage,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            BottomBar(onImageSelected: _handleImageSelected),
          ],
        ),
      ),
    );
  }
}
