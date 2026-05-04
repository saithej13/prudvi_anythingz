import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anythingz/features/home/widgets/filter_view.dart';
import 'package:anythingz/features/home/widgets/store_filter_button_widget.dart';
import 'package:anythingz/features/splash/controllers/splash_controller.dart';
import 'package:anythingz/features/store/controllers/store_controller.dart';
import 'package:anythingz/helper/responsive_helper.dart';
import 'package:anythingz/util/dimensions.dart';
import 'package:anythingz/util/styles.dart';

class AllStoreFilterWidget extends StatelessWidget {
  const AllStoreFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        final splash = Get.find<SplashController>();

        return Center(
          child: Container(
            width: Dimensions.webMaxWidth,
            transform: Matrix4.translationValues(0, -2, 0),
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= HEADER =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      splash.configModel!.moduleConfig!.module!.showRestaurantText!
                          ? 'restaurants'.tr
                          : 'stores'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),

                    Text(
                      '${storeController.storeModel?.totalSize ?? 0} '
                          '${splash.configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants_near_you'.tr : 'stores_near_you'.tr}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).disabledColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// ================= FILTER BAR =================
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    cacheExtent: 1000, // ⚡ improves scroll smoothness
                    padding: EdgeInsets.zero,

                    children: [
                      /// OPTIONAL FILTER VIEW (desktop/mobile safe)
                      if (!ResponsiveHelper.isDesktop(context)) ...[
                        RepaintBoundary(
                          child: FilterView(storeController: storeController),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                      ],

                      /// ALL
                      _buildFilterButton(
                        context,
                        storeController,
                        title: 'all'.tr,
                        value: 'all',
                      ),

                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      /// NEWLY JOINED
                      _buildFilterButton(
                        context,
                        storeController,
                        title: 'newly_joined'.tr,
                        value: 'newly_joined',
                      ),

                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      /// POPULAR
                      _buildFilterButton(
                        context,
                        storeController,
                        title: 'popular'.tr,
                        value: 'popular',
                      ),

                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      /// TOP RATED
                      _buildFilterButton(
                        context,
                        storeController,
                        title: 'top_rated'.tr,
                        value: 'top_rated',
                      ),

                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      /// Desktop extra filter
                      if (ResponsiveHelper.isDesktop(context)) ...[
                        RepaintBoundary(
                          child: FilterView(storeController: storeController),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ================= FILTER BUTTON =================
  Widget _buildFilterButton(
      BuildContext context,
      StoreController controller, {
        required String title,
        required String value,
      }) {
    return RepaintBoundary(
      child: StoreFilterButtonWidget(
        buttonText: title,
        isSelected: controller.storeType == value,
        onTap: () => controller.setStoreType(value),
      ),
    );
  }
}
