import 'package:get/get.dart';
import 'package:otraku/models/review_model.dart';
import 'package:otraku/utils/client.dart';

class ReviewController extends GetxController {
  // ***************************************************************************
  // CONSTANTS
  // ***************************************************************************

  static const _reviewQuery = r'''
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
        media {id type title {userPreferred} coverImage {large} bannerImage}
        user {id name avatar {large}}
      }
    }
  ''';

  static const _rateMutation = r'''
    mutation Rate($id: Int, $rating: ReviewRating) {
      RateReview(reviewId: $id, rating: $rating) {
        rating
        ratingAmount
        userRating
      }
    }
  ''';

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  final int _id;
  ReviewController(this._id);

  ReviewModel? _model;

  ReviewModel? get model => _model;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    final data = await Client.request(_reviewQuery, {'id': _id});
    if (data == null) return;
    _model = ReviewModel(data['Review']);
    update();
  }

  Future<void> rate(bool? rating) async {
    final data = await Client.request(_rateMutation, {
      'id': _id,
      'rating': rating == null
          ? 'NO_VOTE'
          : rating
              ? 'UP_VOTE'
              : 'DOWN_VOTE',
    });
    if (data == null) return;

    _model!.updateRating(data['RateReview']);
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
