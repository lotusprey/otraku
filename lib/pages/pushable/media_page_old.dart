import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/models/media_object.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/tools/media_page_segments_old/media_top.dart';
import 'package:otraku/tools/media_page_segments_old/overview.dart';
import 'package:otraku/tools/media_page_segments_old/multi_widget.dart';
import 'package:otraku/tools/navigation/floating_navigation.dart';
import 'package:otraku/tools/navigation/media_action_controls.dart';
import 'package:otraku/tools/navigation/title_segmented_control.dart';
import 'package:provider/provider.dart';

class MediaPageOld extends StatefulWidget {
  final int mediaId;
  final Object tag;

  MediaPageOld({@required this.mediaId, this.tag});

  @override
  _MediaPageOldState createState() => _MediaPageOldState();
}

class _MediaPageOldState extends State<MediaPageOld> {
  MediaObject _mediaObject;
  List<MultiWidget> _parts;
  FloatingNavigation _delegate;
  ScrollController _scrollCtrl;
  bool _isLoading = true;

  double _topInset;
  double _coverWidth;
  double _coverHeight;
  double _bannerHeight;

  @override
  void initState() {
    super.initState();

    _scrollCtrl = ScrollController();

    if (_mediaObject == null) {
      _mediaObject = MediaObject(
        context: context,
        mediaId: widget.mediaId,
        setState: () {
          _topInset = Provider.of<ViewConfig>(context, listen: false).topInset;
          _coverWidth = 0.35 * MediaQuery.of(context).size.width;
          _coverHeight = 1.5 * _coverWidth;
          if (_coverHeight < 210) {
            _coverHeight = 210;
          }

          if (_mediaObject.banner != null) {
            _bannerHeight = 0.2 * MediaQuery.of(context).size.height;
          }

          setState(() => _isLoading = false);
        },
      );
    }

    _parts = [
      Overview(_mediaObject, () => setState(() {})),
    ];
  }

  @override
  void dispose() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_delegate == null && !_isLoading) {
      _delegate = FloatingNavigation(
        child: ActionControls(_mediaObject),
        scrollCtrl: _scrollCtrl,
      );
    }

    return Scaffold(
      floatingActionButton: _isLoading
          ? Container(
              color: Colors.transparent,
            )
          : _delegate,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: const DisableAnimationAnimator(),
      body: Hero(
        tag: widget.tag,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).backgroundColor,
          child: !_isLoading
              ? CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollCtrl,
                  slivers: <Widget>[
                    SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: _BannerHeader(
                        title: _mediaObject.title,
                        banner: _mediaObject.banner,
                        bannerHeight: _bannerHeight,
                        topPadding: _topInset,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          MediaTop(
                            mediaObj: _mediaObject,
                            coverWidth: _coverWidth,
                            coverHeight: _coverHeight,
                          ),
                          const SizedBox(height: 10),
                          TitleSegmentedControl(
                            function: (value) {},
                            pairs: {
                              'Overview': 0,
                              'Characters': 1,
                              'Staff': 2,
                              'Stats': 3,
                              'Social': 4,
                            },
                          ),
                        ]),
                      ),
                    ),
                    ..._parts[0].build(context),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}

class _BannerHeader implements SliverPersistentHeaderDelegate {
  final String title;
  final Image banner;
  final double topPadding;
  double _maxExtent;
  double _minExtent;
  double _diff;

  _BannerHeader({
    this.title,
    this.banner,
    bannerHeight,
    this.topPadding,
  }) {
    _minExtent = topPadding + 40;

    if (bannerHeight == null || bannerHeight < _minExtent) {
      _maxExtent = _minExtent;
    } else {
      _maxExtent = bannerHeight;
    }

    _diff = _maxExtent - _minExtent;
  }

  Widget _title(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, top: topPadding + 5),
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return banner != null
        ? Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            height: maxExtent,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _title(context),
                GestureDetector(
                  child: Opacity(
                    opacity: _fadeOut(shrinkOffset),
                    child: banner,
                  ),
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => PopUpAnimation(
                      ImageDialog(banner),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            height: minExtent,
            child: _title(context),
          );
  }

  double _fadeOut(double shrinkOffset) {
    if (shrinkOffset > _diff) {
      return 0;
    }

    return 1 - shrinkOffset / _diff;
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;
}
