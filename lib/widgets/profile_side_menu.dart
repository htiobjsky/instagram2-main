import 'package:flutter/material.dart';
import 'package:instagram_two_record/models/firebase_auth_state.dart';
import 'package:instagram_two_record/screens/auth_screen.dart';
import 'package:provider/provider.dart';

class ProfileSideMenu extends StatelessWidget {
  final double menuWidth;

  const ProfileSideMenu(
    this.menuWidth, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: menuWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Setting',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.black87),
              title: Text("Sign out"),
              onTap: () {
                // Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(builder: (context) => AuthScreen()),);
                Provider.of<FirebaseAuthState>(context, listen: false)
                    .signOut();
              },
            )
          ],
        ),
      ),
    );
  }
}
