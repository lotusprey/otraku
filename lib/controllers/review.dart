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

  final int _id;
  Review(this._id);

  ReviewModel _data;

  ReviewModel get data => _data;

  // ***************************************************************************
  // FETCHING
  // ***************************************************************************

  Future<void> fetch() async {
    final body = await GraphQL.request(_reviewQuery, {'id': _id});
    if (body == null) return;
    _data = ReviewModel(body['Review']);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}
