import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/models/page_data/media.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/app_config.dart';
import 'package:otraku/tools/headers/media_page_header.dart';
import 'package:otraku/tools/multichild_layouts/info_grid.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class MediaPage extends StatefulWidget {
  final int id;
  final String tagImageUrl;

  MediaPage(this.id, this.tagImageUrl);

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  //Data
  Media _media;

  //Output settings
  bool _didChangeDependencies = false;
  double _coverWidth;
  double _coverHeight;
  double _bannerHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).backgroundColor,
          child: _media != null
              ? CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: MediaPageHeader(
                        media: _media,
                        coverWidth: _coverWidth,
                        coverHeight: _coverHeight,
                        maxHeight: _bannerHeight,
                        tagImageUrl: widget.tagImageUrl,
                      ),
                    ),
                    if (_media.description != null)
                      SliverPadding(
                        padding: AppConfig.PADDING,
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Text(
                                'Description',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: AppConfig.BORDER_RADIUS,
                                  ),
                                  child: Text(
                                    _media.description,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    overflow: TextOverflow.fade,
                                    maxLines: 5,
                                  ),
                                ),
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (_) => PopUpAnimation(
                                    TextDialog(
                                      title: 'Description',
                                      text: _media.description,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: InfoGrid(_media)),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 500,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).dividerColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: _coverWidth,
                            height: _coverHeight,
                            child: Hero(
                              tag: widget.tagImageUrl,
                              child: ClipRRect(
                                borderRadius: AppConfig.BORDER_RADIUS,
                                child: Image.network(
                                  widget.tagImageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    MediaItem.fetchItemData(widget.id).then((media) {
      if (media == null) return;
      _media = media;
      precacheImage(_media.cover.image, context).then((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependencies) {
      _coverWidth = MediaQuery.of(context).size.width * 0.35;
      _coverHeight = _coverWidth / 0.7;
      _bannerHeight = _coverHeight + AppConfig.MATERIAL_TAP_TARGET_SIZE + 10;
      _didChangeDependencies = true;
    }
  }
}
