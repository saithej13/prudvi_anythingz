
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:anythingz/util/images.dart';

class CustomImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isNotification;
  final String placeholder;
  final bool isHovered;

  const CustomImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.isNotification = false,
    this.placeholder = '',
    this.isHovered = false,
  });

  @override
  Widget build(BuildContext context) {
    final String fallback = placeholder.isNotEmpty
        ? placeholder
        : (isNotification
        ? Images.notificationPlaceholder
        : Images.placeholder);

    /// ⚡ FAST PATH: empty image
    if (image.isEmpty) {
      return _fallbackImage(fallback);
    }

    Widget img;

    if (kIsWeb) {
      img = Image.network(
        image,
        height: height,
        width: width,
        fit: fit,
        cacheWidth: 300, // ⚡ performance boost
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => _fallbackImage(fallback),
      );
    } else {
      img = CachedNetworkImage(
        imageUrl: image,
        height: height,
        width: width,
        fit: fit,
        memCacheWidth: 300, // ⚡ reduces memory usage
        memCacheHeight: 300,
        placeholder: (_, __) => _placeholderImage(fallback),
        errorWidget: (_, __, ___) => _fallbackImage(fallback),
      );
    }

    /// ⚡ REMOVE AnimatedScale (it causes scroll jank)
    return RepaintBoundary(
      child: img,
    );
  }

  /// ⚡ Lightweight placeholder (no rebuild cost)
  Widget _placeholderImage(String fallback) {
    return Image.asset(
      fallback,
      height: height,
      width: width,
      fit: fit,
      cacheWidth: 100,
      filterQuality: FilterQuality.low,
    );
  }

  Widget _fallbackImage(String fallback) {
    return Image.asset(
      fallback,
      height: height,
      width: width,
      fit: fit,
      cacheWidth: 200,
      filterQuality: FilterQuality.low,
    );
  }
}
