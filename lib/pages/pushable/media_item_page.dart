import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/models/media_page_data.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/media_header.dart';
import 'package:otraku/tools/multichild_layouts/info_grid.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:provider/provider.dart';

class MediaItemPage extends StatefulWidget {
  final int id;
  final Object tag;

  MediaItemPage({@required this.id, this.tag});

  @override
  _MediaItemPageState createState() => _MediaItemPageState();
}

class _MediaItemPageState extends State<MediaItemPage> {
  //Data
  MediaPageData _media;

  //Output settings
  bool _isLoading = true;
  bool _didChangeDependencies = false;
  Palette _palette;
  double _coverWidth;
  double _coverHeight;
  double _bannerHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      body: Hero(
        tag: widget.tag,
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: _palette.background,
            child: !_isLoading
                ? CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverPersistentHeader(
                        pinned: true,
                        floating: false,
                        delegate: MediaHeader(
                          palette: _palette,
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
                                  style: _palette.smallTitle,
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  child: Container(
                                    width: double.infinity,
                                    constraints: BoxConstraints(maxHeight: 130),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _palette.primary,
                                      borderRadius: ViewConfig.RADIUS,
                                    ),
                                    child: Text(
                                      _media.description,
                                      style: _palette.paragraph,
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
    _media = MediaPageData(
      context: context,
      id: widget.id,
      setState: () => setState(() => _isLoading = false),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependencies) {
      _palette = Provider.of<Theming>(context).palette;
      _coverWidth = MediaQuery.of(context).size.width * 0.35;
      _coverHeight = _coverWidth / 0.7;
      _bannerHeight = _coverHeight + 110;
      _didChangeDependencies = true;
    }
  }
}
