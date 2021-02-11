import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/viewer.dart';
import 'package:otraku/pages/home/feed_controls.dart';
import 'package:otraku/tools/layouts/activity_list.dart';
import 'package:otraku/tools/navigation/headline_header.dart';

class FeedTab extends StatelessWidget {
  const FeedTab();

  @override
  Widget build(BuildContext context) {
    final viewer = Get.find<Viewer>();
    return CustomScrollView(
      controller: viewer.scrollCtrl,
      physics: Config.PHYSICS,
      slivers: [
        const HeadlineHeader('Feed', false),
        FeedControls(viewer),
        ActivityList(viewer),
      ],
    );
  }
}
