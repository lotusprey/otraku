enum MediaListStatus {
  None,
  Watching,
  Reading,
  Planning,
  Completed,
  Dropped,
  Paused,
  Rewatching,
  Rereading,
}

extension MediaListStatusExtension on MediaListStatus {
  static const _fromEnum = {
    MediaListStatus.None: '',
    MediaListStatus.Watching: 'CURRENT',
    MediaListStatus.Reading: 'CURRENT',
    MediaListStatus.Planning: 'PLANNING',
    MediaListStatus.Completed: 'COMPLETED',
    MediaListStatus.Dropped: 'DROPPED',
    MediaListStatus.Paused: 'PAUSED',
    MediaListStatus.Rewatching: 'REPEATING',
    MediaListStatus.Rereading: 'REPEATING',
  };

  String get string => _fromEnum[this];
}

MediaListStatus getMediaListStatusFromString(String status, String mediaType) {
  switch (status) {
    case '':
      return MediaListStatus.None;
      break;
    case 'CURRENT':
      return mediaType == 'ANIME'
          ? MediaListStatus.Watching
          : MediaListStatus.Reading;
      break;
    case 'PLANNING':
      return MediaListStatus.Planning;
      break;
    case 'COMPLETED':
      return MediaListStatus.Completed;
      break;
    case 'DROPPED':
      return MediaListStatus.Dropped;
      break;
    case 'PAUSED':
      return MediaListStatus.Paused;
      break;
    case 'REPEATING':
      return mediaType == 'ANIME'
          ? MediaListStatus.Rewatching
          : MediaListStatus.Rereading;
      break;
    default:
      throw 'Invalid media status when converting from string';
  }
}