import 'package:anythingz/common/widgets/custom_asset_image_widget.dart';
import 'package:anythingz/common/widgets/web_page_title_widget.dart';
import 'package:anythingz/features/notification/controllers/notification_controller.dart';
import 'package:anythingz/features/notification/domain/models/notification_model.dart';
import 'package:anythingz/features/notification/widgets/notification_bottom_sheet.dart';
import 'package:anythingz/features/splash/controllers/splash_controller.dart';
import 'package:anythingz/helper/auth_helper.dart';
import 'package:anythingz/helper/date_converter.dart';
import 'package:anythingz/helper/responsive_helper.dart';
import 'package:anythingz/helper/route_helper.dart';
import 'package:anythingz/util/dimensions.dart';
import 'package:anythingz/util/images.dart';
import 'package:anythingz/util/styles.dart';
import 'package:anythingz/common/widgets/custom_app_bar.dart';
import 'package:anythingz/features/store/domain/models/store_model.dart';
import 'package:anythingz/common/widgets/custom_image.dart';
import 'package:anythingz/common/widgets/footer_view.dart';
import 'package:anythingz/common/widgets/menu_drawer.dart';
import 'package:anythingz/common/widgets/no_data_screen.dart';
import 'package:anythingz/common/widgets/not_logged_in_screen.dart';
import 'package:anythingz/features/notification/widgets/notification_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../store/controllers/store_controller.dart';
import '../../store/screens/store_screen.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  final int? notificationId;
  const NotificationScreen({super.key, this.fromNotification = false,
    this.notificationId,});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  void _loadData() async {
    Get.find<NotificationController>().clearNotification();
    if(Get.find<SplashController>().configModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    if(AuthHelper.isLoggedIn()) {
      Get.find<NotificationController>().getNotificationList(true);
    }
  }

  @override
  void initState() {
    super.initState();

   _loadData();
   _handleNotificationRedirect();
    //  final notificationController = Get.find<NotificationController>();
   //
   //  final sampleNotification = NotificationModel(
   //    id: 1,
   //    store_id: '65',
   //    createdAt: DateTime.now().toString(),
   //    imageFullUrl: null,
   //    data: Data(
   //      title: 'title',
   //      description: 'description',
   //      type: 'push_notification',
   //    ),
   //  );
   //  notificationController.notificationList?.clear();
   //  notificationController.notificationList?.add(sampleNotification);
   //  notificationController.update();
  }

  Future<void> _handleNotificationRedirect() async {
    if (widget.notificationId == null) return;

    final notificationController = Get.find<NotificationController>();
    final storeController = Get.find<StoreController>();

    try {
      // Find the notification by ID
      final notification = notificationController.notificationList
          ?.firstWhereOrNull((n) => n.id == widget.notificationId);

      if (notification == null) return;

      final storeId = notification.store_id;

      if (storeId != null && storeId.toString().isNotEmpty) {
        // Try to find the store locally or via API
        Store? store = await _findStoreById(storeController, int.parse(storeId.toString()));

        if (store != null) {
          // ✅ Redirect directly to store
          Future.microtask(() {
            Get.offAll(() => StoreScreen(store: store, fromModule: false));
          });
        }
      }
    } catch (e) {
      debugPrint('Error handling store redirect: $e');
    }
  }

  Future<Store?> _findStoreById(StoreController storeController, int storeId) async {
    Store? store;

    try {
      // 1️⃣ Check cached current store
      if (storeController.store?.id == storeId) {
        return storeController.store;
      }

      // 2️⃣ Check store lists
      final allLists = [
        storeController.popularStoreList,
        storeController.latestStoreList,
        storeController.featuredStoreList,
        storeController.recommendedStoreList,
        storeController.visitAgainStoreList,
      ];

      for (var list in allLists) {
        store ??= list?.firstWhereOrNull((s) => s.id == storeId);
        if (store != null) break;
      }

      // 3️⃣ Fetch from API if not found
      store ??= await storeController.getStoreDetails(Store(id: storeId), false);
    } catch (e) {
      debugPrint('Error while finding store by id: $e');
    }

    return store;
  }
  void _redirectToStore(int storeId) async {
    final storeController = Get.find<StoreController>();
    Store? store;

    try {
      store = storeController.store?.id == storeId
          ? storeController.store
          : storeController.popularStoreList
          ?.firstWhereOrNull((s) => s.id == storeId)
          ?? await storeController.getStoreDetails(Store(id: storeId), false);

      if (store != null) {
        Get.offAll(() => StoreScreen(store: store, fromModule: false));
      } else {
        // fallback if store not found
        debugPrint('Store not found for ID $storeId');
      }
    } catch (e) {
      debugPrint('Error redirecting to store: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          return;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'notification'.tr, onBackPressed: () {
          if(widget.fromNotification){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }else{
            Get.back();
          }
        }),
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        body: AuthHelper.isLoggedIn() ? GetBuilder<NotificationController>(builder: (notificationController) {
          if(notificationController.notificationList != null) {
            notificationController.saveSeenNotificationCount(notificationController.notificationList!.length);
          }
          List<DateTime> dateTimeList = [];
          return notificationController.notificationList != null ? notificationController.notificationList!.isNotEmpty ? RefreshIndicator(
            onRefresh: () async {
              await notificationController.getNotificationList(true);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FooterView(
                child: Column(children: [
                  WebScreenTitleWidget(title: 'notification'.tr),

                  Center(
                    child: SizedBox(width: Dimensions.webMaxWidth, child: ListView.builder(
                      itemCount: notificationController.notificationList!.length,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        DateTime originalDateTime = DateConverter.dateTimeStringToDate(notificationController.notificationList![index].createdAt!);
                        DateTime convertedDate = DateTime(originalDateTime.year, originalDateTime.month, originalDateTime.day);
                        bool addTitle = false;
                        if(!dateTimeList.contains(convertedDate)) {
                          addTitle = true;
                          dateTimeList.add(convertedDate);
                        }

                        bool isSeen = notificationController.getSeenNotificationIdList()!.contains(notificationController.notificationList![index].id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            addTitle ? Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                              child: Text(
                                DateConverter.dateTimeStringToDateOnly(notificationController.notificationList![index].createdAt!),
                                style: robotoMedium.copyWith(color: Theme.of(context).hintColor),
                              ),
                            ) : const SizedBox(),

                            InkWell(
                              onTap: () async {
                                final notification = notificationController.notificationList![index];
                                final storeId = notification.store_id;
                                notificationController.addSeenNotificationId(notification.id!);

                                if (storeId != null && storeId.isNotEmpty) {
                                  final storeController = Get.find<StoreController>();

                                  Future<Store?> findStoreById(int storeId) async {
                                    Store? store;

                                    try {
                                      // 1️⃣ Check cached store
                                      if (storeController.store?.id == storeId) {
                                        return storeController.store;
                                      }

                                      // 2️⃣ Check lists (non-blocking small searches)
                                      final allLists = [
                                        storeController.popularStoreList,
                                        storeController.latestStoreList,
                                        storeController.featuredStoreList,
                                        storeController.recommendedStoreList,
                                        storeController.visitAgainStoreList,
                                      ];

                                      for (var list in allLists) {
                                        store ??= list?.firstWhereOrNull((s) => s.id == storeId);
                                        if (store != null) break;
                                      }

                                      // 3️⃣ If not found, fetch asynchronously
                                      store ??= await storeController.getStoreDetails(Store(id: storeId), false);
                                    } catch (e) {
                                      debugPrint('Error while finding store by id: $e');
                                    }

                                    return store;
                                  }

                                  // 🧭 Run in separate microtask to free UI thread
                                  Future.microtask(() async {
                                    try {
                                      // showCustomLoader(); // optional: show progress indicator

                                      final store = await findStoreById(int.parse(storeId.toString()));

                                      // hideCustomLoader();

                                      if (store != null) {
                                        Get.toNamed(RouteHelper.getStoreRoute(id: store.id, page: 'store'),
                                          arguments: StoreScreen(store: store, fromModule: false),
                                        );
                                        // Get.toNamed(
                                        //   RouteHelper.getStoreRoute(id: int.tryParse(storeId), page: 'store'),
                                        //   arguments: StoreScreen(store: store, fromModule: false),
                                        // );
                                      } else {
                                        // showCustomSnackBar('Store not found');
                                      }
                                    } catch (e) {
                                      // hideCustomLoader();
                                      debugPrint('Navigation error: $e');
                                    }
                                  });
                                }
                                else {
                                  ResponsiveHelper.isDesktop(context) ? showDialog(context: context, builder: (BuildContext context) {
                                    return NotificationDialogWidget(notificationModel: notificationController.notificationList![index]);
                                  }) : showModalBottomSheet(
                                    isScrollControlled: true, useRootNavigator: true, context: Get.context!,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                                    ),
                                    builder: (context) {
                                      return ConstrainedBox(
                                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                                        child: NotificationBottomSheet(notificationModel: notificationController.notificationList![index]),
                                      );
                                    },
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSeen ? Theme.of(context).cardColor : Theme.of(context).hintColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    ),
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall + 1),
                                    child: CustomAssetImageWidget(
                                      notificationController.notificationList![index].data!.type == 'push_notification' ? Images.pushNotificationIcon
                                      : notificationController.notificationList![index].data!.type == 'order_status' ? Images.orderConfirmIcon : Images.referEarnIcon,
                                      height: 30, width: 30, fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Expanded(
                                        child: Text(
                                          notificationController.notificationList![index].data!.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: robotoBold.copyWith(color: isSeen ? Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5) : Theme.of(context).textTheme.bodyLarge?.color,
                                            fontWeight: isSeen ? FontWeight.w500 : FontWeight.w700,
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                        child: Text(
                                          DateConverter.dateTimeStringToFormattedTime(notificationController.notificationList![index].createdAt!),
                                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                                        ),
                                      ),

                                    ]),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Expanded(
                                        child: Text(
                                          notificationController.notificationList![index].data!.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                                          style: robotoRegular.copyWith(color: isSeen ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)),
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      notificationController.notificationList![index].data!.type == 'push_notification' ? ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        child: notificationController.notificationList![index].imageFullUrl!=null ? CustomImage(
                                          image: '${notificationController.notificationList![index].imageFullUrl}',
                                          height: 45, width: 75, fit: BoxFit.cover,
                                        ): const SizedBox(),
                                      ) : const SizedBox.shrink(),

                                    ]),

                                  ])),

                                ]),
                              ),
                            ),

                          ]),
                        );
                      },
                    )),
                  ),
                ]),
              ),
            ),
          ) : NoDataScreen(text: 'no_notification_found'.tr, showFooter: true) : const Center(child: CircularProgressIndicator());
        }) :  NotLoggedInScreen(callBack: (value){
          _loadData();
          setState(() {});
        }),
      ),
    );
  }
}
