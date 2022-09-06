import 'package:flutter/material.dart';

class GroupDetailsPage extends StatelessWidget {
  const GroupDetailsPage({Key? key, required this.groupName}) : super(key: key);
  final String groupName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          groupName,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.join_full),
        label: const Text("Join Group"),
        onPressed: () {},
      ),
    );
  }
}
