// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'gen.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountAdd => 'Add Account';

  @override
  String get accountAddWarning =>
      'To add more accounts, you must be logged out of the previous ones in the browser.';

  @override
  String get accountExpired => 'Expired';

  @override
  String accountExpiresIn(String amount) {
    return 'Expires in $amount';
  }

  @override
  String get accountGuest => 'Guest';

  @override
  String get accountLogIn => 'Log In';

  @override
  String get accountLogInAgainQuestion => 'Do you want to log in again?';

  @override
  String get accountLoginInstructions => 'Log in to access this content.';

  @override
  String get accountLoginRequired => 'Login Required';

  @override
  String get accountRemove => 'Remove Account';

  @override
  String get accountRemoveQuestion => 'Remove Account?';

  @override
  String get accountSessionExpired => 'Session Expired';

  @override
  String get accountSwitch => 'Switch Account';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionAgreementAgree => 'Agree';

  @override
  String get actionAgreementDisagree => 'Disagree';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionCollectionLoad => 'Load Entire Collection';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionCopyLink => 'Copy Link';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionGoBack => 'Go Back';

  @override
  String get actionMore => 'More';

  @override
  String get actionNo => 'No';

  @override
  String get actionOk => 'OK';

  @override
  String get actionOpenInBrowser => 'Open in Browser';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSpoilersHide => 'Hide Spoilers';

  @override
  String get actionSpoilersShow => 'Show Spoilers';

  @override
  String get actionYes => 'Yes';

  @override
  String get activities => 'Activities';

  @override
  String get all => 'All';

  @override
  String get animeCollection => 'Anime Collection';

  @override
  String get appName => 'Otraku';

  @override
  String get calendar => 'Calendar';

  @override
  String get characters => 'Characters';

  @override
  String get comments => 'Comments';

  @override
  String get country => 'Country';

  @override
  String get countryChina => 'China';

  @override
  String get countryJapan => 'Japan';

  @override
  String get countrySouthKorea => 'South Korea';

  @override
  String get countryTaiwan => 'Taiwan';

  @override
  String dateTimeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String dateTimeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horus ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String dateTimeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String dateTimeAgoMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String dateTimeAgoSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds ago',
      one: '1 second ago',
    );
    return '$_temp0';
  }

  @override
  String dateTimeAgoYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get dateTimeCreationTime => 'Creation Time';

  @override
  String get dateTimePresent => 'Present';

  @override
  String get discover => 'Discover';

  @override
  String discoverCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Discover Categories',
      one: 'Discover Category',
    );
    return '$_temp0';
  }

  @override
  String get enter => 'Enter';

  @override
  String get entryChangedDateCompletion => 'Completion date changed';

  @override
  String get entryChangedDateCompletionAndProgress => 'Completion date & progress changed';

  @override
  String get entryChangedDateCompletionAndStatus => 'Completion date & status changed';

  @override
  String get entryChangedDateStart => 'Start date changed';

  @override
  String get entryChangedDateStartAndStatus => 'Start date & status changed';

  @override
  String get entryChangedStatus => 'Status changed';

  @override
  String get entryChangedStatusAndProgress => 'Status & progress changed';

  @override
  String get entryComment => 'Comment';

  @override
  String get entryCustomLists => 'Custom Lists';

  @override
  String get entryDateCompleted => 'Completed';

  @override
  String get entryDateStarted => 'Started';

  @override
  String get entryHiddenFromStatusLists => 'Hidden From Status Lists';

  @override
  String get entryNotes => 'Notes';

  @override
  String get entryPrivate => 'Private';

  @override
  String get entryProgress => 'Progress';

  @override
  String get entryProgressIncrement => 'Increment Progress';

  @override
  String get entryProgressUpdateStatusQuestion => 'Do you also want to update the list status?';

  @override
  String get entryProgressVolumes => 'Volume Progress';

  @override
  String get entryRepeats => 'Repeats';

  @override
  String get entryScore => 'Score';

  @override
  String get entryScoreFaceDisliked => 'Score Disliked';

  @override
  String get entryScoreFaceLiked => 'Score Liked';

  @override
  String get entryScoreFaceNeutral => 'Score Neutral';

  @override
  String get entryScoreRemove => 'Unscore';

  @override
  String entryScoreStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Score $count stars',
      one: 'Score 1 star',
    );
    return '$_temp0';
  }

  @override
  String get entryStatus => 'Status';

  @override
  String get entryStatusCompleted => 'Completed';

  @override
  String get entryStatusCompletedAnime => 'Completed';

  @override
  String get entryStatusCompletedManga => 'Completed';

  @override
  String get entryStatusCurrent => 'Current';

  @override
  String get entryStatusCurrentAnime => 'Watching';

  @override
  String get entryStatusCurrentManga => 'Reading';

  @override
  String get entryStatusDropped => 'Dropped';

  @override
  String get entryStatusDroppedAnime => 'Dropped';

  @override
  String get entryStatusDroppedManga => 'Dropped';

  @override
  String get entryStatusPaused => 'Paused';

  @override
  String get entryStatusPausedAnime => 'Paused';

  @override
  String get entryStatusPausedManga => 'Paused';

  @override
  String get entryStatusPlanning => 'Planning';

  @override
  String get entryStatusPlanningAnime => 'Planning';

  @override
  String get entryStatusPlanningManga => 'Planning';

  @override
  String get entryStatusRepeating => 'Repeating';

  @override
  String get entryStatusRepeatingAnime => 'Rewatching';

  @override
  String get entryStatusRepeatingManga => 'Rereading';

  @override
  String get errorAlreadyExists => 'Already Exists';

  @override
  String get errorDateInvalid => 'Date is invalid';

  @override
  String get errorDateInvalidRange => 'Date is not in a valid range';

  @override
  String errorFailedLoading(String error) {
    return 'Failed Loading: $error';
  }

  @override
  String errorFailedReordering(String error) {
    return 'Failed Reordering: $error';
  }

  @override
  String errorFailedUpdatingProgress(String error) {
    return 'Failed Updating Progress: $error';
  }

  @override
  String get errorRequiredField => 'Required Field';

  @override
  String get externalLinks => 'External Links';

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesAdd => 'Favorite';

  @override
  String get favoritesRemove => 'Unfavorite';

  @override
  String get feed => 'Feed';

  @override
  String get filter => 'Filter';

  @override
  String get filterActivitiesFollowed => 'Followed';

  @override
  String get filterActivitiesGlobal => 'Global';

  @override
  String get filterActivitiesSelf => 'Self';

  @override
  String get filterAge => 'Age Restriction';

  @override
  String get filterAgeAdult => 'Adult';

  @override
  String get filterAgeNonAdult => 'Non-Adult';

  @override
  String get filterDefaultQuestion => 'Make default?';

  @override
  String get filterDefaultWarning => 'The current filters and sorting will become the default.';

  @override
  String get filterLicensing => 'Licensing';

  @override
  String get filterLicensingDoujin => 'Doujin';

  @override
  String get filterLicensingLicensed => 'Licensed';

  @override
  String get filterListPresence => 'List Presence';

  @override
  String get filterListPresenceIn => 'In Lists';

  @override
  String get filterListPresenceNotIn => 'Not In Lists';

  @override
  String get filterNotes => 'Notes';

  @override
  String get filterNotesWith => 'With Notes';

  @override
  String get filterNotesWithout => 'Without Notes';

  @override
  String get filterReleaseEnd => 'Release End';

  @override
  String get filterReleaseStart => 'Release Start';

  @override
  String get filterShowAll => 'Show All';

  @override
  String get filterShowBirthdayPeople => 'Show Birthday People';

  @override
  String get filterSort => 'Sort';

  @override
  String get filterSortPreview => 'Preview Sort';

  @override
  String get filterStudioRole => 'Studio Role';

  @override
  String get filterStudioRoleMain => 'Is Main';

  @override
  String get filterStudioRoleNotMain => 'Is Not Main';

  @override
  String get filterVisibility => 'Visibility';

  @override
  String get filterVisibilityPrivate => 'Private';

  @override
  String get filterVisibilityPublic => 'Public';

  @override
  String get followed => 'Following';

  @override
  String get followedAdd => 'Follow';

  @override
  String get followedRemove => 'Unfollow';

  @override
  String get followers => 'Followers';

  @override
  String get followingEachOther => 'Mutual';

  @override
  String get followingThem => 'Following';

  @override
  String get followingYou => 'Follower';

  @override
  String get forum => 'Forum';

  @override
  String get likes => 'Likes';

  @override
  String get likesAdd => 'Like';

  @override
  String get likesRemove => 'Unlike';

  @override
  String get list => 'Lists';

  @override
  String get listPreview => 'Preview';

  @override
  String get listSortAdded => 'Added';

  @override
  String get listSortAiring => 'Airing';

  @override
  String get listSortCompleted => 'Completed';

  @override
  String get listSortProgress => 'Progress';

  @override
  String get listSortRating => 'Rating';

  @override
  String get listSortReleased => 'Released';

  @override
  String get listSortRepeats => 'Repeats';

  @override
  String get listSortScore => 'Score';

  @override
  String get listSortStarted => 'Started';

  @override
  String get listSortTitle => 'Title';

  @override
  String get listSortUpdated => 'Updated';

  @override
  String get mangaCollection => 'Manga Collection';

  @override
  String get media => 'Media';

  @override
  String get mediaAdult => 'Adult';

  @override
  String get mediaChapters => 'Chapters';

  @override
  String get mediaDuration => 'Duration';

  @override
  String mediaEpisode(int episode) {
    return 'Ep $episode';
  }

  @override
  String mediaEpisodeIn(int episode, String timeUntilEpisode) {
    return 'Episode $episode in $timeUntilEpisode';
  }

  @override
  String get mediaEpisodes => 'Episodes';

  @override
  String mediaEpisodesBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes behind',
      one: '1 episode behind',
    );
    return '$_temp0';
  }

  @override
  String get mediaExternalLinks => 'External Links';

  @override
  String get mediaFormat => 'Formats';

  @override
  String get mediaFormatManga => 'Manga';

  @override
  String get mediaFormatMovie => 'Movie';

  @override
  String get mediaFormatMusic => 'Music';

  @override
  String get mediaFormatNovel => 'Novel';

  @override
  String get mediaFormatOna => 'ONA';

  @override
  String get mediaFormatOneShot => 'One Shot';

  @override
  String get mediaFormatOva => 'OVA';

  @override
  String get mediaFormatSpecial => 'Special';

  @override
  String get mediaFormatTv => 'TV';

  @override
  String get mediaFormatTvShort => 'TV Short';

  @override
  String mediaGenres(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Genres', one: 'Genre');
    return '$_temp0';
  }

  @override
  String get mediaHashtag => 'Hashtag';

  @override
  String get mediaPopularity => 'Popularity';

  @override
  String mediaProducers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Producers',
      one: 'Producer',
    );
    return '$_temp0';
  }

  @override
  String get mediaRelationTypeAdaptation => 'Adaptation';

  @override
  String get mediaRelationTypePrequel => 'Prequel';

  @override
  String get mediaRelationTypeSequel => 'Sequel';

  @override
  String get mediaRelationTypeParent => 'Parent';

  @override
  String get mediaRelationTypeSideStory => 'Side Story';

  @override
  String get mediaRelationTypeCharacter => 'Character';

  @override
  String get mediaRelationTypeSummary => 'Summary';

  @override
  String get mediaRelationTypeAlternative => 'Alternative';

  @override
  String get mediaRelationTypeSpinOff => 'Spin Off';

  @override
  String get mediaRelationTypeOther => 'Other';

  @override
  String get mediaRelationTypeSource => 'Source';

  @override
  String get mediaRelationTypeCompilation => 'Compilation';

  @override
  String get mediaRelationTypeContains => 'Contains';

  @override
  String get mediaRelease => 'Release';

  @override
  String get mediaSeason => 'Season';

  @override
  String get mediaSeasonFall => 'Fall';

  @override
  String get mediaSeasonSpring => 'Spring';

  @override
  String get mediaSeasonSummer => 'Summer';

  @override
  String get mediaSeasonWinter => 'Winter';

  @override
  String get mediaSortAddedFirst => 'First Added';

  @override
  String get mediaSortAddedLast => 'Last Added';

  @override
  String get mediaSortFavourites => 'Favourites';

  @override
  String get mediaSortPopularity => 'Popularity';

  @override
  String get mediaSortReleasedEarliest => 'Released Earliest';

  @override
  String get mediaSortReleasedLatest => 'Released Latest';

  @override
  String get mediaSortScoreBest => 'Score';

  @override
  String get mediaSortScoreWorst => 'Worst Score';

  @override
  String get mediaSortTitleEnglish => 'Title English';

  @override
  String get mediaSortTitleNative => 'Title Native';

  @override
  String get mediaSortTitleRomaji => 'Title Romaji';

  @override
  String get mediaSortTrending => 'Trending';

  @override
  String mediaSource(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sources',
      one: 'Source',
    );
    return '$_temp0';
  }

  @override
  String get mediaSourceOriginal => 'Original';

  @override
  String get mediaSourceAnime => 'Anime';

  @override
  String get mediaSourceComic => 'Comic';

  @override
  String get mediaSourceDoujinshi => 'Doujinshi';

  @override
  String get mediaSourceGame => 'Game';

  @override
  String get mediaSourceLightNovel => 'Light Novel';

  @override
  String get mediaSourceLiveAction => 'Live Action';

  @override
  String get mediaSourceManga => 'Manga';

  @override
  String get mediaSourceMultimediaProject => 'Multimedia Project';

  @override
  String get mediaSourceNovel => 'Novel';

  @override
  String get mediaSourceOther => 'Other';

  @override
  String get mediaSourcePictureBook => 'Picture Book';

  @override
  String get mediaSourceVideoGame => 'Video Game';

  @override
  String get mediaSourceVisualNovel => 'Visual Novel';

  @override
  String get mediaSourceWebNovel => 'Web Novel';

  @override
  String mediaStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Statuses',
      one: 'Status',
    );
    return '$_temp0';
  }

  @override
  String get mediaStatusCancelled => 'Cancelled';

  @override
  String get mediaStatusHiatus => 'Hiatus';

  @override
  String get mediaStatusReleased => 'Finished';

  @override
  String get mediaStatusReleasing => 'Releasing';

  @override
  String get mediaStatusUnreleased => 'Not Yet Released';

  @override
  String get mediaScoreMean => 'Mean Score';

  @override
  String get mediaScoreAverageWeighted => 'Weighted Average Score\'';

  @override
  String get mediaScoring3 => '3 Smileys';

  @override
  String get mediaScoring5 => '5 Stars';

  @override
  String get mediaScoring10 => '10 Points';

  @override
  String get mediaScoring100 => '100 Points';

  @override
  String get mediaScoring10Decimal => '10 Decimal Points';

  @override
  String get mediaTitleEnglish => 'English';

  @override
  String get mediaTitleNative => 'Native';

  @override
  String get mediaTitleRomaji => 'Romaji';

  @override
  String get mediaTitleSynonym => 'Synonym';

  @override
  String get mediaType => 'Media Type';

  @override
  String get mediaTypeAnime => 'Anime';

  @override
  String get mediaTypeManga => 'Manga';

  @override
  String get mediaVolumes => 'Volumes';

  @override
  String get numberDecrement => 'Decrement';

  @override
  String get numberIncrement => 'Increment';

  @override
  String numberMinimum(num number) {
    return 'Minimum $number';
  }

  @override
  String numberMaximum(num number) {
    return 'Maximum $number';
  }

  @override
  String get noEntries => 'No entries';

  @override
  String get noResults => 'No results';

  @override
  String get notifications => 'Notifications';

  @override
  String get overview => 'Overview';

  @override
  String get personInfoAge => 'Age';

  @override
  String get personInfoBirth => 'Age';

  @override
  String get personInfoBloodType => 'Blood Type';

  @override
  String get personInfoDeath => 'Death';

  @override
  String get personInfoGender => 'Gender';

  @override
  String get personInfoHomeTown => 'Home Town';

  @override
  String get personInfoNameAlternative => 'Alternative';

  @override
  String get personInfoNameAlternativeSpoiler => 'Alternative Spoiler';

  @override
  String get personInfoNameFull => 'Full';

  @override
  String get personInfoNameNative => 'Native';

  @override
  String get personInfoYearsActive => 'Years Active';

  @override
  String get postsAdd => 'New Post';

  @override
  String get postsLikes => 'Likes';

  @override
  String get postsLocked => 'Locked';

  @override
  String get postsPinned => 'Pinned';

  @override
  String get postsPosted => 'posted';

  @override
  String get postsReplied => 'replied';

  @override
  String get postsReplies => 'Replies';

  @override
  String get postsViews => 'Views';

  @override
  String get profile => 'Profile';

  @override
  String get random => 'Random';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get related => 'Related';

  @override
  String get replies => 'Replies';

  @override
  String get repliesAdd => 'Reply';

  @override
  String get reviews => 'Reviews';

  @override
  String get reviewsBy => 'review by';

  @override
  String reviewsOfBy(String mediaTitle, String userName) {
    return 'Review of $mediaTitle by $userName';
  }

  @override
  String get reviewsRating => 'Review Rating';

  @override
  String reviewsRatingValue(int positiveRating, int totalRating) {
    return '$positiveRating/$totalRating users liked this review';
  }

  @override
  String get reviewsScore => 'Review Score';

  @override
  String get reviewsSortHighestRated => 'Highest Rated';

  @override
  String get reviewsSortLowestRated => 'Lowest Rated';

  @override
  String get reviewsSortNewest => 'Newest';

  @override
  String get reviewsSortOldest => 'Oldest';

  @override
  String get roles => 'Roles';

  @override
  String get search => 'Search';

  @override
  String get searchGlobally => 'Search Globally';

  @override
  String get settings => 'Settings';

  @override
  String get settingsAboutClearImageCache => 'Clear Image Cache';

  @override
  String get settingsAboutDisclaimer => 'An unofficial AniList app';

  @override
  String get settingsAboutDiscord => 'Discord';

  @override
  String get settingsAboutDonate => 'Donate';

  @override
  String settingsAboutLastNotificationCheck(String lastJobTimestamp) {
    return 'Performed a notification check around $lastJobTimestamp.';
  }

  @override
  String get settingsAboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsAboutResetOptions => 'Reset Options';

  @override
  String get settingsAboutSourceCode => 'Source Code';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceModeDark => 'Dark';

  @override
  String get settingsAppearanceModeLight => 'Light';

  @override
  String get settingsAppearanceModeSystem => 'System';

  @override
  String get settingsButtonOrientation => 'Button Orientation';

  @override
  String get settingsButtonOrientationAuto => 'Auto';

  @override
  String get settingsButtonOrientationLeft => 'Left';

  @override
  String get settingsButtonOrientationRight => 'Right';

  @override
  String get settingsCollectionPreviews => 'Collection Previews';

  @override
  String get settingsCollectionPreviewsAnime => 'Anime Collection Preview';

  @override
  String get settingsCollectionPreviewsAnimeDescription =>
      'Only load your watched/rewatched anime and expand to full collection with the floating button';

  @override
  String get settingsCollectionPreviewsManga => 'Manga Collection Preview';

  @override
  String get settingsCollectionPreviewsMangaDescription =>
      'Only load your read/reread manga and expand to full collection with the floating button';

  @override
  String get settingsConfirmExit => 'Confirm Exit';

  @override
  String get settingsDefaults => 'Defaults';

  @override
  String get settingsHighContrast => 'High Contrast';

  @override
  String get settingsHighContrastDescription => 'Pure backgrounds & outlined cards';

  @override
  String get settingsHomeTab => 'Home Tab';

  @override
  String get settingsImageQuality => 'Image Quality';

  @override
  String settingsListsCustomListsAnime(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Anime Custom Lists',
      one: 'Anime Custom List',
    );
    return '$_temp0';
  }

  @override
  String settingsListsCustomListsManga(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Manga Custom Lists',
      one: 'Manga Custom List',
    );
    return '$_temp0';
  }

  @override
  String get settingsListsDefaultSiteSort => 'Default Site List Sort';

  @override
  String get settingsListsScoringAdvanced => 'Advanced Scoring';

  @override
  String settingsListsScoringAdvancedSections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Advanced Score Sections',
      one: 'Advanced Score Section',
    );
    return '$_temp0';
  }

  @override
  String get settingsListsScoringSystem => 'Scoring System';

  @override
  String get settingsListsSplitAnime => 'Split Completed Anime';

  @override
  String get settingsListsSplitManga => 'Split Completed Manga';

  @override
  String get settingsMediaActivityMergeTime => 'Activity Merge Time';

  @override
  String get settingsMediaActivityMergeTimeAlways => 'Always';

  @override
  String settingsMediaActivityMergeTimeDays(int count) {
    return '$count Days';
  }

  @override
  String settingsMediaActivityMergeTimeHours(int count) {
    return '$count Hours';
  }

  @override
  String settingsMediaActivityMergeTimeMinutes(int count) {
    return '$count Minutes';
  }

  @override
  String get settingsMediaActivityMergeTimeNever => 'Never';

  @override
  String settingsMediaActivityMergeTimeWeeks(int count) {
    return '$count Weeks';
  }

  @override
  String get settingsMediaAdult => '18+ Content';

  @override
  String get settingsMediaAiringAnimeNotifications => 'Airing Anime Notifications';

  @override
  String get settingsMediaPersonNaming => 'Character & Staff Names';

  @override
  String get settingsMediaPersonNamingNative => 'Native';

  @override
  String get settingsMediaPersonNamingRomaji => 'Romaji';

  @override
  String get settingsMediaPersonNamingRomajiWestern => 'Romaji, Western Order';

  @override
  String get settingsMediaTitleLanguage => 'Title Language';

  @override
  String get settingsMediaTitleLanguageEnglish => 'English';

  @override
  String get settingsMediaTitleLanguageNative => 'Native';

  @override
  String get settingsMediaTitleLanguageRomaji => 'Romaji';

  @override
  String settingsSocialActivityCreation(String listStatus) {
    return 'Create $listStatus activities';
  }

  @override
  String get settingsSocialLimitMessages => 'Limit Messages';

  @override
  String get settingsSocialLimitMessagesDescription => 'Only users I follow can message me';

  @override
  String get settingsTabAbout => 'About';

  @override
  String get settingsTabApp => 'App';

  @override
  String get settingsTabContent => 'Content';

  @override
  String get settingsViewLayout => 'View Layouts';

  @override
  String get settingsViewLayoutDetailed => 'Detailed';

  @override
  String get settingsViewLayoutDiscover => 'Discover View';

  @override
  String get settingsViewLayoutCollection => 'Collection View';

  @override
  String get settingsViewLayoutCollectionPreview => 'Collection Preview View';

  @override
  String get settingsViewLayoutSimple => 'Simple';

  @override
  String get social => 'Social';

  @override
  String get staff => 'Staff';

  @override
  String get statistics => 'Statistics';

  @override
  String get statisticsScoreDistribution => 'Score Distribution';

  @override
  String get statisticsStatusDistribution => 'Status Distribution';

  @override
  String studios(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Studios',
      one: 'Studio',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionAdd => 'Subscribe';

  @override
  String get subscriptionRemove => 'Unsubscribe';

  @override
  String tags(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Tags', one: 'Tag');
    return '$_temp0';
  }

  @override
  String get threads => 'Threads';

  @override
  String get users => 'Users';
}
