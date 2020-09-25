import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/models/media_data.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/media_header.dart';
import 'package:otraku/tools/multichild_layouts/info_grid.dart';
import 'package:otraku/tools/overlays/dialogs.dart';

class MediaPage extends StatefulWidget {
  final int id;
  final Object tag;

  MediaPage({@required this.id, this.tag});

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  //Data
  MediaData _media;

  //Output settings
  bool _isLoading = true;
  bool _didChangeDependencies = false;
  double _coverWidth;
  double _coverHeight;
  double _bannerHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: widget.tag,
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).backgroundColor,
            child: !_isLoading
                ? CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverPersistentHeader(
                        pinned: true,
                        floating: false,
                        delegate: MediaHeader(
                          mediaObj: _media,
                          coverWidth: _coverWidth,
                          coverHeight: _coverHeight,
                          height: _bannerHeight,
                        ),
                      ),
                      if (_media.description != null)
                        SliverPadding(
                          padding: ViewConfig.PADDING,
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
                                    width: double.infinity,
                                    constraints: BoxConstraints(maxHeight: 130),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: ViewConfig.RADIUS,
                                    ),
                                    child: Text(
                                      _media.description,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                      overflow: TextOverflow.fade,
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
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _media = MediaData(
      context: context,
      id: widget.id,
      setState: () => setState(() => _isLoading = false),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependencies) {
      _coverWidth = MediaQuery.of(context).size.width * 0.35;
      _coverHeight = _coverWidth / 0.7;
      _bannerHeight = _coverHeight + 110;
      _didChangeDependencies = true;
    }
  }
}
