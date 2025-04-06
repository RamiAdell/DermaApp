import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mydata extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var document = documents[index];
            return ListTile(
              title: Text(document['name']),
            );
          },
        );
      },
    );
  }
}