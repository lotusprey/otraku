import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/models/user.dart';
import 'package:otraku/pages/pushable/settings_page.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/providers/users.dart';
import 'package:otraku/providers/app_config.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:provider/provider.dart';

class UserTab extends StatefulWidget {
  final int id;

  UserTab(this.id);

  @override
  _UserTabState createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  static const _space = SizedBox(width: 10);

  User _user;
  bool _didChangeDependencies = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPersistentHeader(
          delegate: _Header(_user, widget.id == null),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentSystemIcons.ic_fluent_movies_and_tv_regular,
                          color: Theme.of(context).backgroundColor,
                        ),
                        _space,
                        Text('Anime List',
                            style: Theme.of(context).textTheme.button),
                      ],
                    ),
                    onPressed: () => widget.id == null
                        ? AppConfig.pageIndex = TabManager.ANIME_LIST
                        : print('TODO'),
                  ),
                ),
                _space,
                Expanded(
                  child: RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentSystemIcons.ic_fluent_bookmark_regular,
                          color: Theme.of(context).backgroundColor,
                        ),
                        _space,
                        Text('Manga List',
                            style: Theme.of(context).textTheme.button),
                      ],
                    ),
                    onPressed: () => widget.id == null
                        ? AppConfig.pageIndex = TabManager.MANGA_LIST
                        : print('TODO'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependencies) {
      if (widget.id == null) {
        _user = Provider.of<Users>(context).me;
      } else {
        _user = Provider.of<Users>(context).them(widget.id);
      }
      _didChangeDependencies = true;
    }
  }
}

class _Header implements SliverPersistentHeaderDelegate {
  final User user;
  final bool isMe;

  _Header(this.user, this.isMe);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    if (user == null) return const SizedBox();

    final shrinkPercentage = shrinkOffset / (maxExtent - minExtent);
    final avatar =
        user != null ? Image.network(user.avatar, fit: BoxFit.cover) : null;

    return Container(
      height: maxExtent,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).backgroundColor,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (user != null) ...[
            if (user.banner != null)
              Image.network(
                user.banner,
                fit: BoxFit.cover,
              ),
            Container(
              padding: const EdgeInsets.only(
                top: AppConfig.MATERIAL_TAP_TARGET_SIZE,
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).backgroundColor.withAlpha(70),
                    Theme.of(context).backgroundColor,
                  ],
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    child: Hero(
                      tag: user.avatar,
                      child: ClipRRect(
                        borderRadius: AppConfig.BORDER_RADIUS,
                        child: Container(
                          height: 150,
                          width: 150,
                          child: avatar,
                        ),
                      ),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => PopUpAnimation(
                        ImageDialog(avatar),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(user.name, style: Theme.of(context).textTheme.headline3),
                ],
              ),
            ),
            if (shrinkOffset > 0)
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Theme.of(context)
                    .backgroundColor
                    .withAlpha((shrinkPercentage * 255).round()),
              ),
          ],
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isMe) ...[
                  const SizedBox(),
                  IconButton(
                    icon: const Icon(
                        FluentSystemIcons.ic_fluent_settings_regular),
                    color: Theme.of(context).dividerColor,
                    onPressed: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (ctx) => SettingsPage(),
                        )),
                  ),
                ] else ...[
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).dividerColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 300;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  TickerProvider get vsync => null;
}
