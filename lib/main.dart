import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "firebase_options.dart";
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'prototype',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = PicturePage(
          category: 'childhood',
          imgName: 'c',
          length: 2,
        );
        break;
      case 1:
        page = PicturePage(
          category: 'food',
          imgName: 'f',
          length: 2,
        );
        break;
      case 2:
        page = PicturePage(
          category: 'art',
          imgName: 'a',
          length: 3,
        );
        break;
      case 3:
        page = PicturePage(
          category: 'house',
          imgName: 'h',
          length: 1,
        );
        break;
      case 4:
        page = Stats();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 400,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.add_reaction_outlined),
                    label: Text('My Childhood'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.fastfood_outlined),
                    label: Text('Food'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.wallpaper_outlined),
                    label: Text('Art'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.house_outlined),
                    label: Text('Household Items'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_customize_outlined),
                    label: Text('Stats'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: page, // ← Here.
              ),
            ),
          ],
        ),
      );
    });
  }
}

class PicturePage extends StatelessWidget {
  final String imgName;
  final String category;
  final int length;
  PicturePage(
      {required this.imgName, required this.category, required this.length});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.all(50),
              child: MyImageWidget(
                category: category,
                imgName: imgName + (++index).toString(),
              ),
            ),
          ],
        );
      },
    );
  }
}

Reference firestorage = FirebaseStorage.instance.ref();

Future<String> getImage(String imgName) async {
  var urlRef = firestorage.child('$imgName.jpg');
  var imgUrl = await urlRef.getDownloadURL();
  return imgUrl;
}

Future<int> getDataLength(category) async {
  CollectionReference collectionRef =
      FirebaseFirestore.instance.collection(category);
  QuerySnapshot querySnapshot = await collectionRef.get();
  final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

  print(allData);
  return allData.length;
}

class MyImageWidget extends StatelessWidget {
  final String imgName;
  final String category;

  MyImageWidget({required this.category, required this.imgName});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FutureBuilder(
        future: getImage(imgName),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return CachedNetworkImage(
            imageUrl: snapshot.data!,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          );
        },
      ),
      Container(
        margin: const EdgeInsets.only(top: 10.0),
        height: 25,
        child: FloatingActionButton(
          onPressed: () => onPressed(category, imgName),
          tooltip: 'like',
          backgroundColor: Colors.pink[100],
          child: const Icon(Icons.favorite_border),
        ),
      ),
    ]);
  }
}

void onPressed(String category, String imgName) async {
  DocumentReference docRef =
      FirebaseFirestore.instance.collection(category).doc(imgName);
  DocumentSnapshot<Object?> docSnapshot = await docRef.get();

  var temp = docSnapshot.data() as Map;
  var click = temp['click'];
  print(temp);
  print(temp['click']);

  docRef.update({'click': click + 1});
}

class Stats extends StatelessWidget {
  var collectionList = ['childhood', 'food', 'art', 'house'];
  var ret = [];
  Future<String> getStats() async {
    for (var element in collectionList) {
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection(element);

      QuerySnapshot querySnapshot = await collectionRef.get();
      var key, temp, clicks;
      collectionRef.get().then(
        (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            temp = '';
            key = '';
            temp = docSnapshot.data();
            key = temp['name'];
            clicks = temp['click'];
            if (key != null) {
              ret.add('Picture $key clicked $clicks times');
              print('Picture $key clicked $clicks times');
            } else {
              print('Picture $key clicked $clicks times');
            }
          }
        },
        onError: (e) => print("Error completing: $e"),
      );
    }

    return ret.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Picture Stats'),
        ),
        body: FutureBuilder(
          builder: (ctx, snapshot) {
            // Checking if future is resolved or not
            if (snapshot.connectionState == ConnectionState.done) {
              // If we got an error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                // Extracting data from snapshot object
                final data = snapshot.data as String;
                return Center(
                  child: Text(
                    data,
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
          future: getStats(),
        ),
      ),
    );
  }
}
