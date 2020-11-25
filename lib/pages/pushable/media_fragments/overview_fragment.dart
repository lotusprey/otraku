import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class OverviewFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final overview = Get.find<Media>().overview;

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          if (overview.description != null)
            InputFieldStructure(
              enforceHeight: false,
              title: 'Description',
              body: GestureDetector(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: Config.BORDER_RADIUS,
                  ),
                  child: Text(
                    overview.description,
                    style: Theme.of(context).textTheme.bodyText1,
                    overflow: TextOverflow.fade,
                    maxLines: 5,
                  ),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => PopUpAnimation(
                    TextDialog(
                      title: 'Description',
                      text: overview.description,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
