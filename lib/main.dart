import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String input = "";

  createToDo()
  {
    DocumentReference documentReference = FirebaseFirestore.instance.collection("MyToDo").doc();
    Map<String, String> todomap = {
      "todotitle":input
    };
    documentReference.set(todomap).whenComplete((){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$input Created'),
      ));
    }).onError((error, stackTrace){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error : $error'),
      ));
    });
  }

  deleteToDo(item)
  {
    DocumentReference documentReference = FirebaseFirestore.instance.collection("MyToDo").doc(item);
    documentReference.delete().whenComplete((){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Deleted!"),
      ));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My To Do List"),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        showDialog(context: context, builder:
        (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: 
            BorderRadius.circular(8)),
            title: const Text("Add To Do List"),
            content: TextField(
            onChanged: (String value){
              input = value;
            },
            ),
            actions: <Widget>
            [
              FlatButton(onPressed: (){
                setState(() {
                  createToDo();
                });
                Navigator.of(context).pop();
              }, child: const Text("Add"))
            ],
          );
        });
      }, child: const Icon(
        Icons.add,
        color: Colors.white,
      ),),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('MyToDo').snapshots(),
          builder: (context, snapshot) {
          return ListView.builder(
            shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index ) {
                DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
                return Dismissible(
                    onDismissed: (direction){
                    deleteToDo(documentSnapshot.id);
                    },
                    key: Key(index.toString()),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        child: ListTile(
                          title: Text(
                            documentSnapshot.get("todotitle").toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20),),
                          trailing: IconButton(onPressed: (){
                            setState(() {
                              deleteToDo(documentSnapshot.id);
                            });
                          }, icon: const Icon(
                            Icons.delete,
                            color : Colors.red,
                          )),
                        ),
                      ),
                    ));
              });
          }),
    );
  }
}

