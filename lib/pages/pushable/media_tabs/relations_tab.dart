import 'package:flutter/material.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/tools/navigators/bubble_tabs.dart';

class RelationsTab extends StatelessWidget {
  final Media media;

  RelationsTab(this.media);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          BubbleTabs(
            options: ['Media', 'Characters', 'Staff'],
            values: [
              Media.REL_MEDIA,
              Media.REL_CHARACTERS,
              Media.REL_CHARACTERS,
            ],
            initial: media.relationsTab,
            onNewValue: (val) => media.relationsTab = val,
            onSameValue: (_) {},
            shrinkWrap: false,
            padding: false,
          ),
          if (media.relationsTab == Media.REL_MEDIA)
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (_, index) => Container(color: Colors.green),
              itemCount: media.mediaRelations.length,
            ),
        ],
      ),
    );
  }
}
