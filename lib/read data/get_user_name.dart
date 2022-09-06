import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetUserName extends StatelessWidget {
  final String documentId;

  const GetUserName({required this.documentId});

  @override
  Widget build(BuildContext context) {
    //get collection
    CollectionReference people =
        FirebaseFirestore.instance.collection('people');

    return FutureBuilder<DocumentSnapshot>(
        future: people.doc(documentId).get(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Text('${data['first name']} ${data['last name']}');
          }
          return const Text('loading...');
        }));
  }
}
