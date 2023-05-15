import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../services/user_data_service.dart';

class ContactCard extends StatefulWidget {
  final PublicUser user;
  const ContactCard({super.key, required this.user});

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PublicUser user = widget.user;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xff1A1B1E),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(),
            title: Text(
              user.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(user.bio),
          ),
        ],
      ), //   },
    );
  }
}
