import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_app/pages/group_details_page.dart';
import 'package:group_app/pages/members_page.dart';
import 'package:group_app/pages/new_group_page.dart';

class MyHomeWidget extends StatefulWidget {
  const MyHomeWidget({Key? key}) : super(key: key);

  @override
  State<MyHomeWidget> createState() => _MyHomeWidgetState();
}

class _MyHomeWidgetState extends State<MyHomeWidget> {
  final groupsCollection = FirebaseFirestore.instance.collection('groups');
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Group Creator"),
        actions: [
          IconButton(
            splashRadius: 22,
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout_outlined,
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: groupsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return GridView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: orientation == Orientation.landscape ? 3 : 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final groupData = snapshot.data!.docs[index];
                final String groupName = groupData['group_name'];
                final int maxCount = groupData['max_count'];
                final List members = groupData['members'];
                bool isMember =
                    members.contains(FirebaseAuth.instance.currentUser!.uid);
                return isMember
                    ? Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                groupName,
                                style: Theme.of(context).textTheme.headline6,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: SizedBox(
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          MembersPage(id: groupData.id),
                                    ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const Text("Already a member"),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GroupDetailsPage(
                                groupName: groupName,
                                id: groupData.id,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  groupName,
                                  style: Theme.of(context).textTheme.headline6,
                                  textAlign: TextAlign.center,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(
                                      Icons.people_alt,
                                      color: Colors.blueGrey,
                                      size: 35,
                                    ),
                                    Text(
                                      '$maxCount',
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
              },
            );
          } else if (snapshot.hasError) {
            return const Text("There was an error fetching groups");
          } else {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.note_add_outlined),
        label: const Text("New Group"),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewGroupPage(),
            ),
          );
        },
      ),
    );
  }
}
