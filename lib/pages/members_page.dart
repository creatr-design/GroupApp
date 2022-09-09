import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    final allMembers = FirebaseFirestore.instance
        .collection('sub_groups')
        .where(
          'parent_id',
          isEqualTo: id,
        )
        .where(
      'members',
      arrayContains: {
        "uid": FirebaseAuth.instance.currentUser!.uid,
        "email": FirebaseAuth.instance.currentUser!.email
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Members"),
      ),
      body: StreamBuilder(
        stream: allMembers.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              padding: const EdgeInsets.all(14),
              itemBuilder: (context, index) {
                final members = snapshot.data!.docs[index]['members'] as List;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    members.length,
                    (index) => Text(
                      members[index]['email'],
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                height: 0,
              ),
              itemCount: snapshot.data!.docs.length,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
        },
      ),
    );
  }
}
