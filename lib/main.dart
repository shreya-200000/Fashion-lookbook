import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import 'package:logbook/firebase_options.dart';
import 'package:logbook/screens/product_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //populateMedia();
  runApp(MyApp());
}

Future<void> populateMedia() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference collection = firestore.collection('fashionItems');

  QuerySnapshot querySnapshot = await collection.get();

  List<String> ids = querySnapshot.docs.map((doc) => doc.id).toList();
  print(ids);
  for (int i = 0; i < ids.length; i++) {
    for (int j = 0; j < 3; j++) {
      await collection.doc(ids[i]).collection("media").add({
        "file_url": "https://picsum.photos/300",
        "file_type": "image",
      });
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ecom App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: ProductListPage(),
      // home: LoginPage(),
    );
  }
}
