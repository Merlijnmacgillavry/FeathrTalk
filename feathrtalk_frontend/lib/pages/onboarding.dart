import 'dart:io';
import 'dart:async';
import 'package:feathrtalk_frontend/pages/chats.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  String profilePicture =
      "https://ik.imagekit.io/wajpf38jg/61091596-21e1-4139-967a-98e966c40a63_43JVBrx5G.jpg?updatedAt=1682415117624"; // Store the profile picture path or URL
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  // Function to handle profile picture change

  void _openImagePicker(ImageSource source) async {
    try {
      final pickedFile = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: false);
      setState(() {
        PlatformFile _imageFile = pickedFile!.files.first;
        print(_imageFile.path);
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _saveProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatsPage(name: _nameController.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                      radius: 100,
                      // child: ClipOval(
                      // backgroundImage: NetworkImage(profilePicture),
                      child: SizedBox(
                          width: 200,
                          height: 200,
                          child: ClipOval(child: Image.network(profilePicture)))

                      // ),
                      ),
                  // width: 100,
                  // child: Container(
                  //   decoration: BoxDecoration(
                  //     image: DecorationImage(
                  //         image: NetworkImage(profilePicture),
                  //         fit: BoxFit.cover),
                  //   ),
                  // ),

                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => _openImagePicker(ImageSource.gallery),
                    child: Text('Choose picture from Gallery'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your name',
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Divider(),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your bio',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Add logic for saving profile
                      _saveProfile();
                    },
                    child: Text('Save Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _imageFile;

  // Function to open the image picker
  void _openImagePicker(ImageSource source) async {
    try {
      final pickedFile = await FilePicker.platform.pickFiles();
      setState(() {
        PlatformFile _imageFile = pickedFile!.files.first;
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _openImagePicker(ImageSource.gallery),
          child: Text('Choose from Gallery'),
        ),
        ElevatedButton(
          onPressed: () => _openImagePicker(ImageSource.camera),
          child: Text('Take a Photo'),
        ),
        _imageFile != null
            ? Image.file(
                _imageFile!,
                height: 200,
                width: 200,
              )
            : Text('No Image Selected'),
      ],
    );
  }
}
