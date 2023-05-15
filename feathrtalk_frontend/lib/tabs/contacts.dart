import 'package:feathrtalk_frontend/widgets/add_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import '../providers/websocket_provider.dart';
import '../services/user_data_service.dart';
import '../widgets/contact_card.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  bool _isSearching = false;
  bool _isAdding = false;
  @override
  Widget build(BuildContext context) {
    final websocketProvider = Provider.of<WebsocketProvider>(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Color(0xff1A1B1E),
          actions: [
            Offstage(
              offstage: !_isSearching,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                child: SizedBox(
                  height: 20,
                  width: size.width * 0.4,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                    ),
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: IconButton(
                  icon: _isSearching
                      ? Icon(Icons.close)
                      : Icon(
                          Icons.search,
                          size: 30,
                        ),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      _isAdding = false;
                    });
                  }),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: IconButton(
                  icon: Icon(
                    Icons.person_add,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddContactPage()),
                      );
                    });
                  }),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: Icon(
                Icons.more_vert,
                size: 30.0,
              ),
            ),
          ],
          title: Text(
            'Contacts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
              foreground: Paint()
                ..shader = LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xff47C8FF),
                    Color(0xff9747FF),
                  ],
                ).createShader(
                  Rect.fromLTWH(0.0, 0.0, 200.0, 100.0),
                ),
            ),
          ),
        ),
      ),
      body: Container(
        // width: double.infinity,
        // height: double.infinity,
        // color: Colors.red,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xff47C8FF),
            Color(0xff9747FF),
          ],
        )
            // repeat: ImageRepeat.repeat,
            ),

        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount:
                    websocketProvider.userDataService.contacts.keys.length,
                itemBuilder: (context, index) {
                  // bool _isOnline = websocketProvider.onlineUsers.contains(element)
                  String key = websocketProvider.userDataService.contacts.keys
                      .toList()[index];
                  PublicUser user =
                      websocketProvider.userDataService.contacts[key]!;
                  return ContactCard(
                    user: user,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
