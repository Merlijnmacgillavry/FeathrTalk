import 'dart:io';
import 'dart:async';
import 'package:feathrtalk_frontend/models/user_credentials.dart';
import 'package:feathrtalk_frontend/services/user_data_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/websocket_provider.dart';
import 'home.dart';

class Onboarding extends StatefulWidget {
  final UserCredentials uc;
  const Onboarding({required this.uc, Key? key}) : super(key: key);

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

  void _saveProfile(PublicUser publicUser, UserCredentials uc) {
    print(publicUser.toJson());
    print(uc.email);
    context.read<AuthProvider>().addUser(publicUser, uc).then((value) {
      context.read<WebsocketProvider>().connectToWebSocket();
      context.read<NotificationProvider>().alert(
          "Successfully logged in! With accessToken: ${value.tokens.accessToken} and refreshToken${value.tokens.refreshToken} and id${value.id} ");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }).catchError((e) {
      context.read<NotificationProvider>().alert('error');

      context.read<NotificationProvider>().alert(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    String _bio = "";
    String _profileImage = "";
    String _name = "";

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // return Scaffold(
    //   // appBar: AppBar(
    //   //   title: Text('Flutter Chat App'),
    //   // ),
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         TextField(
    //           controller: _emailController,
    //           decoration: InputDecoration(
    //             border: OutlineInputBorder(),
    //             labelText: 'Enter your name',
    //           ),
    //         ),
    //         SizedBox(height: 20),
    //         TextField(
    //           controller: _passwordController,
    //           obscureText: !_passwordVisible,
    //           decoration: InputDecoration(
    //             border: OutlineInputBorder(),
    //             labelText: 'Enter your password',
    //             suffixIcon: IconButton(
    //               icon: Icon(
    //                 _passwordVisible ? Icons.visibility_off : Icons.visibility,
    //               ),
    //               onPressed: _togglePasswordVisibility,
    //             ),
    //           ),
    //         ),
    //         SizedBox(height: 20),
    //         ElevatedButton(
    //           onPressed: () => _onLoginButtonPressed(context),
    //           child: Text('Login'),
    //         ),
    //         NotificationWidget(),
    //       ],
    //     ),
    //   ),
    // );
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xff47C8FF),
            Color(0xff9747FF),
          ],
        )
            // repeat: ImageRepeat.repeat,
            ),
        child: Form(
          key: _formKey,
          child: Center(
            child: Card(
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(32.0),
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Create a profile",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      _gap(),
                      Image.asset(
                        "lib/assets/Rectangle 2.png",
                        height: 100,
                      ),
                      _gap(),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Enter a username and a small bio to create a profile.",
                          style: Theme.of(context).textTheme.caption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        validator: (value) {
                          // add email validation
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }

                          setState(() {
                            _name = value;
                          });
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'Pick a nice username',
                          prefixIcon: Icon(Icons.account_box_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }

                          setState(() {
                            _bio = value;
                          });
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          hintText: 'Share some things about yourself',
                          prefixIcon: const Icon(Icons.info_rounded),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1A1B1E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'Create Profile',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              /// do something
                              UserCredentials uc = widget.uc;
                              PublicUser publicUser = PublicUser(
                                  id: "",
                                  name: _name,
                                  bio: _bio,
                                  profileImage: "x");
                              // _onLoginButtonPressed(uc);
                              _saveProfile(publicUser, uc);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // return Scaffold(
    //   body: Center(
    //     child: Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Card(
    //         elevation: 8.0,
    //         child: Padding(
    //           padding: const EdgeInsets.all(16.0),
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             crossAxisAlignment: CrossAxisAlignment.stretch,
    //             children: [
    //               // CircleAvatar(
    //               // radius: 100,
    //               // // child: ClipOval(
    //               // // backgroundImage: NetworkImage(profilePicture),
    //               // child: SizedBox(
    //               //     width: 200,
    //               //     height: 200,
    //               //     child: ClipOval(child: Image.network(profilePicture)))

    //               // // ),
    //               // ),
    //               // width: 100,
    //               // child: Container(
    //               //   decoration: BoxDecoration(
    //               //     image: DecorationImage(
    //               //         image: NetworkImage(profilePicture),
    //               //         fit: BoxFit.cover),
    //               //   ),
    //               // ),

    //               const SizedBox(height: 16.0),
    //               ElevatedButton(
    //                 onPressed: () => _openImagePicker(ImageSource.gallery),
    //                 child: Text('Choose picture from Gallery'),
    //               ),
    //               const SizedBox(height: 16.0),
    //               TextField(
    //                 controller: _nameController,
    //                 decoration: InputDecoration(
    //                   border: OutlineInputBorder(),
    //                   labelText: 'Enter your name',
    //                 ),
    //               ),
    //               const SizedBox(height: 8.0),
    //               Divider(),
    //               const SizedBox(height: 8.0),
    //               TextField(
    //                 controller: _bioController,
    //                 decoration: InputDecoration(
    //                   border: OutlineInputBorder(),
    //                   labelText: 'Enter your bio',
    //                 ),
    //                 textAlign: TextAlign.center,
    //               ),
    //               const SizedBox(height: 16.0),
    //               ElevatedButton(
    //                 onPressed: () {
    //                   // Add logic for saving profile
    //                   _saveProfile();
    //                 },
    //                 child: Text('Save Profile'),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _gap() => const SizedBox(height: 16);
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
