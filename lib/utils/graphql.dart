abstract class GqlQuery {
  static const collection = r'''
    query Collection($userId: Int, $type: MediaType) {
      MediaListCollection(userId: $userId, type: $type) {
        lists {name isCustomList isSplitCompletedList status entries {...entry media{...main}}}
        user {
          mediaListOptions {
            rowOrder
            scoreFormat
            animeList {sectionOrder customLists splitCompletedSectionByFormat}
            mangaList {sectionOrder customLists splitCompletedSectionByFormat}
          }
        }
      }
    }
  '''
      '${_GqlFragment.mediaMain}';

  static const media = r'''
    query Media($id: Int, $withMain: Boolean = false, $withDetails: Boolean = false,
        $withCharacters: Boolean = false, $withStaff: Boolean = false,
        $withReviews: Boolean = false, $characterPage: Int = 1,
        $staffPage: Int = 1, $reviewPage: Int = 1) {
      Media(id: $id) {
        ...main @include(if: $withMain)
        mediaListEntry @include(if: $withMain) {...entry}
        ...details @include(if: $withDetails)
        ...reviews @include(if: $withReviews)
        ...characters @include(if: $withCharacters)
        ...staff @include(if: $withStaff)
      }
    }
    fragment details on Media {
      synonyms
      bannerImage
      isFavourite
      favourites
      description
      duration
      season
      seasonYear
      averageScore
      meanScore
      popularity
      studios {edges {isMain node {id name}}}
      tags {name description rank isMediaSpoiler isGeneralSpoiler}
      source
      hashtag
      siteUrl
      rankings {rank type year season allTime}
      stats {scoreDistribution {score amount} statusDistribution {status amount}}
      relations {
        edges {
          relationType(version: 2)
          node {
            id
            type
            format
            title {userPreferred} 
            status(version: 2)
            coverImage {extraLarge}
          }
        }
      }
    }
    fragment characters on Media {
      characters(page: $characterPage, sort: [ROLE, ID]) {
        pageInfo {hasNextPage}
        edges {
          role
          voiceActors {id name {userPreferred} language image {large}}
          node {id name {userPreferred} image {large}}
        }
      }
    }
    fragment staff on Media {
      staff(page: $staffPage) {
        pageInfo {hasNextPage}
        edges {role node {id name {userPreferred} image {large}}}
      }
    }
    fragment reviews on Media {
      reviews(sort: RATING_DESC, page: $reviewPage) {
        pageInfo {hasNextPage}
        nodes {
          id
          summary
          rating
          ratingAmount
          user {id name avatar{large}}
        }
      }
    }
  '''
      '${_GqlFragment.mediaMain}';

  static const medias = r'''
    query Media($page: Int, $type: MediaType, $search:String, $status_in: [MediaStatus],
        $status_not_in: [MediaStatus], $format_in: [MediaFormat], $format_not_in: [MediaFormat], 
        $genre_in: [String], $genre_not_in: [String], $tag_in: [String], $tag_not_in: [String], 
        $onList: Boolean, $isAdult: Boolean, $startDate_greater: FuzzyDateInt, 
        $startDate_lesser: FuzzyDateInt, $countryOfOrigin: CountryCode, $source: MediaSource, 
        $season: MediaSeason, $sort: [MediaSort]) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        media(type: $type, search: $search, status_in: $status_in, status_not_in: $status_not_in, 
        format_in: $format_in, format_not_in: $format_not_in, genre_in: $genre_in, 
        genre_not_in: $genre_not_in, tag_in: $tag_in, tag_not_in: $tag_not_in, 
        onList: $onList, isAdult: $isAdult, startDate_greater: $startDate_greater, 
        startDate_lesser: $startDate_lesser, countryOfOrigin: $countryOfOrigin, 
        source: $source, season: $season, sort: $sort) {
          id type title {userPreferred} coverImage {extraLarge}
        }
      }
    }
  ''';

  static const character = r'''
    query Character($id: Int, $sort: [MediaSort], $animePage: Int = 1, $mangaPage: Int = 1, 
        $onList: Boolean, $withMain: Boolean = false, $withAnime: Boolean = false, $withManga: Boolean = false) {
      Character(id: $id) {
        ...main @include(if: $withMain)
        anime: media(page: $animePage, type: ANIME, onList: $onList, sort: $sort) 
          @include(if: $withAnime) {...media}
        manga: media(page: $mangaPage, type: MANGA, onList: $onList, sort: $sort) 
          @include(if: $withManga) {...media}
      }
    }
    fragment main on Character {
      id
      name{userPreferred native alternative alternativeSpoiler}
      image{large}
      description(asHtml: true)
      dateOfBirth{year month day}
      gender
      age
      favourites 
      isFavourite
      isFavouriteBlocked
    }
    fragment media on MediaConnection {
      pageInfo {hasNextPage}
      edges {
        characterRole
        voiceActors(sort: [LANGUAGE]) {id name {userPreferred} image {large} language}
        node {id type title {userPreferred} coverImage {extraLarge}}
      }
    }
  ''';

  static const characters = r'''
    query Characters($page: Int, $search: String, $isBirthday: Boolean) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        characters(search: $search, sort: FAVOURITES_DESC, isBirthday: $isBirthday) {
          id name {userPreferred} image {large}
        }
      }
    }
  ''';

  static const staff = r'''
    query Staff($id: Int, $sort: [MediaSort], $characterPage: Int = 1, $staffPage: Int = 1, 
        $onList: Boolean, $withMain: Boolean = false, $withCharacters: Boolean = false, $withStaff: Boolean = false) {
      Staff(id: $id) {
        ...main @include(if: $withMain)
        characterMedia(page: $characterPage, sort: $sort, onList: $onList) @include(if: $withCharacters) {
          pageInfo {hasNextPage}
          edges {
            characterRole
            node {
              id
              type
              title {userPreferred}
              coverImage {extraLarge}
              format
            }
            characters {
              id
              name {userPreferred}
              image {large}
            }
          }
        }
        staffMedia(page: $staffPage, sort: $sort, onList: $onList) @include(if: $withStaff) {
          pageInfo {hasNextPage}
          edges {
            staffRole
            node {
              id
              type
              title {userPreferred}
              coverImage {extraLarge}
            }
          }
        }
      }
    }
    fragment main on Staff {
      id
      name{userPreferred native alternative}
      image{large}
      description(asHtml: true)
      languageV2
      primaryOccupations
      dateOfBirth{year month day}
      dateOfDeath{year month day}
      gender
      age
      yearsActive
      homeTown
      favourites 
      isFavourite
      isFavouriteBlocked
    }
  ''';

  static const staffs = r'''
    query Staff($page: Int, $search: String, $isBirthday: Boolean) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        staff(search: $search, sort: FAVOURITES_DESC, isBirthday: $isBirthday) {
          id name {userPreferred} image {large}
        }
      }
    }
  ''';

  static const studio = r'''
    query Studio($id: Int, $page: Int = 1, $sort: [MediaSort], $isMain: Boolean, $onList: Boolean, $withMain: Boolean = false) {
      Studio(id: $id) {
        ...studio @include(if: $withMain)
        media(page: $page, sort: $sort, isMain: $isMain, onList: $onList) {
          pageInfo {hasNextPage}
          nodes {
            id
            title {userPreferred}
            coverImage {extraLarge}
            startDate {year}
            status(version: 2)
          }
        }
      }
    }
    fragment studio on Studio {id name favourites isFavourite isAnimationStudio}
  ''';

  static const studios = r'''
    query Studios($page: Int, $search: String) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        studios(search: $search) {id name}
      }
    }
  ''';

  static const review = r'''
    query Review($id: Int) {
      Review(id: $id) {
        id
        summary
        body(asHtml: true)
        score
        rating
        ratingAmount
        userRating
        createdAt
        media {id type title {userPreferred} coverImage {extraLarge} bannerImage}
        user {id name avatar {large}}
      }
    }
  ''';

  static const reviews = r'''
    query Reviews($userId: Int, $page: Int = 1) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        reviews(userId: $userId, sort: CREATED_AT_DESC) {
          id
          summary 
          body(asHtml: true)
          rating
          ratingAmount
          media {id type title {userPreferred} bannerImage}
          user {id name}
        }
      }
    }
  ''';

  static const users = r'''
    query Users($page: Int, $search: String) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        users(search: $search) {id name avatar {large}}
      }
    }
  ''';

  static const user = r'''
      query User($id: Int, $page: Int = 1, $withMain: Boolean = false, $withStats: Boolean = false,
        $withAnime: Boolean = false, $withManga: Boolean = false, $withCharacters: Boolean = false,
        $withStaff: Boolean = false, $withStudios: Boolean = false) {
        User(id: $id) {
          ...main @include(if: $withMain)
          statistics @include(if: $withStats) {anime {...stats} manga {...stats}}
          favourites {
            anime(page: $page) @include(if: $withAnime) {...media}
            manga(page: $page) @include(if: $withManga) {...media}
            characters(page: $page) @include(if: $withCharacters) {...character}
            staff(page: $page) @include(if: $withStaff) {...staff}
            studios(page: $page) @include(if: $withStudios) {...studio}
          }
        }
      }
      fragment main on User {
        id
        name
        about(asHtml: true)
        avatar {large}
        bannerImage
        isFollowing
        isFollower
        isBlocked
        siteUrl
        donatorTier
        donatorBadge
        moderatorRoles
      }
      fragment stats on UserStatistics {
        count
        meanScore
        standardDeviation
        minutesWatched
        episodesWatched
        chaptersRead
        volumesRead
        scores(sort: MEAN_SCORE) {count meanScore minutesWatched chaptersRead score}
        lengths {count meanScore minutesWatched chaptersRead length}
        formats {count meanScore minutesWatched chaptersRead format}
        statuses {count meanScore minutesWatched chaptersRead status}
        countries {count meanScore minutesWatched chaptersRead country}
      }
      fragment media on MediaConnection {pageInfo {hasNextPage} nodes {id title {userPreferred} coverImage {extraLarge}}}
      fragment character on CharacterConnection {pageInfo {hasNextPage} nodes {id name {userPreferred} image {large}}}
      fragment staff on StaffConnection {pageInfo {hasNextPage} nodes {id name {userPreferred} image {large}}}
      fragment studio on StudioConnection {pageInfo {hasNextPage} nodes {id name}}
    ''';

  static const friends = r'''
    query Friends($id: Int!, $page: Int = 1, $withFollowing: Boolean = false, $withFollowers: Boolean = false) {
      following: Page(page: $page) @include(if: $withFollowing) {
        pageInfo {hasNextPage}
        following(userId: $id, sort: USERNAME) {id name avatar {large}}
      }
      followers: Page(page: $page) @include(if: $withFollowers) {
        pageInfo {hasNextPage}
        followers(userId: $id, sort: USERNAME) {id name avatar {large}}
      }
    }
  ''';

  static const activity = r'''
    query Activity($id: Int, $withActivity: Boolean = false, $page: Int = 1) {
      Activity(id: $id) @include(if: $withActivity) {
        ... on TextActivity {...textActivity}
        ... on ListActivity {...listActivity}
        ... on MessageActivity {...messageActivity}
      }
      Page(page: $page) {
        pageInfo {hasNextPage}
        activityReplies(activityId: $id) {
          id
          likeCount
          isLiked
          createdAt
          text(asHtml: true)
          user {id name avatar {large}}
        }
      }
    }
  '''
      '${_GqlFragment.textActivity}${_GqlFragment.listActivity}${_GqlFragment.messageActivity}';

  static const activities = r'''
    query Activities($userId: Int, $page: Int = 1, $isFollowing: Boolean, $hasRepliesOrTypeText: Boolean, $typeIn: [ActivityType]) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        activities(userId: $userId, isFollowing: $isFollowing, hasRepliesOrTypeText: $hasRepliesOrTypeText, type_in: $typeIn, sort: ID_DESC) {
          ... on TextActivity {...textActivity}
          ... on ListActivity {...listActivity}
          ... on MessageActivity {...messageActivity}
        }
      }
    }
  '''
      '${_GqlFragment.textActivity}${_GqlFragment.listActivity}${_GqlFragment.messageActivity}';

  static const settings = r'''
    query Settings {
      Viewer {
        unreadNotificationCount
        ...userSettings
    }
  }
  '''
      '${_GqlFragment.userSettings}';

  static const notifications = r'''
    query Notifications($page: Int = 1, $filter: [NotificationType],
        $withCount: Boolean = false, $resetCount: Boolean = false) {
      Viewer @include(if: $withCount) {unreadNotificationCount}
      Page(page: $page) {
        pageInfo {hasNextPage}
        notifications(type_in: $filter, resetNotificationCount: $resetCount) {
          ... on FollowingNotification {
            id
            type
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityMessageNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplyNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplySubscribedNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentReplyNotification {
            id
            type
            context
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityMentionNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentMentionNotification {
            id
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentSubscribedNotification {
            id
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityLikeNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ActivityReplyLikeNotification {
            id
            type
            activityId
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadLikeNotification {
            id
            type
            thread {id title}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentLikeNotification {
            id
            type
            commentId
            thread {title}
            user {id name avatar {large}}
            createdAt
          }
          ... on RelatedMediaAdditionNotification {
            id
            type
            media {id type title {userPreferred} coverImage {extraLarge}}
            createdAt
          }
          ... on MediaDataChangeNotification {
            id
            type
            reason
            media {id type title {userPreferred} coverImage {extraLarge}}
            createdAt
          }
          ... on MediaMergeNotification {
            id
            type
            reason
            deletedMediaTitles
            media {id type title {userPreferred} coverImage {extraLarge}}
            createdAt
          }
          ... on MediaDeletionNotification {
            id
            type
            reason
            deletedMediaTitle
            createdAt
          }
          ... on AiringNotification {
            id
            type
            episode
            media {id type title {userPreferred} coverImage {extraLarge}}
            createdAt
          }
        }
      }
    }
  ''';
}

