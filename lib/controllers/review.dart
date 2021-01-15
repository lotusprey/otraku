import 'package:get/get.dart';
import 'package:otraku/models/anilist/review_data.dart';
import 'package:otraku/helpers/network.dart';

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
        media {id type title {userPreferred} bannerImage}
        user {id name}
      }
    }
  ''';

  // ***************************************************************************
  // DATA
  // ***************************************************************************

  ReviewData _data;

  ReviewData get data => _data;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetchReview(int id) async {
    final body = await Network.request(_reviewQuery, {'id': id});
    if (body == null) return;
    _data = ReviewData(body['Review']);
    update();
  }
}
