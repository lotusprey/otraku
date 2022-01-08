import 'package:get/get.dart';
import 'package:otraku/models/review_model.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';

class ReviewController extends GetxController {
  ReviewController(this._id);

  final int _id;
  ReviewModel? _model;

  ReviewModel? get model => _model;

  Future<void> fetch() async {
    final data = await Client.request(GqlQuery.review, {'id': _id});
    if (data == null) return;
    _model = ReviewModel(data['Review']);
    update();
  }

  Future<void> rate(bool? rating) async {
    final data = await Client.request(GqlMutation.rateReview, {
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