abstract class GqlMutation {
  static const updateEntry = r'''
    mutation UpdateEntry($mediaId: Int, $status: MediaListStatus,
        $score: Float, $progress: Int, $progressVolumes: Int, $repeat: Int,
        $private: Boolean, $notes: String, $hiddenFromStatusLists: Boolean,
        $customLists: [String], $startedAt: FuzzyDateInput, $completedAt: FuzzyDateInput,
        $advancedScores: [Float]) {
      SaveMediaListEntry(mediaId: $mediaId, status: $status, score: $score,
        progress: $progress, progressVolumes: $progressVolumes, repeat: $repeat,
        private: $private, notes: $notes, hiddenFromStatusLists: $hiddenFromStatusLists,
        customLists: $customLists, startedAt: $startedAt, completedAt: $completedAt,
        advancedScores: $advancedScores) {...entry media{...main}}
    }
  '''
      '${_GqlFragment.mediaMain}';

  static const updateProgress = r'''
    mutation UpdateProgress($mediaId: Int, $progress: Int) {
      SaveMediaListEntry(mediaId: $mediaId, progress: $progress) {...entry media{...main}}
    }
  '''
      '${_GqlFragment.mediaMain}';

  static const removeEntry = r'''
    mutation RemoveEntry($entryId: Int) {DeleteMediaListEntry(id: $entryId) {deleted}}
  ''';

