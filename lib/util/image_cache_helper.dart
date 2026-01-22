import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Helper class to manage image cache and fix "Future already completed" errors
class ImageCacheHelper {

  /// Clear all cached images
  static Future<void> clearImageCache() async {
    try {
      // Clear cached network images
      await DefaultCacheManager().emptyCache();

      // Clear Flutter's image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      debugPrint('✅ Image cache cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing image cache: $e');
    }
  }

  /// Clear cache for specific image URL
  static Future<void> clearImageUrl(String url) async {
    try {
      await DefaultCacheManager().removeFile(url);
      debugPrint('✅ Cleared cache for: $url');
    } catch (e) {
      debugPrint('❌ Error clearing image URL cache: $e');
    }
  }

  /// Evict specific image from memory cache
  static void evictImage(String url) {
    try {
      final NetworkImage provider = NetworkImage(url);
      provider.evict();
      debugPrint('✅ Evicted image from memory: $url');
    } catch (e) {
      debugPrint('❌ Error evicting image: $e');
    }
  }

  /// Configure image cache size limits
  static void configureImageCache({
    int maxMemoryCacheSize = 100, // MB
    int maxDiskCacheSize = 200,   // MB
  }) {
    // Set maximum cache size (in MB)
    PaintingBinding.instance.imageCache.maximumSize = 1000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = maxMemoryCacheSize * 1024 * 1024;

    debugPrint('✅ Image cache configured: Memory=${maxMemoryCacheSize}MB, Disk=${maxDiskCacheSize}MB');
  }

  /// Get current cache stats
  static Map<String, dynamic> getCacheStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': imageCache.currentSize,
      'maximumSize': imageCache.maximumSize,
      'currentSizeBytes': imageCache.currentSizeBytes,
      'maximumSizeBytes': imageCache.maximumSizeBytes,
      'liveImageCount': imageCache.liveImageCount,
      'pendingImageCount': imageCache.pendingImageCount,
    };
  }

  /// Print cache stats for debugging
  static void printCacheStats() {
    final stats = getCacheStats();
    debugPrint('📊 Image Cache Stats:');
    stats.forEach((key, value) {
      debugPrint('  $key: $value');
    });
  }
}
