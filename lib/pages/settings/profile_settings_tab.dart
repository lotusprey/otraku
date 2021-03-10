import 'package:flutter/material.dart';
import 'package:otraku/utils/client.dart';

class ProfileSettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('Log Out'),
        onPressed: Client.logOut,
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).errorColor),
        ),
      ),
    );
  }
}
