import 'package:get/get.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/models/explorable_model.dart';
import 'package:otraku/models/user_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/scroll_x_controller.dart';

class UserReviewsController extends ScrollxController {
  static const _reviewsQuery = r'''
    query UserReviews($id: Int, $page: Int = 1) {
      Page(page: $page) {
        pageInfo {hasNextPage}
        reviews(userId: $id, sort: CREATED_AT_DESC) {
          id
          summary 
          body(asHtml: true)
          rating
          ratingAmount
          media {id type title{userPreferred} bannerImage}
          user {id name}
        }
      }
    }
  ''';

  final int id;
  UserReviewsController(this.id);

  late UserModel _model;

  @override
  bool get hasNextPage => _model.reviews.hasNextPage;
  List<ExplorableModel> get reviews => _model.reviews.items;

  @override
  Future<void> fetchPage() async {
    final data = await Client.request(_reviewsQuery, {
      'id': id,
      'page': _model.reviews.nextPage,
    });
    if (data == null) return;

    final rl = <ExplorableModel>[];
    for (final r in data['Page']['reviews']) rl.add(ExplorableModel.review(r));
    _model.reviews.append(rl, data['Page']['pageInfo']['hasNextPage']);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _model = Get.find<UserController>(tag: id.toString()).model!;
    if (_model.reviews.items.isEmpty) fetchPage();
  }
}
