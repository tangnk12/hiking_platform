import 'package:flutter/material.dart';
import 'package:hiking_platform/Home/search_group_list/data.dart';
import 'package:postgres/postgres.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../../Home/home_page.dart';
import '../../query.dart';
import '../create_group/data.dart';

class EditGroup extends StatefulWidget {
  final PostgreSQLConnection connection;
  final User currUser;
  final InfoItem selectedGroup;

  EditGroup(
      {Key? key,
      required this.connection,
      required this.currUser,
      required this.selectedGroup})
      : super(key: key);

  @override
  _GroupCreatePage createState() => _GroupCreatePage();
}

File? groupImageChoose;

class _GroupCreatePage extends State<EditGroup> {
  final _formKey = GlobalKey<FormState>();
  late String _groupName;
  late Group createGroup;
  late String _groupDescription;
  late Uint8List? previewGroupImage;
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

  void saveEditGroupToDatabase() async {
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
        if (existingGroups.isNotEmpty &&
            existingGroups[0].id == widget.selectedGroup.id) {
          await widget.connection.query(
            'UPDATE "group" SET description = @description, group_image = @groupImage WHERE group_id = @groupId',
            substitutionValues: {
              'groupId': widget.selectedGroup.id,
              'groupImage': groupPicture,
              'description': _groupDescription,
            },
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Group $_groupName information successfully changed'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Group $_groupName unexpected error'),
            ),
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
  void initState() {
    super.initState();

    // Initialize the values with activityData
    _groupName = widget.selectedGroup.groupName;
    _groupDescription = widget.selectedGroup.description;
    previewGroupImage = widget.selectedGroup.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Group :' + widget.selectedGroup.groupName),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Group Description'),
                initialValue: widget.selectedGroup.description,
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
                onPressed: saveEditGroupToDatabase,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
