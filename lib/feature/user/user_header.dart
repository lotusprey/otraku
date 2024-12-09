import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/feature/user/user_model.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/field/pill_selector.dart';
import 'package:otraku/widget/layout/content_header.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/text_rail.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({
    required this.id,
    required this.isViewer,
    required this.user,
    required this.imageUrl,
    required this.toggleFollow,
  });

  final int? id;
  final bool isViewer;
  final User? user;
  final String? imageUrl;
  final Future<Object?> Function() toggleFollow;

  @override
  Widget build(BuildContext context) {
    final textRailItems = <String, bool>{};
    if (user != null) {
      if (user!.modRoles.isNotEmpty) textRailItems[user!.modRoles[0]] = false;
      if (user!.donatorTier > 0) textRailItems[user!.donatorBadge] = true;
    }

    return ContentHeader(
      imageUrl: user?.imageUrl ?? imageUrl,
      imageHeightToWidthRatio: 1,
      imageHeroTag: id ?? '',
      imageFit: BoxFit.contain,
      bannerUrl: user?.bannerUrl,
      siteUrl: user?.siteUrl,
      title: user?.name,
      details: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (user?.modRoles.isNotEmpty ?? false) {
            showDialog(
              context: context,
              builder: (context) => TextDialog(
                title: 'Roles',
                text: user!.modRoles.join(', '),
              ),
            );
          }
        },
        child: TextRail(
          textRailItems,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
      trailingTopButtons: [
        if (isViewer) ...[
          IconButton(
            tooltip: 'Switch Account',
            icon: const Icon(Icons.manage_accounts_outlined),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const _AccountPicker(),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Ionicons.cog_outline),
            onPressed: () => context.push(Routes.settings),
          ),
        ] else if (user != null)
          _FollowButton(user!, toggleFollow),
      ],
    );
  }
}

class _AccountPicker extends StatefulWidget {
  const _AccountPicker();

  @override
  State<_AccountPicker> createState() => __AccountPickerState();
}

class __AccountPickerState extends State<_AccountPicker> {
  static const _loginLink =
      'https://anilist.co/api/v2/oauth/authorize?client_id=3535&response_type=token';

  static const _imageSize = 60.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: Theming.offset,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Theming.offset),
        child: Consumer(
          builder: (context, ref, _) {
            final accountGroup = ref.watch(
              persistenceProvider.select((s) => s.accountGroup),
            );
            final accounts = accountGroup.accounts;

            const divider = SizedBox(
              height: 40,
              child: VerticalDivider(width: 10, thickness: 1),
            );

            final items = <Widget>[];
            for (int i = 0; i < accounts.length; i++) {
              items.add(Row(
                children: [
                  CachedImage(
                    accounts[i].avatarUrl,
                    width: _imageSize,
                    height: _imageSize,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${accounts[i].name} ${accounts[i].id}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Text(
                          DateTime.now().isBefore(accounts[i].expiration)
                              ? 'Expires in ${accounts[i].expiration.timeUntil}'
                              : 'Expired',
                          style: Theme.of(context).textTheme.labelMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        )
                      ],
                    ),
                  ),
                  divider,
                  IconButton(
                    tooltip: 'Remove Account',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => ConfirmationDialog.show(
                      context,
                      title: 'Remove Account?',
                      primaryAction: 'Yes',
                      secondaryAction: 'No',
                      onConfirm: () {
                        if (i == accountGroup.accountIndex) {
                          ref
                              .read(persistenceProvider.notifier)
                              .switchAccount(null);
                        }

                        ref
                            .read(persistenceProvider.notifier)
                            .removeAccount(i)
                            .then((_) => setState(() {}));
                      },
                    ),
                  ),
                ],
              ));
            }

            items.add(Row(
              children: [
                const SizedBox(
                  height: _imageSize,
                  width: _imageSize + Theming.offset,
                  child: Icon(Icons.person_rounded, size: _imageSize),
                ),
                const Expanded(child: Text('Guest')),
                divider,
                IconButton(
                  tooltip: 'Add Account',
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => _addAccount(accounts.isEmpty),
                ),
              ],
            ));

            return PillSelector(
              maxWidth: 350,
              shrinkWrap: true,
              selected: accountGroup.accountIndex ?? accounts.length,
              items: items,
              onTap: (i) async {
                if (i == accounts.length) {
                  ref.read(persistenceProvider.notifier).switchAccount(null);
                  Navigator.pop(context);
                  return;
                }

                if (DateTime.now().isBefore(accounts[i].expiration)) {
                  ref.read(persistenceProvider.notifier).switchAccount(i);
                  Navigator.pop(context);
                  return;
                }

                var ok = false;
                await ConfirmationDialog.show(
                  context,
                  title: 'Session expired',
                  content: 'Do you want to log in again?',
                  primaryAction: 'Yes',
                  secondaryAction: 'No',
                  onConfirm: () => ok = true,
                );

                if (ok) _addAccount(accounts.isEmpty);
              },
            );
          },
        ),
      ),
    );
  }

  void _addAccount(bool isAccountListEmpty) {
    if (isAccountListEmpty) {
      SnackBarExtension.launch(context, _loginLink);
      return;
    }

    ConfirmationDialog.show(
      context,
      title: 'Add an Account',
      content:
          'To add more accounts, make sure you\'re logged out of the previous ones in the browser.',
      primaryAction: 'Continue',
      secondaryAction: 'Cancel',
      onConfirm: () {
        if (mounted) {
          SnackBarExtension.launch(context, _loginLink);
        }
      },
    );
  }
}

class _FollowButton extends StatefulWidget {
  const _FollowButton(this.user, this.toggleFollow);

  final User user;
  final Future<Object?> Function() toggleFollow;

  @override
  State<_FollowButton> createState() => __FollowButtonState();
}

class __FollowButtonState extends State<_FollowButton> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Padding(
      padding: const EdgeInsets.all(Theming.offset),
      child: ElevatedButton.icon(
        icon: Icon(
          user.isFollowed
              ? Ionicons.person_remove_outline
              : Ionicons.person_add_outline,
          size: Theming.iconSmall,
        ),
        label: Text(
          user.isFollowed
              ? user.isFollower
                  ? 'Mutual'
                  : 'Following'
              : user.isFollower
                  ? 'Follower'
                  : 'Follow',
        ),
        onPressed: () {
          final isFollowed = user.isFollowed;
          setState(() => user.isFollowed = !isFollowed);

          widget.toggleFollow().then((err) {
            if (err == null) return;

            setState(() => user.isFollowed = isFollowed);

            if (context.mounted) {
              SnackBarExtension.show(context, err.toString());
            }
          });
        },
      ),
    );
  }
}
