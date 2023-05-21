abstract class GqlQuery {
  static const collection = r'''
    query Collection($userId: Int, $type: MediaType) {
      MediaListCollection(userId: $userId, type: $type) {
        lists {name isCustomList isSplitCompletedList status entries {...collectionEntry}}
        user {
          mediaListOptions {
            rowOrder
            scoreFormat
            animeList {sectionOrder splitCompletedSectionByFormat}
            mangaList {sectionOrder splitCompletedSectionByFormat}
          }
        }
      }
    }
  '''
      '${_GqlFragment.collectionEntry}';

  static const collectionPreview = r'''
    query CollectionPreview($userId: Int, $type: MediaType) {
      MediaListCollection(userId: $userId, type: $type, status_in: [CURRENT, REPEATING]) {
        lists {isCustomList entries {...collectionEntry}}
        user {mediaListOptions {scoreFormat}}
      }
    }
  '''
      '${_GqlFragment.collectionEntry}';

  static const listEntry = r'''
    query CollectionEntry($userId: Int, $mediaId: Int) {
      MediaList(userId: $userId, mediaId: $mediaId) {...collectionEntry}
    }
  '''
      '${_GqlFragment.collectionEntry}';

  static const media = r'''
    query Media($id: Int, $withInfo: Boolean = false, $withRecommendations: Boolean = false,
        $withCharacters: Boolean = false, $withStaff: Boolean = false,
        $withReviews: Boolean = false, $page: Int = 1) {
      Media(id: $id) {
        mediaListEntry @include(if: $withInfo) {...entry}
        ...info @include(if: $withInfo)
        ...recommendations @include (if: $withRecommendations)
        ...characters @include(if: $withCharacters)
        ...staff @include(if: $withStaff)
        ...reviews @include(if: $withReviews)
      }
    }
    fragment info on Media {
      id
      type
      title {userPreferred english romaji native}
      synonyms
      description
      coverImage {extraLarge large medium}
      bannerImage
      episodes
      chapters
      volumes
      format
      status(version: 2)
      startDate {year month day}
      endDate {year month day}
      nextAiringEpisode {episode airingAt}
      countryOfOrigin
      genres
      tags {id}
      isAdult
      hashtag
      isFavourite
      favourites
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
            coverImage {extraLarge large medium}
          }
        }
      }
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
    fragment recommendations on Media {
      recommendations(page: $page, sort: [RATING_DESC]) {
        pageInfo {hasNextPage}
        nodes {
          rating
          userRating
          mediaRecommendation {
            id
            type
            title {userPreferred}
            coverImage {extraLarge large medium}
          }
        }
      }
    }
    fragment characters on Media {
      characters(page: $page, sort: [ROLE, ID]) {
        pageInfo {hasNextPage}
        edges {
          role
          voiceActors {id name {userPreferred} languageV2 image {large}}
          node {id name {userPreferred} image {large}}
        }
      }
    }
    fragment staff on Media {
      staff(page: $page) {
        pageInfo {hasNextPage}
        edges {role node {id name {userPreferred} image {large}}}
      }
    }
    fragment reviews on Media {
      reviews(sort: RATING_DESC, page: $page) {
        pageInfo {hasNextPage}
        nodes {
          id
          summary
          rating
          ratingAmount
          user {id name avatar {large}}
        }
      }
    }
  ''';

  static const entry = r'''
    query Entry($mediaId: Int) {
      Media(id: $mediaId) {
        id
        type
        episodes
        chapters
        volumes
        mediaListEntry {
          id
          status
          progress
          progressVolumes
          repeat
          notes
          startedAt {year month day}
          completedAt {year month day}
          score
          advancedScores
          private
          hiddenFromStatusLists
          customLists
        }
      }
    }
  ''';

  static const medias = r'''
    query Media($page: Int, $type: MediaType, $search:String, $status_in: [MediaStatus],
        $format_in: [MediaFormat], $genre_in: [String], $genre_not_in: [String],
        $tag_in: [String], $tag_not_in: [String], $onList: Boolean, $startFrom: FuzzyDateInt,
        $startTo: FuzzyDateInt, $countryOfOrigin: CountryCode, $season: MediaSeason,
        $sources: [MediaSource], $isAdult: Boolean, $sort: [MediaSort]) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        media(type: $type, search: $search, status_in: $status_in, format_in: $format_in,
        genre_in: $genre_in, genre_not_in: $genre_not_in, tag_in: $tag_in, tag_not_in: $tag_not_in, 
        onList: $onList, startDate_greater: $startFrom, startDate_lesser: $startTo, isAdult: $isAdult,
        countryOfOrigin: $countryOfOrigin, season: $season, source_in: $sources, sort: $sort) {
          id
          type
          title {userPreferred}
          coverImage {extraLarge large medium}
          format
          status(version: 2)
          averageScore
          popularity
          startDate {year}
          isAdult
          mediaListEntry {status}
        }
      }
    }
  ''';

  static const character = r'''
    query Character($id: Int, $sort: [MediaSort], $page: Int = 1, $onList: Boolean,
        $withInfo: Boolean = false, $withAnime: Boolean = false, $withManga: Boolean = false) {
      Character(id: $id) {
        ...info @include(if: $withInfo)
        anime: media(page: $page, type: ANIME, onList: $onList, sort: $sort) 
          @include(if: $withAnime) {...media}
        manga: media(page: $page, type: MANGA, onList: $onList, sort: $sort) 
          @include(if: $withManga) {...media}
      }
    }
    fragment info on Character {
      id
      name{userPreferred native alternative alternativeSpoiler}
      image{large}
      description(asHtml: true)
      dateOfBirth{year month day}
      bloodType
      gender
      age
      favourites 
      isFavourite
    }
    fragment media on MediaConnection {
      pageInfo {hasNextPage}
      edges {
        characterRole
        voiceActors(sort: [LANGUAGE]) {id name {userPreferred} image {large} languageV2}
        node {id type title {userPreferred} coverImage {extraLarge large medium}}
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
    query Staff($id: Int, $sort: [MediaSort], $page: Int = 1, $type: MediaType, $onList: Boolean,
        $withInfo: Boolean = false, $withCharacters: Boolean = false, $withRoles: Boolean = false) {
      Staff(id: $id) {
        ...info @include(if: $withInfo)
        characterMedia(page: $page, sort: $sort, onList: $onList) @include(if: $withCharacters) {
          pageInfo {hasNextPage}
          edges {
            characterRole
            node {
              id
              type
              title {userPreferred}
              coverImage {extraLarge large medium}
              format
            }
            characters {
              id
              name {userPreferred}
              image {large}
            }
          }
        }
        staffMedia(page: $page, sort: $sort, type: $type, onList: $onList) @include(if: $withRoles) {
          pageInfo {hasNextPage}
          edges {
            staffRole
            node {
              id
              type
              title {userPreferred}
              coverImage {extraLarge large medium}
            }
          }
        }
      }
    }
    fragment info on Staff {
      id
      name{userPreferred native alternative}
      image{large}
      description(asHtml: true)
      dateOfBirth{year month day}
      dateOfDeath{year month day}
      gender
      age
      yearsActive
      bloodType
      homeTown
      favourites 
      isFavourite
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
    query Studio($id: Int, $page: Int = 1, $sort: [MediaSort], $onList: Boolean, $isMain: Boolean, $withInfo: Boolean = false) {
      Studio(id: $id) {
        ...info @include(if: $withInfo)
        media(page: $page, sort: $sort, onList: $onList, isMain: $isMain) {
          pageInfo {hasNextPage}
          nodes {
            id
            title {userPreferred}
            coverImage {extraLarge large medium}
            startDate {year}
            endDate {year}
            status(version: 2)
          }
        }
      }
    }
    fragment info on Studio {id name favourites isFavourite}
  ''';

  static const studios = r'''
    query Studios($page: Int, $search: String) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        studios(search: $search, sort: FAVOURITES_DESC) {id name}
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
        siteUrl
        media {id type title {userPreferred} coverImage {extraLarge large medium} bannerImage}
        user {id name avatar {large}}
      }
    }
  ''';

  static const reviews = r'''
    query Reviews($userId: Int, $page: Int = 1, $sort: [ReviewSort] = [CREATED_AT_DESC]) {
      Page(page: $page) {
        pageInfo {hasNextPage total}
        reviews(userId: $userId, sort: $sort) {
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
      query User($userId: Int) {
        User(id: $userId) {
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
          statistics {anime {...stats} manga {...stats}}
        }
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
    ''';

  static const favorites = r'''
    query Favorites($userId: Int, $page: Int = 1, $withAnime: Boolean = false,
      $withManga: Boolean = false, $withCharacters: Boolean = false,
      $withStaff: Boolean = false, $withStudios: Boolean = false) {
      User(id: $userId) {
        favourites {
          anime(page: $page) @include(if: $withAnime) {...media}
          manga(page: $page) @include(if: $withManga) {...media}
          characters(page: $page) @include(if: $withCharacters) {...character}
          staff(page: $page) @include(if: $withStaff) {...staff}
          studios(page: $page) @include(if: $withStudios) {...studio}
        }
      }
    }
    fragment media on MediaConnection {pageInfo {hasNextPage total} nodes {id title {userPreferred} coverImage {extraLarge large medium}}}
    fragment character on CharacterConnection {pageInfo {hasNextPage total} nodes {id name {userPreferred} image {large}}}
    fragment staff on StaffConnection {pageInfo {hasNextPage total} nodes {id name {userPreferred} image {large}}}
    fragment studio on StudioConnection {pageInfo {hasNextPage total} nodes {id name}}
  ''';

  static const friends = r'''
    query Friends($userId: Int!, $page: Int = 1, $withFollowing: Boolean = false, $withFollowers: Boolean = false) {
      following: Page(page: $page) @include(if: $withFollowing) {
        pageInfo {hasNextPage total}
        following(userId: $userId, sort: USERNAME) {id name avatar {large}}
      }
      followers: Page(page: $page) @include(if: $withFollowers) {
        pageInfo {hasNextPage total}
        followers(userId: $userId, sort: USERNAME) {id name avatar {large}}
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
    query Activities($userId: Int, $userIdNot: Int, $page: Int = 1, $isFollowing: Boolean,
        $hasRepliesOrText: Boolean, $typeIn: [ActivityType], $createdBefore: Int) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        activities(userId: $userId, userId_not: $userIdNot, isFollowing: $isFollowing,
            hasRepliesOrTypeText: $hasRepliesOrText, type_in: $typeIn, sort: [PINNED, ID_DESC],
            createdAt_lesser: $createdBefore) {
          ... on TextActivity {...textActivity}
          ... on ListActivity {...listActivity}
          ... on MessageActivity {...messageActivity}
        }
      }
    }
  '''
      '${_GqlFragment.textActivity}${_GqlFragment.listActivity}${_GqlFragment.messageActivity}';

  static const settings = r'''
    query Settings($withData: Boolean = true) {
      Viewer {
        unreadNotificationCount
        ...userSettings @include(if: $withData)
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
          ... on ActivityMentionNotification {
            id
            type
            activityId
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
          ... on ActivityLikeNotification {
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
          ... on ActivityReplyLikeNotification {
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
          ... on ThreadLikeNotification {
            id
            type
            thread {id title siteUrl}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentLikeNotification {
            id
            type
            thread {title}
            comment {siteUrl}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentReplyNotification {
            id
            type
            context
            thread {title}
            comment {siteUrl}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentMentionNotification {
            id
            type
            thread {title}
            comment {siteUrl}
            user {id name avatar {large}}
            createdAt
          }
          ... on ThreadCommentSubscribedNotification {
            id
            type
            thread {title}
            comment {siteUrl}
            user {id name avatar {large}}
            createdAt
          }
          ... on AiringNotification {
            id
            type
            episode
            media {id type title {userPreferred} coverImage {extraLarge large medium}}
            createdAt
          }
          ... on RelatedMediaAdditionNotification {
            id
            type
            media {id type title {userPreferred} coverImage {extraLarge large medium}}
            createdAt
          }
          ... on MediaDataChangeNotification {
            id
            type
            reason
            media {id type title {userPreferred} coverImage {extraLarge large medium}}
            createdAt
          }
          ... on MediaMergeNotification {
            id
            type
            reason
            deletedMediaTitles
            media {id type title {userPreferred} coverImage {extraLarge large medium}}
            createdAt
          }
          ... on MediaDeletionNotification {
            id
            type
            reason
            deletedMediaTitle
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
        advancedScores: $advancedScores) {id}
    }
  ''';

  static const updateProgress = r'''
    mutation UpdateProgress($mediaId: Int, $progress: Int) {
      SaveMediaListEntry(mediaId: $mediaId, progress: $progress) {customLists}
    }
  ''';

  static const removeEntry = r'''
    mutation RemoveEntry($entryId: Int) {DeleteMediaListEntry(id: $entryId) {deleted}}
  ''';

  static const updateSettings = r'''
    mutation UpdateSettings($titleLanguage: UserTitleLanguage, $staffNameLanguage: UserStaffNameLanguage, 
        $activityMergeTime: Int, $displayAdultContent: Boolean, $airingNotifications: Boolean, 
        $scoreFormat: ScoreFormat, $rowOrder: String, $notificationOptions: [NotificationOptionInput], 
        $splitCompletedAnime: Boolean, $splitCompletedManga: Boolean, $restrictMessagesToFollowing: Boolean,
        $advancedScoringEnabled: Boolean, $advancedScoring: [String], $disabledListActivity: [ListActivityOptionInput]) {
      UpdateUser(titleLanguage: $titleLanguage, staffNameLanguage: $staffNameLanguage,
          activityMergeTime: $activityMergeTime, displayAdultContent: $displayAdultContent, 
          airingNotifications: $airingNotifications, restrictMessagesToFollowing: $restrictMessagesToFollowing,
          scoreFormat: $scoreFormat, rowOrder: $rowOrder, notificationOptions: $notificationOptions,
          disabledListActivity: $disabledListActivity,
          animeListOptions: {splitCompletedSectionByFormat: $splitCompletedAnime,
          advancedScoringEnabled: $advancedScoringEnabled, advancedScoring: $advancedScoring},
          mangaListOptions: {splitCompletedSectionByFormat: $splitCompletedManga}) {
        ...userSettings
      }
    }
  '''
      '${_GqlFragment.userSettings}';

  static const toggleFavorite = r'''
    mutation ToggleFavorite($anime: Int, $manga: Int, $character: Int, $staff: Int, $studio: Int) {
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

  static const rateRecommendation = r'''
    mutation RateRecommendation($id: Int, $recommendedId: Int, $rating: RecommendationRating) {
      SaveRecommendation(mediaId: $id, mediaRecommendationId: $recommendedId, rating: $rating) {id}
    }
  ''';

  static const saveStatusActivity = r'''
    mutation SaveStatusActivity($id: Int, $text: String) {
      SaveTextActivity(id: $id, text: $text) {...textActivity}
    }
  '''
      '${_GqlFragment.textActivity}';

  static const saveMessageActivity = r'''
    mutation SaveMessageActivity($id: Int, $recipientId: Int, $text: String, $private: Boolean) {
      SaveMessageActivity(id: $id, recipientId: $recipientId, message: $text, private: $private) {...messageActivity}
    }
  '''
      '${_GqlFragment.messageActivity}';

  static const saveActivityReply = r'''
    mutation SaveActivityReply($id: Int, $activityId: Int, $text: String) {
      SaveActivityReply(id: $id, activityId: $activityId, text: $text) {
        id
        likeCount
        isLiked
        createdAt
        text(asHtml: true)
        user {id name avatar {large}}
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

  static const toggleActivityPin = r'''
    mutation ToggleActivityPin($id: Int, $pinned: Boolean) {
      ToggleActivityPin(id: $id, pinned: $pinned) {
        ... on ListActivity {isPinned}
        ... on TextActivity {isPinned}
      }
    }
  ''';

  static const deleteActivity = r'''
    mutation DeleteActivity($id: Int) {DeleteActivity(id: $id) {deleted}}
  ''';

  static const deleteActivityReply = r'''
    mutation DeleteActivityReply($id: Int) {DeleteActivityReply(id: $id) {deleted}}
  ''';
}

abstract class _GqlFragment {
  static const collectionEntry = r'''
    fragment collectionEntry on MediaList {
      status
      progress
      score
      notes
      repeat
      startedAt {year month day}
      completedAt {year month day}
      createdAt
      updatedAt
      media {
        id
        title {userPreferred romaji english native}
        coverImage {extraLarge large medium}
        format
        status
        episodes
        chapters
        averageScore
        genres
        tags {id}
        nextAiringEpisode {episode airingAt}
        startDate {year month day}
        countryOfOrigin
      }
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
        restrictMessagesToFollowing
        disabledListActivity {type disabled}
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
      isPinned
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
      isPinned
      createdAt
      siteUrl
      user {id name avatar {large}}
      media {id type title {userPreferred} coverImage {extraLarge large medium} format}
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
