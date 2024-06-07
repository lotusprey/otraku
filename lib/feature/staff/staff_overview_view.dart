import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/table_list.dart';
import 'package:otraku/feature/staff/staff_provider.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/layouts/constrained_view.dart';
import 'package:otraku/widget/loaders/loaders.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/util/toast.dart';

class StaffOverviewSubview extends StatelessWidget {
  const StaffOverviewSubview({
    required this.id,
    required this.scrollCtrl,
    required this.imageUrl,
  });

  final int id;
  final ScrollController scrollCtrl;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageWidth = size.width < 430.0 ? size.width * 0.30 : 100.0;
    final imageHeight = imageWidth * Theming.coverHtoWRatio;

    return Consumer(
      builder: (context, ref, _) {
        final staff = ref.watch(staffProvider(id));
        final imageUrl = staff.valueOrNull?.imageUrl ?? this.imageUrl;

        final header = SliverToBoxAdapter(
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Hero(
                      tag: id,
                      child: ClipRRect(
                        borderRadius: Theming.borderRadiusSmall,
                        child: Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: GestureDetector(
                            child: CachedImage(imageUrl),
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => ImageDialog(imageUrl),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                staff.unwrapPrevious().maybeWhen(
                      orElse: () => const SizedBox(),
                      data: (data) => Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              onTap: () => Toast.copy(context, data.name),
                              child: Text(
                                data.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            if (data.altNames.isNotEmpty)
                              Text(data.altNames.join(', ')),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );

        final refreshControl = SliverRefreshControl(
          onRefresh: () => ref.invalidate(staffProvider(id)),
        );

        return ConstrainedView(
          child: staff.unwrapPrevious().when(
                loading: () => CustomScrollView(
                  physics: Theming.bouncyPhysics,
                  controller: scrollCtrl,
                  slivers: [
                    refreshControl,
                    header,
                    const SliverFillRemaining(child: Center(child: Loader())),
                    const SliverFooter(),
                  ],
                ),
                error: (_, __) => CustomScrollView(
                  physics: Theming.bouncyPhysics,
                  controller: scrollCtrl,
                  slivers: [
                    refreshControl,
                    header,
                    const SliverFillRemaining(
                      child: Center(child: Text('No data')),
                    ),
                    const SliverFooter(),
                  ],
                ),
                data: (data) => CustomScrollView(
                  physics: Theming.bouncyPhysics,
                  controller: scrollCtrl,
                  slivers: [
                    refreshControl,
                    header,
                    const SliverToBoxAdapter(child: SizedBox(height: 15)),
                    TableList([
                      ('Favorites', data.favorites.toString()),
                      if (data.dateOfBirth != null)
                        ('Birth', data.dateOfBirth!),
                      if (data.dateOfDeath != null)
                        ('Death', data.dateOfDeath!),
                      if (data.age != null) ('Age', data.age!),
                      if (data.gender != null) ('Gender', data.gender!),
                      if (data.startYear != null)
                        (
                          'Years Active',
                          '${data.startYear} - ${data.endYear ?? 'Present'}',
                        ),
                      if (data.homeTown != null) ('Home Town', data.homeTown!),
                      if (data.bloodType != null)
                        ('Blood Type', data.bloodType!),
                    ]),
                    if (data.description.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: 15)),
                      HtmlContent(
                        data.description,
                        renderMode: RenderMode.sliverList,
                      ),
                    ],
                    const SliverFooter(),
                  ],
                ),
              ),
        );
      },
    );
  }
}