  static const updateSettings = r'''
    mutation UpdateSettings($about: String, $titleLanguage: UserTitleLanguage, $staffNameLanguage: UserStaffNameLanguage, 
        $activityMergeTime: Int, $displayAdultContent: Boolean, $airingNotifications: Boolean, 
        $scoreFormat: ScoreFormat, $rowOrder: String, $notificationOptions: [NotificationOptionInput], 
        $splitCompletedAnime: Boolean, $splitCompletedManga: Boolean, $advancedScoringEnabled: Boolean, $advancedScoring: [String]) {
      UpdateUser(about: $about, titleLanguage: $titleLanguage, staffNameLanguage: $staffNameLanguage,
          activityMergeTime: $activityMergeTime, displayAdultContent: $displayAdultContent, 
          airingNotifications: $airingNotifications, scoreFormat: $scoreFormat,
          rowOrder: $rowOrder, notificationOptions: $notificationOptions,
          animeListOptions: {splitCompletedSectionByFormat: $splitCompletedAnime, 
          advancedScoringEnabled: $advancedScoringEnabled, advancedScoring: $advancedScoring},
          mangaListOptions: {splitCompletedSectionByFormat: $splitCompletedManga}) {
        ...userSettings
      }
    }
  '''
      '${_GqlFragment.userSettings}';

