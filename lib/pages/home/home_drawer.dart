import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: [
          Container(
            height: 160,
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 60.0,
                      color: Colors.black12,
                    ),
                    SizedBox(width: 15),
                    Container(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kenny',
                            style: TextStyle(fontSize: 20),
                            overflow: TextOverflow.clip,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'View Profile',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.card_giftcard_outlined),
            title: Text('Free Rides'),
          ),
          ListTile(
            leading: Icon(Icons.credit_card_outlined),
            title: Text(
              'Payments',
            ),
          ),
          ListTile(
            leading: Icon(Icons.history_outlined),
            title: Text('Ride History'),
          ),
          ListTile(
            leading: Icon(Icons.contact_support_outlined),
            title: Text(
              'Support',
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(
              'About',
            ),
          ),
        ],
      ),
    );
  }
}
