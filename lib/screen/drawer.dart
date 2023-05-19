import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_tangotyo/screen/tangotyo/acount_screens/login.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_books_list/vocabulary_books_list.dart';

class DrawerW extends StatefulWidget {
  const DrawerW({Key? key}) : super(key: key);

  @override
  State<DrawerW> createState() => _DrawerWState();
}

class _DrawerWState extends State<DrawerW> {
  List menu = [
    [Icons.home, "Home", const VocabularyBooksList()],
  ];
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Menu",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.white),
              ),
            ),
          ),
          for (int i = 0; i < menu.length; i++) ...{
            ListTile(
              title: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return menu[i][2];
                    }),
                  );
                },
                child: Row(children: [
                  Icon(menu[i][0]),
                  Text(menu[i][1]),
                ]),
              ),
            )
          },
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return LogInPage();
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
