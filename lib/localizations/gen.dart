import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'gen_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localizations/gen.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @accountAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get accountAdd;

  /// No description provided for @accountAddWarning.
  ///
  /// In en, this message translates to:
  /// **'To add more accounts, you must be logged out of the previous ones in the browser.'**
  String get accountAddWarning;

  /// No description provided for @accountExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get accountExpired;

  /// After how much time a login will expire
  ///
  /// In en, this message translates to:
  /// **'Expires in {amount}'**
  String accountExpiresIn(String amount);

  /// No description provided for @accountGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get accountGuest;

  /// No description provided for @accountLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get accountLogIn;

  /// No description provided for @accountLogInAgainQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log in again?'**
  String get accountLogInAgainQuestion;

  /// No description provided for @accountLoginInstructions.
  ///
  /// In en, this message translates to:
  /// **'Log in to access this content.'**
  String get accountLoginInstructions;

  /// No description provided for @accountLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get accountLoginRequired;

  /// No description provided for @accountRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove Account'**
  String get accountRemove;

  /// No description provided for @accountRemoveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove Account?'**
  String get accountRemoveQuestion;

  /// No description provided for @accountSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get accountSessionExpired;

  /// No description provided for @accountSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch Account'**
  String get accountSwitch;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionAgreementAgree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get actionAgreementAgree;

  /// No description provided for @actionAgreementDisagree.
  ///
  /// In en, this message translates to:
  /// **'Disagree'**
  String get actionAgreementDisagree;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionCollectionLoad.
  ///
  /// In en, this message translates to:
  /// **'Load Entire Collection'**
  String get actionCollectionLoad;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get actionCopyLink;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get actionGoBack;

  /// No description provided for @actionMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get actionMore;

  /// No description provided for @actionNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get actionNo;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get actionOpenInBrowser;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionSpoilersHide.
  ///
  /// In en, this message translates to:
  /// **'Hide Spoilers'**
  String get actionSpoilersHide;

  /// No description provided for @actionSpoilersShow.
  ///
  /// In en, this message translates to:
  /// **'Show Spoilers'**
  String get actionSpoilersShow;

  /// No description provided for @actionYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get actionYes;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @animeCollection.
  ///
  /// In en, this message translates to:
  /// **'Anime Collection'**
  String get animeCollection;

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Otraku'**
  String get appName;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get characters;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @countryChina.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get countryChina;

  /// No description provided for @countryJapan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get countryJapan;

  /// No description provided for @countrySouthKorea.
  ///
  /// In en, this message translates to:
  /// **'South Korea'**
  String get countrySouthKorea;

  /// No description provided for @countryTaiwan.
  ///
  /// In en, this message translates to:
  /// **'Taiwan'**
  String get countryTaiwan;

  /// Past relative time in days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String dateTimeAgoDays(int count);

  /// Past relative time in hours
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} horus ago}}'**
  String dateTimeAgoHours(int count);

  /// Past relative time in minutes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String dateTimeAgoMinutes(int count);

  /// Past relative time in months
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String dateTimeAgoMonths(int count);

  /// Past relative time in seconds
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second ago} other{{count} seconds ago}}'**
  String dateTimeAgoSeconds(int count);

  /// Past relative time in years
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String dateTimeAgoYears(int count);

  /// No description provided for @dateTimeCreationTime.
  ///
  /// In en, this message translates to:
  /// **'Creation Time'**
  String get dateTimeCreationTime;

  /// No description provided for @dateTimePresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get dateTimePresent;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// Browsable categories
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Discover Category} other{Discover Categories}}'**
  String discoverCategories(int count);

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @entryChangedDateCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion date changed'**
  String get entryChangedDateCompletion;

  /// No description provided for @entryChangedDateCompletionAndProgress.
  ///
  /// In en, this message translates to:
  /// **'Completion date & progress changed'**
  String get entryChangedDateCompletionAndProgress;

  /// No description provided for @entryChangedDateCompletionAndStatus.
  ///
  /// In en, this message translates to:
  /// **'Completion date & status changed'**
  String get entryChangedDateCompletionAndStatus;

  /// No description provided for @entryChangedDateStart.
  ///
  /// In en, this message translates to:
  /// **'Start date changed'**
  String get entryChangedDateStart;

  /// No description provided for @entryChangedDateStartAndStatus.
  ///
  /// In en, this message translates to:
  /// **'Start date & status changed'**
  String get entryChangedDateStartAndStatus;

  /// No description provided for @entryChangedStatus.
  ///
  /// In en, this message translates to:
  /// **'Status changed'**
  String get entryChangedStatus;

  /// No description provided for @entryChangedStatusAndProgress.
  ///
  /// In en, this message translates to:
  /// **'Status & progress changed'**
  String get entryChangedStatusAndProgress;

  /// No description provided for @entryComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get entryComment;

  /// No description provided for @entryCustomLists.
  ///
  /// In en, this message translates to:
  /// **'Custom Lists'**
  String get entryCustomLists;

  /// No description provided for @entryDateCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get entryDateCompleted;

  /// No description provided for @entryDateStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get entryDateStarted;

  /// No description provided for @entryHiddenFromStatusLists.
  ///
  /// In en, this message translates to:
  /// **'Hidden From Status Lists'**
  String get entryHiddenFromStatusLists;

  /// No description provided for @entryNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get entryNotes;

  /// No description provided for @entryPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get entryPrivate;

  /// No description provided for @entryProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get entryProgress;

  /// No description provided for @entryProgressIncrement.
  ///
  /// In en, this message translates to:
  /// **'Increment Progress'**
  String get entryProgressIncrement;

  /// No description provided for @entryProgressUpdateStatusQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you also want to update the list status?'**
  String get entryProgressUpdateStatusQuestion;

  /// No description provided for @entryProgressVolumes.
  ///
  /// In en, this message translates to:
  /// **'Volume Progress'**
  String get entryProgressVolumes;

  /// No description provided for @entryRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get entryRepeats;

  /// No description provided for @entryScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get entryScore;

  /// No description provided for @entryScoreFaceDisliked.
  ///
  /// In en, this message translates to:
  /// **'Score Disliked'**
  String get entryScoreFaceDisliked;

  /// No description provided for @entryScoreFaceLiked.
  ///
  /// In en, this message translates to:
  /// **'Score Liked'**
  String get entryScoreFaceLiked;

  /// No description provided for @entryScoreFaceNeutral.
  ///
  /// In en, this message translates to:
  /// **'Score Neutral'**
  String get entryScoreFaceNeutral;

  /// No description provided for @entryScoreRemove.
  ///
  /// In en, this message translates to:
  /// **'Unscore'**
  String get entryScoreRemove;

  /// Score in star format
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Score 1 star} other{Score {count} stars}}'**
  String entryScoreStars(int count);

  /// No description provided for @entryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get entryStatus;

  /// No description provided for @entryStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get entryStatusCompleted;

  /// No description provided for @entryStatusCompletedAnime.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get entryStatusCompletedAnime;

  /// No description provided for @entryStatusCompletedManga.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get entryStatusCompletedManga;

  /// No description provided for @entryStatusCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get entryStatusCurrent;

  /// No description provided for @entryStatusCurrentAnime.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get entryStatusCurrentAnime;

  /// No description provided for @entryStatusCurrentManga.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get entryStatusCurrentManga;

  /// No description provided for @entryStatusDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get entryStatusDropped;

  /// No description provided for @entryStatusDroppedAnime.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get entryStatusDroppedAnime;

  /// No description provided for @entryStatusDroppedManga.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get entryStatusDroppedManga;

  /// No description provided for @entryStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get entryStatusPaused;

  /// No description provided for @entryStatusPausedAnime.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get entryStatusPausedAnime;

  /// No description provided for @entryStatusPausedManga.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get entryStatusPausedManga;

  /// No description provided for @entryStatusPlanning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get entryStatusPlanning;

  /// No description provided for @entryStatusPlanningAnime.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get entryStatusPlanningAnime;

  /// No description provided for @entryStatusPlanningManga.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get entryStatusPlanningManga;

  /// No description provided for @entryStatusRepeating.
  ///
  /// In en, this message translates to:
  /// **'Repeating'**
  String get entryStatusRepeating;

  /// No description provided for @entryStatusRepeatingAnime.
  ///
  /// In en, this message translates to:
  /// **'Rewatching'**
  String get entryStatusRepeatingAnime;

  /// No description provided for @entryStatusRepeatingManga.
  ///
  /// In en, this message translates to:
  /// **'Rereading'**
  String get entryStatusRepeatingManga;

  /// No description provided for @errorAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Already Exists'**
  String get errorAlreadyExists;

  /// No description provided for @errorDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Date is invalid'**
  String get errorDateInvalid;

  /// No description provided for @errorDateInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Date is not in a valid range'**
  String get errorDateInvalidRange;

  /// Failed http request
  ///
  /// In en, this message translates to:
  /// **'Failed Loading: {error}'**
  String errorFailedLoading(String error);

  /// Failed http request for item reordering
  ///
  /// In en, this message translates to:
  /// **'Failed Reordering: {error}'**
  String errorFailedReordering(String error);

  /// Failed http request for updating entry progress
  ///
  /// In en, this message translates to:
  /// **'Failed Updating Progress: {error}'**
  String errorFailedUpdatingProgress(String error);

  /// No description provided for @errorRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Required Field'**
  String get errorRequiredField;

  /// No description provided for @externalLinks.
  ///
  /// In en, this message translates to:
  /// **'External Links'**
  String get externalLinks;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoritesAdd.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favoritesAdd;

  /// No description provided for @favoritesRemove.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get favoritesRemove;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterActivitiesFollowed.
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get filterActivitiesFollowed;

  /// No description provided for @filterActivitiesGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get filterActivitiesGlobal;

  /// No description provided for @filterActivitiesSelf.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get filterActivitiesSelf;

  /// No description provided for @filterAge.
  ///
  /// In en, this message translates to:
  /// **'Age Restriction'**
  String get filterAge;

  /// No description provided for @filterAgeAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get filterAgeAdult;

  /// No description provided for @filterAgeNonAdult.
  ///
  /// In en, this message translates to:
  /// **'Non-Adult'**
  String get filterAgeNonAdult;

  /// No description provided for @filterDefaultQuestion.
  ///
  /// In en, this message translates to:
  /// **'Make default?'**
  String get filterDefaultQuestion;

  /// No description provided for @filterDefaultWarning.
  ///
  /// In en, this message translates to:
  /// **'The current filters and sorting will become the default.'**
  String get filterDefaultWarning;

  /// No description provided for @filterLicensing.
  ///
  /// In en, this message translates to:
  /// **'Licensing'**
  String get filterLicensing;

  /// No description provided for @filterLicensingDoujin.
  ///
  /// In en, this message translates to:
  /// **'Doujin'**
  String get filterLicensingDoujin;

  /// No description provided for @filterLicensingLicensed.
  ///
  /// In en, this message translates to:
  /// **'Licensed'**
  String get filterLicensingLicensed;

  /// No description provided for @filterListPresence.
  ///
  /// In en, this message translates to:
  /// **'List Presence'**
  String get filterListPresence;

  /// No description provided for @filterListPresenceIn.
  ///
  /// In en, this message translates to:
  /// **'In Lists'**
  String get filterListPresenceIn;

  /// No description provided for @filterListPresenceNotIn.
  ///
  /// In en, this message translates to:
  /// **'Not In Lists'**
  String get filterListPresenceNotIn;

  /// No description provided for @filterNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get filterNotes;

  /// No description provided for @filterNotesWith.
  ///
  /// In en, this message translates to:
  /// **'With Notes'**
  String get filterNotesWith;

  /// No description provided for @filterNotesWithout.
  ///
  /// In en, this message translates to:
  /// **'Without Notes'**
  String get filterNotesWithout;

  /// No description provided for @filterReleaseEnd.
  ///
  /// In en, this message translates to:
  /// **'Release End'**
  String get filterReleaseEnd;

  /// No description provided for @filterReleaseStart.
  ///
  /// In en, this message translates to:
  /// **'Release Start'**
  String get filterReleaseStart;

  /// No description provided for @filterShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get filterShowAll;

  /// No description provided for @filterShowBirthdayPeople.
  ///
  /// In en, this message translates to:
  /// **'Show Birthday People'**
  String get filterShowBirthdayPeople;

  /// No description provided for @filterSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get filterSort;

  /// No description provided for @filterSortPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview Sort'**
  String get filterSortPreview;

  /// No description provided for @filterStudioRole.
  ///
  /// In en, this message translates to:
  /// **'Studio Role'**
  String get filterStudioRole;

  /// No description provided for @filterStudioRoleMain.
  ///
  /// In en, this message translates to:
  /// **'Is Main'**
  String get filterStudioRoleMain;

  /// No description provided for @filterStudioRoleNotMain.
  ///
  /// In en, this message translates to:
  /// **'Is Not Main'**
  String get filterStudioRoleNotMain;

  /// No description provided for @filterVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get filterVisibility;

  /// No description provided for @filterVisibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get filterVisibilityPrivate;

  /// No description provided for @filterVisibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get filterVisibilityPublic;

  /// No description provided for @followed.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followed;

  /// No description provided for @followedAdd.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followedAdd;

  /// No description provided for @followedRemove.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get followedRemove;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @followingEachOther.
  ///
  /// In en, this message translates to:
  /// **'Mutual'**
  String get followingEachOther;

  /// No description provided for @followingThem.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingThem;

  /// No description provided for @followingYou.
  ///
  /// In en, this message translates to:
  /// **'Follower'**
  String get followingYou;

  /// No description provided for @forum.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get forum;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// No description provided for @likesAdd.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likesAdd;

  /// No description provided for @likesRemove.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get likesRemove;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get list;

  /// No description provided for @listPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get listPreview;

  /// No description provided for @listSortAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get listSortAdded;

  /// No description provided for @listSortAiring.
  ///
  /// In en, this message translates to:
  /// **'Airing'**
  String get listSortAiring;

  /// No description provided for @listSortCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get listSortCompleted;

  /// No description provided for @listSortProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get listSortProgress;

  /// No description provided for @listSortRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get listSortRating;

  /// No description provided for @listSortReleased.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get listSortReleased;

  /// No description provided for @listSortRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get listSortRepeats;

  /// No description provided for @listSortScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get listSortScore;

  /// No description provided for @listSortStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get listSortStarted;

  /// No description provided for @listSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get listSortTitle;

  /// No description provided for @listSortUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get listSortUpdated;

  /// No description provided for @mangaCollection.
  ///
  /// In en, this message translates to:
  /// **'Manga Collection'**
  String get mangaCollection;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @mediaAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get mediaAdult;

  /// No description provided for @mediaChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get mediaChapters;

  /// No description provided for @mediaDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get mediaDuration;

  /// Next episode to be aired
  ///
  /// In en, this message translates to:
  /// **'Ep {episode}'**
  String mediaEpisode(int episode);

  /// Next episode to be aired and in what time
  ///
  /// In en, this message translates to:
  /// **'Episode {episode} in {timeUntilEpisode}'**
  String mediaEpisodeIn(int episode, String timeUntilEpisode);

  /// No description provided for @mediaEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get mediaEpisodes;

  /// How many aired episodes are left to watch
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 episode behind} other{{count} episodes behind}}'**
  String mediaEpisodesBehind(int count);

  /// No description provided for @mediaExternalLinks.
  ///
  /// In en, this message translates to:
  /// **'External Links'**
  String get mediaExternalLinks;

  /// No description provided for @mediaFormat.
  ///
  /// In en, this message translates to:
  /// **'Formats'**
  String get mediaFormat;

  /// No description provided for @mediaFormatManga.
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get mediaFormatManga;

  /// No description provided for @mediaFormatMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get mediaFormatMovie;

  /// No description provided for @mediaFormatMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get mediaFormatMusic;

  /// No description provided for @mediaFormatNovel.
  ///
  /// In en, this message translates to:
  /// **'Novel'**
  String get mediaFormatNovel;

  /// No description provided for @mediaFormatOna.
  ///
  /// In en, this message translates to:
  /// **'ONA'**
  String get mediaFormatOna;

  /// No description provided for @mediaFormatOneShot.
  ///
  /// In en, this message translates to:
  /// **'One Shot'**
  String get mediaFormatOneShot;

  /// No description provided for @mediaFormatOva.
  ///
  /// In en, this message translates to:
  /// **'OVA'**
  String get mediaFormatOva;

  /// No description provided for @mediaFormatSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get mediaFormatSpecial;

  /// No description provided for @mediaFormatTv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get mediaFormatTv;

  /// No description provided for @mediaFormatTvShort.
  ///
  /// In en, this message translates to:
  /// **'TV Short'**
  String get mediaFormatTvShort;

  /// No description provided for @mediaGenres.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Genre} other{Genres}}'**
  String mediaGenres(int count);

  /// No description provided for @mediaHashtag.
  ///
  /// In en, this message translates to:
  /// **'Hashtag'**
  String get mediaHashtag;

  /// No description provided for @mediaPopularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get mediaPopularity;

  /// No description provided for @mediaProducers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Producer} other{Producers}}'**
  String mediaProducers(int count);

  /// No description provided for @mediaRelationTypeAdaptation.
  ///
  /// In en, this message translates to:
  /// **'Adaptation'**
  String get mediaRelationTypeAdaptation;

  /// No description provided for @mediaRelationTypePrequel.
  ///
  /// In en, this message translates to:
  /// **'Prequel'**
  String get mediaRelationTypePrequel;

  /// No description provided for @mediaRelationTypeSequel.
  ///
  /// In en, this message translates to:
  /// **'Sequel'**
  String get mediaRelationTypeSequel;

  /// No description provided for @mediaRelationTypeParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get mediaRelationTypeParent;

  /// No description provided for @mediaRelationTypeSideStory.
  ///
  /// In en, this message translates to:
  /// **'Side Story'**
  String get mediaRelationTypeSideStory;

  /// No description provided for @mediaRelationTypeCharacter.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get mediaRelationTypeCharacter;

  /// No description provided for @mediaRelationTypeSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get mediaRelationTypeSummary;

  /// No description provided for @mediaRelationTypeAlternative.
  ///
  /// In en, this message translates to:
  /// **'Alternative'**
  String get mediaRelationTypeAlternative;

  /// No description provided for @mediaRelationTypeSpinOff.
  ///
  /// In en, this message translates to:
  /// **'Spin Off'**
  String get mediaRelationTypeSpinOff;

  /// No description provided for @mediaRelationTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get mediaRelationTypeOther;

  /// No description provided for @mediaRelationTypeSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get mediaRelationTypeSource;

  /// No description provided for @mediaRelationTypeCompilation.
  ///
  /// In en, this message translates to:
  /// **'Compilation'**
  String get mediaRelationTypeCompilation;

  /// No description provided for @mediaRelationTypeContains.
  ///
  /// In en, this message translates to:
  /// **'Contains'**
  String get mediaRelationTypeContains;

  /// No description provided for @mediaRelease.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get mediaRelease;

  /// No description provided for @mediaSeason.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get mediaSeason;

  /// No description provided for @mediaSeasonFall.
  ///
  /// In en, this message translates to:
  /// **'Fall'**
  String get mediaSeasonFall;

  /// No description provided for @mediaSeasonSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get mediaSeasonSpring;

  /// No description provided for @mediaSeasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get mediaSeasonSummer;

  /// No description provided for @mediaSeasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get mediaSeasonWinter;

  /// No description provided for @mediaSortAddedFirst.
  ///
  /// In en, this message translates to:
  /// **'First Added'**
  String get mediaSortAddedFirst;

  /// No description provided for @mediaSortAddedLast.
  ///
  /// In en, this message translates to:
  /// **'Last Added'**
  String get mediaSortAddedLast;

  /// No description provided for @mediaSortFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get mediaSortFavourites;

  /// No description provided for @mediaSortPopularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get mediaSortPopularity;

  /// No description provided for @mediaSortReleasedEarliest.
  ///
  /// In en, this message translates to:
  /// **'Released Earliest'**
  String get mediaSortReleasedEarliest;

  /// No description provided for @mediaSortReleasedLatest.
  ///
  /// In en, this message translates to:
  /// **'Released Latest'**
  String get mediaSortReleasedLatest;

  /// No description provided for @mediaSortScoreBest.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get mediaSortScoreBest;

  /// No description provided for @mediaSortScoreWorst.
  ///
  /// In en, this message translates to:
  /// **'Worst Score'**
  String get mediaSortScoreWorst;

  /// No description provided for @mediaSortTitleEnglish.
  ///
  /// In en, this message translates to:
  /// **'Title English'**
  String get mediaSortTitleEnglish;

  /// No description provided for @mediaSortTitleNative.
  ///
  /// In en, this message translates to:
  /// **'Title Native'**
  String get mediaSortTitleNative;

  /// No description provided for @mediaSortTitleRomaji.
  ///
  /// In en, this message translates to:
  /// **'Title Romaji'**
  String get mediaSortTitleRomaji;

  /// No description provided for @mediaSortTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get mediaSortTrending;

  /// No description provided for @mediaSource.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Source} other{Sources}}'**
  String mediaSource(int count);

  /// No description provided for @mediaSourceOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get mediaSourceOriginal;

  /// No description provided for @mediaSourceAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get mediaSourceAnime;

  /// No description provided for @mediaSourceComic.
  ///
  /// In en, this message translates to:
  /// **'Comic'**
  String get mediaSourceComic;

  /// No description provided for @mediaSourceDoujinshi.
  ///
  /// In en, this message translates to:
  /// **'Doujinshi'**
  String get mediaSourceDoujinshi;

  /// No description provided for @mediaSourceGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get mediaSourceGame;

  /// No description provided for @mediaSourceLightNovel.
  ///
  /// In en, this message translates to:
  /// **'Light Novel'**
  String get mediaSourceLightNovel;

  /// No description provided for @mediaSourceLiveAction.
  ///
  /// In en, this message translates to:
  /// **'Live Action'**
  String get mediaSourceLiveAction;

  /// No description provided for @mediaSourceManga.
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get mediaSourceManga;

  /// No description provided for @mediaSourceMultimediaProject.
  ///
  /// In en, this message translates to:
  /// **'Multimedia Project'**
  String get mediaSourceMultimediaProject;

  /// No description provided for @mediaSourceNovel.
  ///
  /// In en, this message translates to:
  /// **'Novel'**
  String get mediaSourceNovel;

  /// No description provided for @mediaSourceOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get mediaSourceOther;

  /// No description provided for @mediaSourcePictureBook.
  ///
  /// In en, this message translates to:
  /// **'Picture Book'**
  String get mediaSourcePictureBook;

  /// No description provided for @mediaSourceVideoGame.
  ///
  /// In en, this message translates to:
  /// **'Video Game'**
  String get mediaSourceVideoGame;

  /// No description provided for @mediaSourceVisualNovel.
  ///
  /// In en, this message translates to:
  /// **'Visual Novel'**
  String get mediaSourceVisualNovel;

  /// No description provided for @mediaSourceWebNovel.
  ///
  /// In en, this message translates to:
  /// **'Web Novel'**
  String get mediaSourceWebNovel;

  /// No description provided for @mediaStatus.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Status} other{Statuses}}'**
  String mediaStatus(int count);

  /// No description provided for @mediaStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get mediaStatusCancelled;

  /// No description provided for @mediaStatusHiatus.
  ///
  /// In en, this message translates to:
  /// **'Hiatus'**
  String get mediaStatusHiatus;

  /// No description provided for @mediaStatusReleased.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get mediaStatusReleased;

  /// No description provided for @mediaStatusReleasing.
  ///
  /// In en, this message translates to:
  /// **'Releasing'**
  String get mediaStatusReleasing;

  /// No description provided for @mediaStatusUnreleased.
  ///
  /// In en, this message translates to:
  /// **'Not Yet Released'**
  String get mediaStatusUnreleased;

  /// No description provided for @mediaScoreMean.
  ///
  /// In en, this message translates to:
  /// **'Mean Score'**
  String get mediaScoreMean;

  /// No description provided for @mediaScoreAverageWeighted.
  ///
  /// In en, this message translates to:
  /// **'Weighted Average Score\''**
  String get mediaScoreAverageWeighted;

  /// No description provided for @mediaScoring3.
  ///
  /// In en, this message translates to:
  /// **'3 Smileys'**
  String get mediaScoring3;

  /// No description provided for @mediaScoring5.
  ///
  /// In en, this message translates to:
  /// **'5 Stars'**
  String get mediaScoring5;

  /// No description provided for @mediaScoring10.
  ///
  /// In en, this message translates to:
  /// **'10 Points'**
  String get mediaScoring10;

  /// No description provided for @mediaScoring100.
  ///
  /// In en, this message translates to:
  /// **'100 Points'**
  String get mediaScoring100;

  /// No description provided for @mediaScoring10Decimal.
  ///
  /// In en, this message translates to:
  /// **'10 Decimal Points'**
  String get mediaScoring10Decimal;

  /// No description provided for @mediaTitleEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get mediaTitleEnglish;

  /// No description provided for @mediaTitleNative.
  ///
  /// In en, this message translates to:
  /// **'Native'**
  String get mediaTitleNative;

  /// No description provided for @mediaTitleRomaji.
  ///
  /// In en, this message translates to:
  /// **'Romaji'**
  String get mediaTitleRomaji;

  /// No description provided for @mediaTitleSynonym.
  ///
  /// In en, this message translates to:
  /// **'Synonym'**
  String get mediaTitleSynonym;

  /// No description provided for @mediaType.
  ///
  /// In en, this message translates to:
  /// **'Media Type'**
  String get mediaType;

  /// No description provided for @mediaTypeAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get mediaTypeAnime;

  /// No description provided for @mediaTypeManga.
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get mediaTypeManga;

  /// No description provided for @mediaVolumes.
  ///
  /// In en, this message translates to:
  /// **'Volumes'**
  String get mediaVolumes;

  /// No description provided for @numberDecrement.
  ///
  /// In en, this message translates to:
  /// **'Decrement'**
  String get numberDecrement;

  /// No description provided for @numberIncrement.
  ///
  /// In en, this message translates to:
  /// **'Increment'**
  String get numberIncrement;

  /// Minimum number value
  ///
  /// In en, this message translates to:
  /// **'Minimum {number}'**
  String numberMinimum(num number);

  /// Maximum number value
  ///
  /// In en, this message translates to:
  /// **'Maximum {number}'**
  String numberMaximum(num number);

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries'**
  String get noEntries;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @personInfoAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get personInfoAge;

  /// No description provided for @personInfoBirth.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get personInfoBirth;

  /// No description provided for @personInfoBloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get personInfoBloodType;

  /// No description provided for @personInfoDeath.
  ///
  /// In en, this message translates to:
  /// **'Death'**
  String get personInfoDeath;

  /// No description provided for @personInfoGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get personInfoGender;

  /// No description provided for @personInfoHomeTown.
  ///
  /// In en, this message translates to:
  /// **'Home Town'**
  String get personInfoHomeTown;

  /// No description provided for @personInfoNameAlternative.
  ///
  /// In en, this message translates to:
  /// **'Alternative'**
  String get personInfoNameAlternative;

  /// No description provided for @personInfoNameAlternativeSpoiler.
  ///
  /// In en, this message translates to:
  /// **'Alternative Spoiler'**
  String get personInfoNameAlternativeSpoiler;

  /// No description provided for @personInfoNameFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get personInfoNameFull;

  /// No description provided for @personInfoNameNative.
  ///
  /// In en, this message translates to:
  /// **'Native'**
  String get personInfoNameNative;

  /// No description provided for @personInfoYearsActive.
  ///
  /// In en, this message translates to:
  /// **'Years Active'**
  String get personInfoYearsActive;

  /// No description provided for @postsAdd.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get postsAdd;

  /// No description provided for @postsLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get postsLikes;

  /// No description provided for @postsLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get postsLocked;

  /// No description provided for @postsPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get postsPinned;

  /// No description provided for @postsPosted.
  ///
  /// In en, this message translates to:
  /// **'posted'**
  String get postsPosted;

  /// No description provided for @postsReplied.
  ///
  /// In en, this message translates to:
  /// **'replied'**
  String get postsReplied;

  /// No description provided for @postsReplies.
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get postsReplies;

  /// No description provided for @postsViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get postsViews;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @related.
  ///
  /// In en, this message translates to:
  /// **'Related'**
  String get related;

  /// No description provided for @replies.
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get replies;

  /// No description provided for @repliesAdd.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get repliesAdd;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @reviewsBy.
  ///
  /// In en, this message translates to:
  /// **'review by'**
  String get reviewsBy;

  /// The media being reviewed and the reviewer
  ///
  /// In en, this message translates to:
  /// **'Review of {mediaTitle} by {userName}'**
  String reviewsOfBy(String mediaTitle, String userName);

  /// No description provided for @reviewsRating.
  ///
  /// In en, this message translates to:
  /// **'Review Rating'**
  String get reviewsRating;

  /// How many people liked the review
  ///
  /// In en, this message translates to:
  /// **'{positiveRating}/{totalRating} users liked this review'**
  String reviewsRatingValue(int positiveRating, int totalRating);

  /// No description provided for @reviewsScore.
  ///
  /// In en, this message translates to:
  /// **'Review Score'**
  String get reviewsScore;

  /// No description provided for @reviewsSortHighestRated.
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get reviewsSortHighestRated;

  /// No description provided for @reviewsSortLowestRated.
  ///
  /// In en, this message translates to:
  /// **'Lowest Rated'**
  String get reviewsSortLowestRated;

  /// No description provided for @reviewsSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get reviewsSortNewest;

  /// No description provided for @reviewsSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get reviewsSortOldest;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchGlobally.
  ///
  /// In en, this message translates to:
  /// **'Search Globally'**
  String get searchGlobally;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsAboutClearImageCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Image Cache'**
  String get settingsAboutClearImageCache;

  /// No description provided for @settingsAboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'An unofficial AniList app'**
  String get settingsAboutDisclaimer;

  /// No description provided for @settingsAboutDiscord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get settingsAboutDiscord;

  /// No description provided for @settingsAboutDonate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get settingsAboutDonate;

  /// The last time a check for new notifications was done
  ///
  /// In en, this message translates to:
  /// **'Performed a notification check around {lastJobTimestamp}.'**
  String settingsAboutLastNotificationCheck(String lastJobTimestamp);

  /// No description provided for @settingsAboutPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsAboutPrivacyPolicy;

  /// No description provided for @settingsAboutResetOptions.
  ///
  /// In en, this message translates to:
  /// **'Reset Options'**
  String get settingsAboutResetOptions;

  /// No description provided for @settingsAboutSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get settingsAboutSourceCode;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsAppearanceModeDark;

  /// No description provided for @settingsAppearanceModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsAppearanceModeLight;

  /// No description provided for @settingsAppearanceModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsAppearanceModeSystem;

  /// No description provided for @settingsButtonOrientation.
  ///
  /// In en, this message translates to:
  /// **'Button Orientation'**
  String get settingsButtonOrientation;

  /// No description provided for @settingsButtonOrientationAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsButtonOrientationAuto;

  /// No description provided for @settingsButtonOrientationLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get settingsButtonOrientationLeft;

  /// No description provided for @settingsButtonOrientationRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get settingsButtonOrientationRight;

  /// No description provided for @settingsCollectionPreviews.
  ///
  /// In en, this message translates to:
  /// **'Collection Previews'**
  String get settingsCollectionPreviews;

  /// No description provided for @settingsCollectionPreviewsAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime Collection Preview'**
  String get settingsCollectionPreviewsAnime;

  /// No description provided for @settingsCollectionPreviewsAnimeDescription.
  ///
  /// In en, this message translates to:
  /// **'Only load your watched/rewatched anime and expand to full collection with the floating button'**
  String get settingsCollectionPreviewsAnimeDescription;

  /// No description provided for @settingsCollectionPreviewsManga.
  ///
  /// In en, this message translates to:
  /// **'Manga Collection Preview'**
  String get settingsCollectionPreviewsManga;

  /// No description provided for @settingsCollectionPreviewsMangaDescription.
  ///
  /// In en, this message translates to:
  /// **'Only load your read/reread manga and expand to full collection with the floating button'**
  String get settingsCollectionPreviewsMangaDescription;

  /// No description provided for @settingsConfirmExit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Exit'**
  String get settingsConfirmExit;

  /// No description provided for @settingsDefaults.
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get settingsDefaults;

  /// No description provided for @settingsHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get settingsHighContrast;

  /// No description provided for @settingsHighContrastDescription.
  ///
  /// In en, this message translates to:
  /// **'Pure backgrounds & outlined cards'**
  String get settingsHighContrastDescription;

  /// No description provided for @settingsHomeTab.
  ///
  /// In en, this message translates to:
  /// **'Home Tab'**
  String get settingsHomeTab;

  /// No description provided for @settingsImageQuality.
  ///
  /// In en, this message translates to:
  /// **'Image Quality'**
  String get settingsImageQuality;

  /// No description provided for @settingsListsCustomListsAnime.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Anime Custom List} other{Anime Custom Lists}}'**
  String settingsListsCustomListsAnime(int count);

  /// No description provided for @settingsListsCustomListsManga.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Manga Custom List} other{Manga Custom Lists}}'**
  String settingsListsCustomListsManga(int count);

  /// No description provided for @settingsListsDefaultSiteSort.
  ///
  /// In en, this message translates to:
  /// **'Default Site List Sort'**
  String get settingsListsDefaultSiteSort;

  /// No description provided for @settingsListsScoringAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced Scoring'**
  String get settingsListsScoringAdvanced;

  /// No description provided for @settingsListsScoringAdvancedSections.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Advanced Score Section} other{Advanced Score Sections}}'**
  String settingsListsScoringAdvancedSections(int count);

  /// No description provided for @settingsListsScoringSystem.
  ///
  /// In en, this message translates to:
  /// **'Scoring System'**
  String get settingsListsScoringSystem;

  /// No description provided for @settingsListsSplitAnime.
  ///
  /// In en, this message translates to:
  /// **'Split Completed Anime'**
  String get settingsListsSplitAnime;

  /// No description provided for @settingsListsSplitManga.
  ///
  /// In en, this message translates to:
  /// **'Split Completed Manga'**
  String get settingsListsSplitManga;

  /// No description provided for @settingsMediaActivityMergeTime.
  ///
  /// In en, this message translates to:
  /// **'Activity Merge Time'**
  String get settingsMediaActivityMergeTime;

  /// No description provided for @settingsMediaActivityMergeTimeAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get settingsMediaActivityMergeTimeAlways;

  /// Days that are less than a week
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String settingsMediaActivityMergeTimeDays(int count);

  /// Hours that are less than a day
  ///
  /// In en, this message translates to:
  /// **'{count} Hours'**
  String settingsMediaActivityMergeTimeHours(int count);

  /// Minutes that are less than an hour
  ///
  /// In en, this message translates to:
  /// **'{count} Minutes'**
  String settingsMediaActivityMergeTimeMinutes(int count);

  /// No description provided for @settingsMediaActivityMergeTimeNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settingsMediaActivityMergeTimeNever;

  /// Weeks that are less than 3
  ///
  /// In en, this message translates to:
  /// **'{count} Weeks'**
  String settingsMediaActivityMergeTimeWeeks(int count);

  /// No description provided for @settingsMediaAdult.
  ///
  /// In en, this message translates to:
  /// **'18+ Content'**
  String get settingsMediaAdult;

  /// No description provided for @settingsMediaAiringAnimeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Airing Anime Notifications'**
  String get settingsMediaAiringAnimeNotifications;

  /// No description provided for @settingsMediaPersonNaming.
  ///
  /// In en, this message translates to:
  /// **'Character & Staff Names'**
  String get settingsMediaPersonNaming;

  /// No description provided for @settingsMediaPersonNamingNative.
  ///
  /// In en, this message translates to:
  /// **'Native'**
  String get settingsMediaPersonNamingNative;

  /// No description provided for @settingsMediaPersonNamingRomaji.
  ///
  /// In en, this message translates to:
  /// **'Romaji'**
  String get settingsMediaPersonNamingRomaji;

  /// No description provided for @settingsMediaPersonNamingRomajiWestern.
  ///
  /// In en, this message translates to:
  /// **'Romaji, Western Order'**
  String get settingsMediaPersonNamingRomajiWestern;

  /// No description provided for @settingsMediaTitleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Title Language'**
  String get settingsMediaTitleLanguage;

  /// No description provided for @settingsMediaTitleLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsMediaTitleLanguageEnglish;

  /// No description provided for @settingsMediaTitleLanguageNative.
  ///
  /// In en, this message translates to:
  /// **'Native'**
  String get settingsMediaTitleLanguageNative;

  /// No description provided for @settingsMediaTitleLanguageRomaji.
  ///
  /// In en, this message translates to:
  /// **'Romaji'**
  String get settingsMediaTitleLanguageRomaji;

  /// Activities will be created for media with given status
  ///
  /// In en, this message translates to:
  /// **'Create {listStatus} activities'**
  String settingsSocialActivityCreation(String listStatus);

  /// No description provided for @settingsSocialLimitMessages.
  ///
  /// In en, this message translates to:
  /// **'Limit Messages'**
  String get settingsSocialLimitMessages;

  /// No description provided for @settingsSocialLimitMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Only users I follow can message me'**
  String get settingsSocialLimitMessagesDescription;

  /// No description provided for @settingsTabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsTabAbout;

  /// No description provided for @settingsTabApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsTabApp;

  /// No description provided for @settingsTabContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get settingsTabContent;

  /// No description provided for @settingsViewLayout.
  ///
  /// In en, this message translates to:
  /// **'View Layouts'**
  String get settingsViewLayout;

  /// No description provided for @settingsViewLayoutDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get settingsViewLayoutDetailed;

  /// No description provided for @settingsViewLayoutDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover View'**
  String get settingsViewLayoutDiscover;

  /// No description provided for @settingsViewLayoutCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection View'**
  String get settingsViewLayoutCollection;

  /// No description provided for @settingsViewLayoutCollectionPreview.
  ///
  /// In en, this message translates to:
  /// **'Collection Preview View'**
  String get settingsViewLayoutCollectionPreview;

  /// No description provided for @settingsViewLayoutSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get settingsViewLayoutSimple;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @statisticsScoreDistribution.
  ///
  /// In en, this message translates to:
  /// **'Score Distribution'**
  String get statisticsScoreDistribution;

  /// No description provided for @statisticsStatusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Status Distribution'**
  String get statisticsStatusDistribution;

  /// No description provided for @studios.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Studio} other{Studios}}'**
  String studios(int count);

  /// No description provided for @subscriptionAdd.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscriptionAdd;

  /// No description provided for @subscriptionRemove.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get subscriptionRemove;

  /// Media tags
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Tag} other{Tags}}'**
  String tags(int count);

  /// No description provided for @threads.
  ///
  /// In en, this message translates to:
  /// **'Threads'**
  String get threads;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
