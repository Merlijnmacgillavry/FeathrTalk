import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tabs/chats.dart';
import '../tabs/contacts.dart';
import '../tabs/group_chats.dart';

class HomePage extends StatelessWidget {
  final _groupsKey = GlobalKey<NavigatorState>();
  final _chatsKey = GlobalKey<NavigatorState>();
  final _contactsKey = GlobalKey<NavigatorState>();
  final _profileKey = GlobalKey<NavigatorState>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return new WillPopScope(
      onWillPop: () async => false,
      child: PersistentBottomBarScaffold(
        items: [
          PersistentTabItem(
            tab: const GroupChats(),
            icon: Icons.group,
            title: 'Groups',
            navigatorkey: _groupsKey,
          ),
          PersistentTabItem(
            tab: const Chats(),
            icon: Icons.chat,
            title: 'Chats',
            navigatorkey: _chatsKey,
          ),
          PersistentTabItem(
            tab: const Contacts(),
            icon: Icons.contacts,
            title: 'Contacts',
            navigatorkey: _contactsKey,
          ),
        ],
      ),
    );
  }
}

class PersistentTabItem {
  final Widget tab;
  final GlobalKey<NavigatorState>? navigatorkey;
  final String title;
  final IconData icon;

  PersistentTabItem(
      {required this.tab,
      this.navigatorkey,
      required this.title,
      required this.icon});
}

class PersistentBottomBarScaffold extends StatefulWidget {
  /// pass the required items for the tabs and BottomNavigationBar
  final List<PersistentTabItem> items;

  const PersistentBottomBarScaffold({Key? key, required this.items})
      : super(key: key);

  @override
  State<PersistentBottomBarScaffold> createState() =>
      _PersistentBottomBarScaffoldState();
}

class _PersistentBottomBarScaffoldState
    extends State<PersistentBottomBarScaffold> {
  int _selectedTab = 0;
  bool _updatingTab = false;
  void nextTab() {
    if (!_updatingTab) {
      _updatingTab = true;
      setState(() {
        if (_selectedTab + 1 == widget.items.length) {
          _selectedTab = 0;
        } else {
          _selectedTab++;
        }
      });
    }
  }

  void previousTab() {
    if (!_updatingTab) {
      _updatingTab = true;
      setState(() {
        if (_selectedTab == 0) {
          _selectedTab = widget.items.length - 1;
        } else {
          _selectedTab--;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        /// Check if curent tab can be popped
        if (widget.items[_selectedTab].navigatorkey?.currentState?.canPop() ??
            false) {
          widget.items[_selectedTab].navigatorkey?.currentState?.pop();
          return false;
        } else {
          // if current tab can't be popped then use the root navigator
          return true;
        }
      },
      child: Scaffold(
        /// Using indexedStack to maintain the order of the tabs and the state of the
        /// previously opened tab
        body: SizedBox.expand(
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              // print(details.delta.direction)

              // Swiping in left direction.
              if (details.delta.dx < -10) {
                nextTab();
              }
              if (details.delta.dx > 10) {
                previousTab();
              }
            },
            onHorizontalDragEnd: (details) => {_updatingTab = false},
            // onPanUpdate: (details) {
            //   // Swiping in right direction.
            // },
            child: IndexedStack(
              index: _selectedTab,
              children: widget.items
                  .map((page) => Navigator(
                        /// Each tab is wrapped in a Navigator so that naigation in
                        /// one tab can be independent of the other tabs
                        key: page.navigatorkey,
                        onGenerateInitialRoutes: (navigator, initialRoute) {
                          return [
                            MaterialPageRoute(builder: (context) => page.tab)
                          ];
                        },
                      ))
                  .toList(),

              /// Define the persistent bottom bar
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xff1A1B1E),
          currentIndex: _selectedTab,
          onTap: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
          items: widget.items
              .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: ShaderMask(
                    shaderCallback: (Rect bounds) => LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xff47C8FF),
                        Color(0xff9747FF),
                      ],
                    ).createShader(bounds),
                    child: Icon(
                      item.icon,
                    ),
                  ),
                  label: item.title))
              .toList(),
        ),
      ),
    );
  }
}
