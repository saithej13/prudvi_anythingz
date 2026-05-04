import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../common/widgets/item_view.dart';
import '../../helper/responsive_helper.dart';
import '../../util/dimensions.dart';
import '../store/controllers/store_controller.dart';

class StoreSliverListWidget extends StatefulWidget {
  final ScrollController scrollController;
  final bool isFood;
  final bool isGrocery;

  const StoreSliverListWidget({
    super.key,
    required this.scrollController,
    required this.isFood,
    required this.isGrocery,
  });

  @override
  State<StoreSliverListWidget> createState() => _StoreSliverListWidgetState();
}

class _StoreSliverListWidgetState extends State<StoreSliverListWidget> {
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(() {
      final controller = Get.find<StoreController>();

      if (widget.scrollController.position.pixels >=
          widget.scrollController.position.maxScrollExtent - 200) {
        _loadMore(controller);
      }
    });
  }

  void _loadMore(StoreController controller) async {
    if (_isLoadingMore) return;
    if (controller.storeModel == null) return;

    _isLoadingMore = true;

    final nextOffset = (controller.storeModel!.offset ?? 0) + 1;

    await controller.getStoreList(nextOffset, false);

    _isLoadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        final stores = storeController.storeModel?.stores ?? [];

        /// ✅ LOADING
        if (storeController.isLoading && stores.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        /// ✅ EMPTY
        if (stores.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("No stores found")),
          );
        }

        /// ✅ NORMAL LIST (NO SLIVERS)
        return ListView.builder(
          controller: widget.scrollController,
          shrinkWrap: true, // IMPORTANT
          physics: const NeverScrollableScrollPhysics(), // IMPORTANT
          padding: EdgeInsets.only(
            bottom: ResponsiveHelper.isDesktop(context) ? 0 : 120,
          ),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];

            return RepaintBoundary(
              child: ItemsView(
                isStore: true,
                items: null,
                isFoodOrGrocery: widget.isFood || widget.isGrocery,
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
        );
      },
    );
  }
}