  static const toggleFavourite = r'''
    mutation ToggleFavourite($anime: Int, $manga: Int, $character: Int, $staff: Int, $studio: Int) {
      ToggleFavourite(animeId: $anime, mangaId: $manga, characterId: $character, staffId: $staff, studioId: $studio) {
        anime(page: 1, perPage: 1) {nodes{isFavourite}}
        manga(page: 1, perPage: 1) {nodes{isFavourite}}
        characters(page: 1, perPage: 1) {nodes{isFavourite}}
        staff(page: 1, perPage: 1) {nodes{isFavourite}}
        studios(page: 1, perPage: 1) {nodes{isFavourite}}
      }
    }
  ''';

  static const toggleFollow =
      r'''mutation ToggleFollow($userId: Int) {ToggleFollow(userId: $userId) {isFollowing}}''';

  static const rateReview = r'''
    mutation RateReview($id: Int, $rating: ReviewRating) {
      RateReview(reviewId: $id, rating: $rating) {
        rating
        ratingAmount
        userRating
      }
    }
  ''';

  static const toggleLike = r'''
    mutation ToggleLike($id: Int, $type: LikeableType) {
      ToggleLikeV2(id: $id, type: $type) {
        ... on ListActivity {likeCount isLiked}
        ... on TextActivity {likeCount isLiked}
        ... on MessageActivity {likeCount isLiked}
        ... on ActivityReply {likeCount isLiked}
      }
    }
  ''';

