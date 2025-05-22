import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/create/create.dart';

class CreatePageController {
  final CreatePostBloc bloc;
  final Function(File?) onImageSelectedByPicker; 

  CreatePageController({
    required this.bloc,
    required this.onImageSelectedByPicker,
  });

  void handleImagePicked(File? image) {
    bloc.add(PostImageChanged(image));
  }

  void removeImage() {
    bloc.add(const PostImageChanged(null));
  }
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _textController = TextEditingController();
  File? _selectedImageFromPage;
  final _bloc = CreatePostBloc();
  StreamSubscription<CreatePostState>? _blocStateSubscription;

  @override
  void initState() {
    super.initState();
    _blocStateSubscription = _bloc.stream.listen((newState) {
      if (mounted) {
        if (_selectedImageFromPage?.path != newState.image?.path) {
          setState(() {
            _selectedImageFromPage = newState.image;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _blocStateSubscription?.cancel();
    _bloc.close();
    super.dispose();
  }

  void _onImageSelectedFromPicker(File? imageFile) {
    _bloc.add(PostImageChanged(imageFile));
  }

  void _onRemoveImageFromPostWidget() {
    _bloc.add(const PostImageChanged(null));
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

                      if (_selectedImageFromPage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: PostImage(
                            key: ValueKey<String>(_selectedImageFromPage!.path),
                            image: _selectedImageFromPage,
                            onRemove: _onRemoveImageFromPostWidget,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              BottomBar(onImageSelected: _onImageSelectedFromPicker),
            ],
          ),
        ),
      ),
    );
  }
}