import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/models/media_object.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/media_page_widgets/media_header.dart';
import 'package:otraku/tools/multichild_layouts/info_grid.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:provider/provider.dart';

class MediaPage extends StatefulWidget {
  final int id;
  final Object tag;

  MediaPage({@required this.id, this.tag});

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  //Data
  MediaObject _mediaObj;

  //Output settings
  bool _isLoading = true;
  bool _didChangeDependencies = false;
  Palette _palette;
  ScrollController _scrollCtrl;
  double _topInset;
  double _coverWidth;
  double _coverHeight;
  double _bannerHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      body: Hero(
        tag: widget.tag,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(top: _topInset),
          color: _palette.background,
          child: !_isLoading
              ? CustomScrollView(
                  controller: _scrollCtrl,
                  physics: const BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: MediaHeader(
                        palette: _palette,
                        mediaObj: _mediaObj,
                        coverWidth: _coverWidth,
                        coverHeight: _coverHeight,
                        height: _bannerHeight,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Text(
                              'Description',
                              style: _palette.titleSmall,
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(maxHeight: 130),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _palette.primary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  _mediaObj.description,
                                  style: _palette.paragraph,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              onTap: () => showDialog(
                                context: context,
                                builder: (_) => PopUpAnimation(
                                  TextDialog(
                                    title: 'Description',
                                    text: _mediaObj.description,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            InfoGrid(_mediaObj),
                            const SizedBox(height: 30),
                            Container(
                              height: 100,
                              color: Colors.blue,
                            ),
                            Container(
                              height: 100,
                              color: Colors.blue,
                            ),
                            Container(
                              height: 100,
                              color: Colors.blue,
                            ),
                            Container(
                              height: 100,
                              color: Colors.blue,
                            ),
                            Container(
                              height: 100,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _mediaObj = MediaObject(
      context: context,
      mediaId: widget.id,
      setState: () => setState(() => _isLoading = false),
    );

    _scrollCtrl = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependencies) {
      _palette = Provider.of<Theming>(context).palette;
      _topInset = Provider.of<ViewConfig>(context, listen: false).topInset;
      _coverWidth = MediaQuery.of(context).size.width * 0.35;
      _coverHeight = _coverWidth / 0.7;
      _bannerHeight = _coverHeight + 110;
      _didChangeDependencies = true;
    }
  }

  @override
  void dispose() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.dispose();
    }
    super.dispose();
  }
}
