import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/staff/staff_models.dart';
import 'package:otraku/staff/staff_providers.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class StaffInfoTab extends StatelessWidget {
  const StaffInfoTab(this.id, this.imageUrl, this.scrollCtrl);

  final int id;
  final String? imageUrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final refreshControl = SliverRefreshControl(
          onRefresh: () {
            ref.invalidate(staffProvider(id));
            return Future.value();
          },
        );

        return ref.watch(staffProvider(id)).when(
              loading: () => _TabContent(
                id: id,
                data: null,
                imageUrl: imageUrl,
                scrollCtrl: scrollCtrl,
                refreshControl: refreshControl,
                loading: true,
              ),
              error: (_, __) => _TabContent(
                id: id,
                data: null,
                imageUrl: imageUrl,
                scrollCtrl: scrollCtrl,
                refreshControl: refreshControl,
                loading: false,
              ),
              data: (data) => _TabContent(
                id: id,
                data: data,
                imageUrl: imageUrl,
                scrollCtrl: scrollCtrl,
                refreshControl: refreshControl,
                loading: false,
              ),
            );
      },
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.id,
    required this.data,
    required this.imageUrl,
    required this.scrollCtrl,
    required this.refreshControl,
    required this.loading,
  });

  final int id;
  final Staff? data;
  final String? imageUrl;
  final ScrollController scrollCtrl;
  final Widget refreshControl;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width < 430.0
        ? MediaQuery.of(context).size.width * 0.30
        : 100.0;
    final imageHeight = imageWidth * Consts.coverHtoWRatio;

    final imageUrl = data?.imageUrl ?? this.imageUrl;

    final headerRow = IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            Hero(
              tag: id,
              child: ClipRRect(
                borderRadius: Consts.borderRadiusMin,
                child: Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: GestureDetector(
                    child: FadeImage(imageUrl),
                    onTap: () => showPopUp(context, ImageDialog(imageUrl)),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 10),
          if (data != null)
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () => Toast.copy(context, data!.name),
                    child: Text(
                      data!.name,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  if (data!.altNames.isNotEmpty)
                    Text(data!.altNames.join(', ')),
                ],
              ),
            ),
        ],
      ),
    );

    const space = SliverToBoxAdapter(child: SizedBox(height: 10));

    return PageLayout(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: [if (data != null) _FavoriteButton(data!)],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
            child: CustomScrollView(
              controller: scrollCtrl,
              physics: Consts.physics,
              slivers: [
                refreshControl,
                space,
                SliverToBoxAdapter(child: headerRow),
                if (data != null) ...[
                  space,
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMinWidthAndFixedHeight(
                      height: Consts.tapTargetSize,
                      minWidth: 150,
                    ),
                    delegate: SliverChildListDelegate([
                      _InfoTile('Favourites', data!.favorites.toString()),
                      if (data!.gender != null)
                        _InfoTile('Gender', data!.gender!),
                      if (data!.age != null) _InfoTile('Age', data!.age!),
                      if (data!.dateOfBirth != null)
                        _InfoTile('Date of Birth', data!.dateOfBirth!),
                      if (data!.dateOfDeath != null)
                        _InfoTile('Date of Death', data!.dateOfDeath!),
                      if (data!.startYear != null)
                        _InfoTile('Active Since', data!.startYear!),
                      if (data!.endYear != null)
                        _InfoTile('Active Until', data!.endYear!),
                      if (data!.homeTown != null)
                        _InfoTile('Home Town', data!.homeTown!),
                      if (data!.bloodType != null)
                        _InfoTile('Blood Type', data!.bloodType!),
                    ]),
                  ),
                  space,
                  if (data!.description.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Card(
                        child: Padding(
                          padding: Consts.padding,
                          child: HtmlContent(data!.description),
                        ),
                      ),
                    ),
                ] else
                  SliverFillRemaining(
                    child: Center(
                      child: loading ? const Loader() : const Text('No data'),
                    ),
                  ),
                const SliverFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.data);

  final Staff data;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: widget.data.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: widget.data.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () {
        setState(() => widget.data.isFavorite = !widget.data.isFavorite);
        toggleFavoriteStaff(widget.data.id).then((ok) {
          if (!ok) {
            setState(() => widget.data.isFavorite = !widget.data.isFavorite);
          }
        });
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              maxLines: 1,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(subtitle, maxLines: 1),
          ],
        ),
      ),
    );
  }
}
