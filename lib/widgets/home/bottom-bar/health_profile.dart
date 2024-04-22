import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/navigators.dart';
import 'package:sizer/sizer.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({Key? key}) : super(key: key);

  @override
  _HealthProfileScreenState createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _gestationalAgeController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _sympatheticCamController = TextEditingController();
  final TextEditingController _parasympatheticCamController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _ageController.text = userData['age'];
        _gestationalAgeController.text = userData['gestationalAge'];
        _bmiController.text = userData['bmi'];
        _sympatheticCamController.text = userData['sympatheticCam'];
        _parasympatheticCamController.text = userData['parasympatheticCam'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _updateHealthProfile();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _gestationalAgeController,
                decoration: InputDecoration(labelText: 'Gestational Age'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _bmiController,
                decoration: InputDecoration(labelText: 'BMI'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _sympatheticCamController,
                decoration: InputDecoration(labelText: 'Sympathetic CAM (LF Form)'),
              ),
              TextFormField(
                controller: _parasympatheticCamController,
                decoration: InputDecoration(labelText: 'Parasympathetic CAM (HF Form)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateHealthProfile() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      // Update health profile information
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'age': _ageController.text,
        'gestationalAge': _gestationalAgeController.text,
        'bmi': _bmiController.text,
        'sympatheticCam': _sympatheticCamController.text,
        'parasympatheticCam': _parasympatheticCamController.text,
      });

      Fluttertoast.showToast(msg: 'Health profile updated successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update health profile');
    }
  }
}
