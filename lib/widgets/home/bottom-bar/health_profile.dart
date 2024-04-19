import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pregathi/bottom-sheet/insta_share_bottom_sheet.dart';
import 'package:pregathi/const/constants.dart';
import 'package:pregathi/navigators.dart';
import 'package:sizer/sizer.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({Key? key}) : super(key: key);

  @override
  _HealthProfileScreenState createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final ref = FirebaseDatabase(
          databaseURL:
              "https://pregathi-69-default-rtdb.asia-southeast1.firebasedatabase.app")
      .ref('sensors');
  late String bpm;
  late String sValue;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _gestationalAgeController =
      TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _sympatheticCamController =
      TextEditingController();
  final TextEditingController _parasympatheticCamController =
      TextEditingController();
  bool isSaving = false;
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
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => goBack(context)),
        title: Text(
          'Health Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: primaryColor,
        actions: [
          TextButton(
            onPressed: () {
              _updateHealthProfile();
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return InstaShareBottomSheet();
              },
            );
          },
          backgroundColor: Colors.red,
          foregroundColor: boxColor,
          highlightElevation: 50,
          child: Icon(
            Icons.warning_outlined,
          ),
        ),
      ),
      body: isSaving
          ? progressIndicator(context)
          : SingleChildScrollView(
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
                      decoration: InputDecoration(labelText: 'Gestational Age (In weeks)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _bmiController,
                      decoration: InputDecoration(labelText: 'BMI'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _sympatheticCamController,
                      decoration: InputDecoration(
                          labelText: 'Sympathetic CAM (LF Form)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _parasympatheticCamController,
                      decoration: InputDecoration(
                          labelText: 'Parasympathetic CAM (HF Form)'),
                      keyboardType: TextInputType.number,
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
      setState(() {
        isSaving = true;
      });
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

      dialogueBoxWithButton(context, 'Health Profile updated successfully');

      setState(() {
        isSaving = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update health profile');
    }
  }
}
