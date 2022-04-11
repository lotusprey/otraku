class RelatedReviewModel {
  RelatedReviewModel._({
    required this.reviewId,
    required this.userId,
    required this.avatar,
    required this.username,
    required this.summary,
    required this.rating,
  });

  factory RelatedReviewModel(Map<String, dynamic> map) {
    if (map['user'] == null) throw ArgumentError.notNull('type');

    return RelatedReviewModel._(
      reviewId: map['id'],
      userId: map['user']['id'],
      username: map['user']['name'] ?? '',
      summary: map['summary'] ?? '',
      avatar: map['user']['avatar']['large'],
      rating: '${map['rating']}/${map['ratingAmount']}',
    );
  }

  final int reviewId;
  final int userId;
  final String username;
  final String avatar;
  final String summary;
  final String rating;
}
