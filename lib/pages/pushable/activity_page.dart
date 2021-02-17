import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/activity.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/activity_widgets.dart';
import 'package:otraku/tools/navigation/custom_app_bar.dart';

class ActivityPage extends StatelessWidget {
  static const ROUTE = '/activity';

  final int id;
  ActivityPage(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        bottom: false,
        child: GetBuilder<Activity>(
          tag: id.toString(),
          builder: (activity) => ListView.builder(
            physics: Config.PHYSICS,
            padding: Config.PADDING,
            itemBuilder: (_, index) {
              if (index > 0) return Text('${index - 1}');
              return UserActivity(activity.model);
            },
            itemCount: activity.model.replies.length + 1,
          ),
        ),
      ),
    );
  }
}
