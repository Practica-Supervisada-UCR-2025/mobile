import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/create/create.dart';

class CreatePageController {
  final CreatePostBloc bloc;
  File? selectedImage;
  final Function(File?) onImageChanged;
  
  CreatePageController({
    required this.bloc,
    required this.onImageChanged,
  });
  
  void handleImageSelected(File? image) {
    selectedImage = image;
    bloc.add(PostImageChanged(image));
    onImageChanged(image);
  }
  
  void removeImage() {
    selectedImage = null;
    bloc.add(const PostImageChanged(null));
    onImageChanged(null);
  }
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _textController = TextEditingController();
  File? _selectedImage;
  final _bloc = CreatePostBloc();
  late final CreatePageController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = CreatePageController(
      bloc: _bloc,
      onImageChanged: (image) {
        setState(() {
          _selectedImage = image;
        });
      },
    );
    
    _textController.addListener(() {
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const TopActions(),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
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
                            key: ValueKey<String>(_selectedImage?.path ?? ''),
                            image: _selectedImage,
                            onRemove: _controller.removeImage,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              BlocSelector<CreatePostBloc, CreatePostState, int>(
                selector: (state) => state.text.length,
                builder: (context, textLength) {
                  return BottomBar(onImageSelected: _controller.handleImageSelected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
