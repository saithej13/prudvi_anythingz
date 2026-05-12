import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../common/widgets/item_view.dart';
import '../../helper/responsive_helper.dart';
import '../../util/dimensions.dart';
import '../store/controllers/store_controller.dart';

class StoreSliverListWidget extends StatelessWidget {
  final bool isFood;
  final bool isGrocery;

  const StoreSliverListWidget({
    super.key,
    required this.isFood,
    required this.isGrocery,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        final stores = storeController.storeModel?.stores ?? [];

        /// ✅ LOADING
        if (storeController.isLoading && stores.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        /// ✅ EMPTY
        if (stores.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text("No stores found")),
            ),
          );
        }

        /// ✅ SLIVER LIST (BETTER PERFORMANCE)
        return SliverPadding(
          padding: EdgeInsets.only(
            bottom: ResponsiveHelper.isDesktop(context) ? 0 : 120,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == stores.length) {
                  // Trigger pagination when reaching the end
                  Future.microtask(() => storeController.getStoreList((storeController.storeModel?.offset ?? 0) + 1, false));
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final store = stores[index];

                return RepaintBoundary(
                  child: ItemsView(
                    isStore: true,
                    items: null,
                    isFoodOrGrocery: isFood || isGrocery,
                    stores: [store],
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.paddingSizeExtraSmall
                          : Dimensions.paddingSizeSmall,
                      vertical: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.paddingSizeExtraSmall
                          : Dimensions.paddingSizeDefault,
                    ),
                  ),
                );
              },
              childCount: stores.length + (storeController.storeModel?.offset != null && (storeController.storeModel?.offset ?? 0) < (storeController.storeModel?.totalSize ?? 0) ? 1 : 0),
            ),
          ),
        );
      },
    );
  }
}