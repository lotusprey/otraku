import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/user_feed.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/activity_widgets.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';

class UserFeedPage extends StatelessWidget {
  static const ROUTE = '/activities';

  final int id;
  UserFeedPage(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Activities'),
      body: SafeArea(
        child: GetBuilder<UserFeed>(
          tag: id.toString(),
          builder: (feed) {
            if (feed.activities.isEmpty) {
              if (feed.hasNextPage) return const Center(child: Loader());

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
              controller: feed.scrollCtrl,
              itemBuilder: (_, i) => UserActivity(feed.activities[i]),
              itemCount: feed.activities.length,
            );
          },
        ),
      ),
    );
  }
}
