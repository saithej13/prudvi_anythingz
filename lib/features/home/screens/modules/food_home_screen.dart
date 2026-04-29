import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anythingz/common/controllers/theme_controller.dart';
import 'package:anythingz/features/home/widgets/highlight_widget.dart';
import 'package:anythingz/features/home/widgets/views/category_view.dart';
import 'package:anythingz/features/home/widgets/views/top_offers_near_me.dart';
import 'package:anythingz/helper/auth_helper.dart';
import 'package:anythingz/util/images.dart';
import 'package:anythingz/features/home/widgets/bad_weather_widget.dart';
import 'package:anythingz/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:anythingz/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:anythingz/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:anythingz/features/home/widgets/views/just_for_you_view.dart';
import 'package:anythingz/features/home/widgets/views/most_popular_item_view.dart';
import 'package:anythingz/features/home/widgets/views/new_on_mart_view.dart';
import 'package:anythingz/features/home/widgets/views/special_offer_view.dart';
import 'package:anythingz/features/home/widgets/views/visit_again_view.dart';
import 'package:anythingz/features/home/widgets/banner_view.dart';

import '../../../profile/controllers/profile_controller.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  @override


  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔴 DEBUG VISIBILITY (YOU WILL SEE THIS)
          // Container(
          //   height: 60,
          //   width: double.infinity,
          //   color: Colors.red,
          //   alignment: Alignment.center,
          //   child: const Text(
          //     'I AM VISIBLE',
          //     style: TextStyle(color: Colors.white, fontSize: 18),
          //   ),
          // ),

          /// Banner section
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: Get.find<ThemeController>().darkTheme
                ? null
                : const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.foodModuleBannerBg),
                fit: BoxFit.cover,
              ),
            ),
            child: const Column(
              children: [
                BannerView(isFeatured: true),
                SizedBox(height: 12),
              ],
            ),
          ),
          GetBuilder<ProfileController>(
            builder: (profileController) {

              bool isLoggedIn = AuthHelper.isLoggedIn();

              String name = isLoggedIn
                  ? "${profileController.userInfoModel?.fName ?? ''}"
                  : "Hey";

              return Text(
                "$name, what's on your mind?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const CategoryView(),
          if (isLoggedIn) const VisitAgainView(fromFood: true),
          const SpecialOfferView(isFood: true, isShop: false),
          const HighlightWidget(),
          const TopOffersNearMe(),
          const BestReviewItemView(),
          const BestStoreNearbyView(),
          const ItemThatYouLoveView(forShop: false),
          const MostPopularItemView(isFood: true, isShop: false),
          const JustForYouView(),
          const NewOnMartView(
            isNewStore: true,
            isPharmacy: false,
            isShop: false,
          ),

          const SizedBox(height: 120), // bottom nav space
        ],
      ),
    );
  }




// Widget build(BuildContext context) {
//     bool isLoggedIn = AuthHelper.isLoggedIn();
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//       Container(
//         width: MediaQuery.of(context).size.width,
//         decoration: Get.find<ThemeController>().darkTheme ? null : const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(Images.foodModuleBannerBg),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: const Column(
//           children: [
//             // BadWeatherWidget(),
//             BannerView(isFeatured: false),
//             SizedBox(height: 12),
//           ],
//         ),
//       ),
//
//       const CategoryView(),
//       isLoggedIn ? const VisitAgainView(fromFood: true) : const SizedBox(),
//       const SpecialOfferView(isFood: true, isShop: false),
//       const HighlightWidget(),
//       const TopOffersNearMe(),
//       const BestReviewItemView(),
//       const BestStoreNearbyView(),
//       const ItemThatYouLoveView(forShop: false),
//       const MostPopularItemView(isFood: true, isShop: false),
//       const JustForYouView(),
//       const NewOnMartView(isNewStore: true, isPharmacy: false, isShop: false),
//     ]);
//   }
}
