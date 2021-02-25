import 'package:flutter/material.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/helpers/client.dart';

class ProfileSettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        padding: Config.PADDING,
        shape: const RoundedRectangleBorder(
          borderRadius: Config.BORDER_RADIUS,
        ),
        color: Theme.of(context).errorColor,
        child: Text('Log Out', style: Theme.of(context).textTheme.button),
        onPressed: Client.logOut,
      ),
    );
  }
}