  static const toggleActivitySubscription = r'''
    mutation ToggleActivitySubscription($id: Int, $subscribe: Boolean) {
      ToggleActivitySubscription(activityId: $id, subscribe: $subscribe) {
        ... on ListActivity {isSubscribed}
        ... on TextActivity {isSubscribed}
        ... on MessageActivity {isSubscribed}
      }
    }
  ''';

  static const deleteActivity = r'''
    mutation DeleteActivity($id: Int) {DeleteActivity(id: $id) {deleted}}
  ''';
}

abstract class _GqlFragment {
  static const mediaMain = r'''
    fragment main on Media {
      id
      type
      episodes
      chapters
      volumes
      title {userPreferred english romaji native}
      format
      status(version: 2)
      startDate {year month day}
      endDate {year month day}
      coverImage {extraLarge}
      nextAiringEpisode {episode airingAt}
      countryOfOrigin
      genres
      tags {id}
    }
    fragment entry on MediaList {
      id
      status
      progress
      progressVolumes
      score
      repeat
      notes
      startedAt {year month day}
      completedAt {year month day}
      private
      hiddenFromStatusLists
      customLists
      advancedScores
      updatedAt
      createdAt
    }
  ''';

  static const userSettings = r'''
    fragment userSettings on User {
      options {
        titleLanguage 
        staffNameLanguage
        activityMergeTime
        displayAdultContent
        airingNotifications
        notificationOptions {type enabled}
      }
      mediaListOptions {
        scoreFormat
        rowOrder
        animeList {splitCompletedSectionByFormat customLists advancedScoring advancedScoringEnabled}
        mangaList {splitCompletedSectionByFormat customLists}
      }
    }  
  ''';

  static const textActivity = r'''
    fragment textActivity on TextActivity {
      id
      type
      replyCount
      likeCount
      isLiked
      isSubscribed
      createdAt
      siteUrl
      user {id name avatar {large}}
      text(asHtml: true)
    }
  ''';

  static const listActivity = r'''
    fragment listActivity on ListActivity {
      id
      type
      replyCount
      likeCount
      isLiked
      isSubscribed
      createdAt
      siteUrl
      user {id name avatar {large}}
      media {id type title {userPreferred} coverImage {extraLarge} format}
      progress
      status
    }
  ''';

  static const messageActivity = r'''
    fragment messageActivity on MessageActivity {
      id
      type
      replyCount
      likeCount
      isLiked
      isSubscribed
      isPrivate
      createdAt
      siteUrl
      recipient {id name avatar {large}}
      messenger {id name avatar {large}}
      message(asHtml: true)
    }
  ''';
}
