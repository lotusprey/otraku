import 'package:get/get.dart';
import 'package:otraku/models/anilist/review_model.dart';
import 'package:otraku/helpers/graph_ql.dart';

class Review extends GetxController {
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

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  ReviewModel _data;

  ReviewModel get data => _data;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetchReview(int id) async {
    final body = await GraphQL.request(_reviewQuery, {'id': id});
    if (body == null) return;
    _data = ReviewModel(body['Review']);
    update();
  }
}
