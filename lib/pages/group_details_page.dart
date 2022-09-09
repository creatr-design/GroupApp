// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupDetailsPage extends StatefulWidget {
  const GroupDetailsPage({
    Key? key,
    required this.groupName,
    required this.id,
  }) : super(key: key);
  final String groupName;
  final String id;

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  bool isMember = true;
  bool confirmed = false;
  @override
  Widget build(BuildContext context) {
    final subGroup = FirebaseFirestore.instance.collection('sub_groups').where(
          'parent_id',
          isEqualTo: widget.id,
        );

    Future<void> joinGroup() async {
      try {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.id)
            .update({
          "members": FieldValue.arrayUnion(
            [FirebaseAuth.instance.currentUser!.uid],
          )
        });
      } on FirebaseException {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Error joining group"),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    }

    Future<void> joinSubGroup(String subGroupId) async {
      try {
        await FirebaseFirestore.instance
            .collection('sub_groups')
            .doc(subGroupId)
            .update({
          "members": FieldValue.arrayUnion(
            [
              {
                "email": FirebaseAuth.instance.currentUser!.email,
                "uid": FirebaseAuth.instance.currentUser!.uid,
              }
            ],
          )
        }).whenComplete(() => Navigator.of(context).pop());
      } on FirebaseException {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Error joining sub group"),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.groupName,
        ),
      ),
      body: StreamBuilder(
          stream: subGroup.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final id = snapshot.data!.docs[index].id;
                  return ListTile(
                    title: Text('Group ${index + 1}'),
                    subtitle: Text("Join Group ${index + 1}"),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Do you want to join group ${index + 1}?",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    "Action cannot be undone",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: Theme.of(context).errorColor,
                                        ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    joinGroup();
                                    joinSubGroup(id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width * 0.8,
                                        40),
                                  ),
                                  child: const Text("Join"),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  height: 0,
                ),
              );
            } else if (snapshot.hasError) {
              return const Text("There was an error, try again later");
            } else {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.join_full),
        label: const Text("Join Group"),
        onPressed: () {},
      ),
    );
  }
}
