import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/helpers/graph_ql.dart';
import 'package:otraku/tools/activity_widgets.dart';
import 'package:otraku/tools/loader.dart';
import 'package:otraku/tools/navigation/custom_app_bar.dart';

class UserActivitiesPage extends StatelessWidget {
  static const ROUTE = '/activities';

  final int id;
  UserActivitiesPage(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Activities'),
      body: SafeArea(
        child: GetBuilder<User>(
          tag: id?.toString() ?? GraphQL.viewerId.toString(),
          builder: (user) {
            if (user.activities.isEmpty) {
              user.fetchActivities();
              if (user.loading) return Center(child: Loader());
              return Center(
                child: Text(
                  'No Activities',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              );
            }

            return ListView.builder(
              physics: Config.PHYSICS,
              padding: Config.PADDING,
              itemBuilder: (_, i) {
                if (i == user.activities.length - 5) user.fetchActivities();
                return UserActivity(user.activities[i]);
              },
              itemCount: user.activities.length,
            );
          },
        ),
      ),
    );
  }
}
