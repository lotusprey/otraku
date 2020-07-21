import 'package:flutter/material.dart';
import 'package:otraku/models/media_object.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/tools/media_page_segments_old/multi_widget.dart';

class Overview extends MultiWidget {
  final MediaObject mediaObject;
  final Function setState;

  Overview(this.mediaObject, this.setState);

  @override
  List<Widget> build(BuildContext context) {
    bool isLoading = false;

    if (mediaObject.overview == null) {
      isLoading = true;
      mediaObject.initOverview(context, () => setState());
    }

    return !isLoading
        ? [
            if (mediaObject.overview.description != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(maxHeight: 130),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            mediaObject.overview.description,
                            style: Theme.of(context).textTheme.bodyText1,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => PopUpAnimation(
                            TextDialog(
                              title: 'Description',
                              text: mediaObject.overview.description,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 20,
                bottom: 70,
              ),
              sliver: SliverToBoxAdapter(
                child: Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: mediaObject.overview.info
                      .map((i) => _InfoTile(
                            i.item1,
                            i.item2,
                          ))
                      .toList(),
                ),
              ),
            ),
          ]
        : [];
  }
}

class _InfoTile extends StatelessWidget {
  final String heading;
  final String subtitle;

  const _InfoTile(this.heading, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              heading,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
}
