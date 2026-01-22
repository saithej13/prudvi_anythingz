import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:anythingz/api/local_client.dart';
import 'package:anythingz/common/enums/data_source_enum.dart';
import 'package:anythingz/features/category/domain/models/category_model.dart';
import 'package:anythingz/features/item/domain/models/item_model.dart';
import 'package:anythingz/features/splash/controllers/splash_controller.dart';
import 'package:anythingz/features/store/domain/models/store_model.dart';
import 'package:anythingz/features/language/controllers/language_controller.dart';
import 'package:anythingz/api/api_client.dart';
import 'package:anythingz/util/app_constants.dart';
import 'package:anythingz/features/category/domain/reposotories/category_repository_interface.dart';

class CategoryRepository implements CategoryRepositoryInterface {
  final ApiClient apiClient;
  CategoryRepository({required this.apiClient});

  @override
  Future getList({int? offset, bool categoryList = false, bool subCategoryList = false, bool categoryItemList = false, bool categoryStoreList = false,
    bool? allCategory, String? id, String? type, DataSourceEnum? source}) async {
    if (categoryList) {
      return await _getCategoryList(allCategory!, source ?? DataSourceEnum.client);
    } else if (subCategoryList) {
      return await _getSubCategoryList(id);
    } else if (categoryItemList) {
      return await _getCategoryItemList(id, offset!, type!);
    } else if (categoryStoreList) {
      return await _getCategoryStoreList(id, offset!, type!);
    }
  }

  Future<List<CategoryModel>?> _getCategoryList(bool allCategory, DataSourceEnum source) async {
    List<CategoryModel>? categoryList;
    Map<String, String>? header = allCategory ? {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: Get.find<LocalizationController>().locale.languageCode,
    } : null;

    Map<String, String>? cacheHeader = header ?? apiClient.getHeader();
    // String cacheId = AppConstants.categoryUri + Get.find<SplashController>().module!.id!.toString();
    final moduleId = Get.find<SplashController>().module?.id?.toString() ?? 'default';
    String cacheId = '${AppConstants.categoryUri}$moduleId';

    switch(source) {
      case DataSourceEnum.client:
        try {
          // Enable retry for categories endpoint (critical data)
          Response response = await apiClient.getData(
            AppConstants.categoryUri,
            headers: header,
            enableRetry: true, // Enable retry with exponential backoff
          );

          if (response.statusCode == 200) {
            categoryList = [];
            response.body.forEach((category) {
              categoryList!.add(CategoryModel.fromJson(category));
            });
            // Cache successful response
            LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), cacheHeader);

            if (kDebugMode) {
              print('====> Categories loaded from API: ${categoryList.length} items');
            }
          } else {
            // API failed, fall back to cache
            if (kDebugMode) {
              print('====> Categories API failed (${response.statusCode}), falling back to cache');
            }
            categoryList = await _getCategoriesFromCache(cacheId);
          }
        } catch (e) {
          // Exception occurred, fall back to cache
          if (kDebugMode) {
            print('====> Categories API exception: $e, falling back to cache');
          }
          categoryList = await _getCategoriesFromCache(cacheId);
        }

      case DataSourceEnum.local:
        categoryList = await _getCategoriesFromCache(cacheId);
    }

    return categoryList;
  }

  /// Helper method to load categories from cache
  Future<List<CategoryModel>?> _getCategoriesFromCache(String cacheId) async {
    try {
      String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
      if(cacheResponseData != null && cacheResponseData.isNotEmpty) {
        List<CategoryModel> categoryList = [];
        jsonDecode(cacheResponseData).forEach((category) {
          categoryList.add(CategoryModel.fromJson(category));
        });

        if (kDebugMode) {
          print('====> Categories loaded from cache: ${categoryList.length} items');
        }
        return categoryList;
      }
    } catch (e) {
      if (kDebugMode) {
        print('====> Failed to load categories from cache: $e');
      }
    }
    return null;
  }

  Future<List<CategoryModel>?> _getSubCategoryList(String? parentID) async {
    List<CategoryModel>? subCategoryList;
    Response response = await apiClient.getData('${AppConstants.subCategoryUri}$parentID');
    if (response.statusCode == 200) {
      subCategoryList= [];
      response.body.forEach((category) => subCategoryList!.add(CategoryModel.fromJson(category)));
    }
    return subCategoryList;
  }

  Future<ItemModel?> _getCategoryItemList(String? categoryID, int offset, String type) async {
    ItemModel? categoryItem;
    Response response = await apiClient.getData('${AppConstants.categoryItemUri}$categoryID?limit=10&offset=$offset&type=$type');
    if (response.statusCode == 200) {
      categoryItem = ItemModel.fromJson(response.body);
    }
    return categoryItem;
  }

  Future<StoreModel?> _getCategoryStoreList(String? categoryID, int offset, String type) async {
    StoreModel? categoryStore;
    Response response = await apiClient.getData('${AppConstants.categoryStoreUri}$categoryID?limit=10&offset=$offset&type=$type');
    if (response.statusCode == 200) {
      categoryStore = StoreModel.fromJson(response.body);
    }
    return categoryStore;
  }

  @override
  Future<Response> getSearchData(String? query, String? categoryID, bool isStore, String type) async {
    return await apiClient.getData(
      '${AppConstants.searchUri}${isStore ? 'stores' : 'items'}/search?name=$query&category_id=$categoryID&type=$type&offset=1&limit=50',
    );
  }

  @override
  Future<bool> saveUserInterests(List<int?> interests) async {
    Response response = await apiClient.postData(AppConstants.interestUri, {"interest": interests});
    return (response.statusCode == 200);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}