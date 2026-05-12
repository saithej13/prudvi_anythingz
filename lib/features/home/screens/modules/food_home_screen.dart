import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anythingz/common/controllers/theme_controller.dart';
import 'package:anythingz/features/home/widgets/views/category_view.dart';
import 'package:anythingz/features/home/widgets/views/top_offers_near_me.dart';
import 'package:anythingz/helper/auth_helper.dart';
import 'package:anythingz/util/images.dart';
import 'package:anythingz/util/dimensions.dart';
import 'package:anythingz/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:anythingz/features/home/widgets/views/most_popular_item_view.dart';
import 'package:anythingz/features/home/widgets/views/new_on_mart_view.dart';
import 'package:anythingz/features/home/widgets/banner_view.dart';
import '../../../profile/controllers/profile_controller.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

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
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: GetBuilder<ProfileController>(
            builder: (profileController) {
              bool isLoggedIn = AuthHelper.isLoggedIn();
              String name = isLoggedIn
                  ? "${profileController.userInfoModel?.fName ?? ''}"
                  : "Hey";

              return Text(
                "$name, what's on your mind?",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),

        const CategoryView(),
        const TopOffersNearMe(),
        const BestStoreNearbyView(),
        const MostPopularItemView(isFood: true, isShop: false),
        const NewOnMartView(
          isNewStore: true,
          isPharmacy: false,
          isShop: false,
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
