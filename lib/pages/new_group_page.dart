import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:group_app/pages/my_own_home.dart';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({Key? key}) : super(key: key);

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  final _formKey = GlobalKey<FormState>();
  OutlineInputBorder enableBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.white),
    borderRadius: BorderRadius.circular(12),
  );

  OutlineInputBorder focusBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.deepPurple),
    borderRadius: BorderRadius.circular(12),
  );
  OutlineInputBorder errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.red),
    borderRadius: BorderRadius.circular(12),
  );
  TextEditingController groupNameController = TextEditingController();
  TextEditingController totalPeopleController = TextEditingController();
  TextEditingController peoplerPerGroupController = TextEditingController();

  Future<void> createNewGroup() async {
    try {
      FirebaseFirestore.instance.collection('groups').add({
        "group_name": groupNameController.text,
        "division": int.parse(peoplerPerGroupController.text),
        "max_count": int.parse(totalPeopleController.text),
        "sub_groups": [],
      }).whenComplete(
        () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomeWidget()),
        ),
      );
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error creating group'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Group"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        physics: const BouncingScrollPhysics(),
        children: [
          SvgPicture.asset(
            'assets/update.svg',
            width: 250,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 30),
            child: Text(
              "It's as easy as it looks. Get started by letting us know your needs",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: groupNameController,
                  maxLength: 40,
                  decoration: InputDecoration(
                    enabledBorder: enableBorder,
                    focusedBorder: focusBorder,
                    errorBorder: errorBorder,
                    hintText: "Group Name",
                    fillColor: Colors.grey[200],
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter group name';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: TextFormField(
                    maxLength: 4,
                    controller: totalPeopleController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      enabledBorder: enableBorder,
                      focusedBorder: focusBorder,
                      errorBorder: errorBorder,
                      hintText: "total Number of people",
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the total number of people';
                      }
                      return null;
                    },
                  ),
                ),
                TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 2,
                  controller: peoplerPerGroupController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    enabledBorder: enableBorder,
                    focusedBorder: focusBorder,
                    errorBorder: errorBorder,
                    hintText: "People per group",
                    fillColor: Colors.grey[200],
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the divisions you want to have';
                    }
                    if (int.parse(totalPeopleController.text) %
                            int.parse(peoplerPerGroupController.text) >
                        int.parse(peoplerPerGroupController.text)) {
                      return 'Invalid peopler per group division';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        createNewGroup();
                      }
                    },
                    icon: const Icon(Icons.check_box),
                    label: const Text("Submit"),
                    style: ElevatedButton.styleFrom(
                      fixedSize:
                          Size.fromWidth(MediaQuery.of(context).size.width),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
