import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:hiking_platform/group_info/join_group/data.dart';
import 'package:postgres/postgres.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../../Home/home_page.dart';
import '../../query.dart';
import 'data.dart';

class CreateGroup extends StatefulWidget {
  final PostgreSQLConnection connection;
  final User currUser;

  CreateGroup({
    Key? key,
    required this.connection,
    required this.currUser,
  }) : super(key: key);

  @override
  _GroupCreatePage createState() => _GroupCreatePage();
}

File? groupImageChoose;

Uint8List? previewGroupImage = null;

class _GroupCreatePage extends State<CreateGroup> {
  final _formKey = GlobalKey<FormState>();
  late String _groupName;
  late Group createGroup;
  late String _groupDescription;
  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      groupImageChoose = File(pickedImage.path);
      final bytes = await groupImageChoose!.readAsBytes();
      setState(() {
        previewGroupImage = bytes;
      });
    }
  }

  void saveGroupToDatabase() async {
    String? groupPicture;
    if (previewGroupImage != null) {
      groupPicture = base64Encode(previewGroupImage!);
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        var existingGroups = await getGroupsByNameAndCreator(
          widget.currUser.userId,
          _groupName,
          widget.connection,
        );
        if (existingGroups.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Group $_groupName already exists")),
          );
        } else {
          await widget.connection.query(
            "INSERT INTO \"group\" (group_name, creator_id, group_image, description) VALUES (@groupName, @creatorId, @groupImage, @description)",
            substitutionValues: {
              'groupName': _groupName,
              'creatorId': widget.currUser.userId,
              'groupImage': groupPicture,
              'description': _groupDescription,
            },
          );
          createGroup = await getCreateGroup(
            widget.currUser.userId,
            _groupName,
            widget.connection,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Group $_groupName registered successfully'),
            ),
          );

          joinGroup(
            widget.currUser.userId,
            createGroup.id,
            widget.connection,
            true,
            'creator',
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
        print(e.toString());
      }

      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            user: widget.currUser,
            connection: widget.connection,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
                onSaved: (value) => _groupName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Group Description'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter description to introduce the  group';
                  }
                  return null;
                },
                onSaved: (value) => _groupDescription = value!,
              ),

              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Group Image'),
              ),
              //After pick,preview the image
              Column(
                children: [
                  SizedBox(height: 10),
                  if (previewGroupImage != null)
                    Image.memory(
                      previewGroupImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              ElevatedButton(
                onPressed: saveGroupToDatabase,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
