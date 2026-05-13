import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_specialized_temp/core/constants/asset_constants.dart';
import 'package:flutter_specialized_temp/core/network/cache/app_image_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

/// General-purpose image widget supporting network, asset, SVG, and file sources.
///
/// Network images use [AppImageCacheManager] (100-object, 7-day bounded cache)
/// and show a shimmer skeleton while loading.
///
/// Pass [thumbnailUrl] for true progressive loading: the low-res thumbnail
/// loads first, then the full-resolution image fades in over it.
///
/// Pass [memCacheWidth] / [memCacheHeight] to cap how many pixels are decoded
/// into memory — useful for list views with many large images.
class CustomImageView extends StatelessWidget {
  const CustomImageView({
    super.key,
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.thumbnailUrl,
    this.memCacheWidth,
    this.memCacheHeight,
    this.placeHolder = AssetConstants.imageNotFound,
  });

  final String? imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final String placeHolder;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final BoxBorder? border;

  /// Optional low-resolution URL that loads before [imagePath].
  final String? thumbnailUrl;

  /// Limits the decoded image width in memory (pixels).
  final int? memCacheWidth;

  /// Limits the decoded image height in memory (pixels).
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment!,
            child: _buildWidget(),
          )
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: _buildCircleImage(),
      ),
    );
  }

  Widget _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius!,
        child: _buildImageWithBorder(),
      );
    }
    return _buildImageWithBorder();
  }

  Widget _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
        ),
        child: _buildImageView(),
      );
    }
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (imagePath == null || imagePath!.isEmpty) {
      return Image.asset(
        AssetConstants.imageNotFound,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
      );
    }

    switch (imagePath!.imageType) {
      case ImageType.svg:
        return SizedBox(
          height: height,
          width: width,
          child: SvgPicture.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
          ),
        );

      case ImageType.file:
        return Image.file(
          File(imagePath!),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );

      case ImageType.network:
        return _buildNetworkImage();

      case ImageType.png:
      case ImageType.unknown:
        return Image.asset(
          imagePath!,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
    }
  }

  Widget _buildNetworkImage() {
    final hasThumbnail =
        thumbnailUrl != null && thumbnailUrl!.isNotEmpty;

    if (hasThumbnail) {
      return _ProgressiveNetworkImage(
        imageUrl: imagePath!,
        thumbnailUrl: thumbnailUrl!,
        height: height,
        width: width,
        fit: fit,
        color: color,
        placeHolder: placeHolder,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
      );
    }

    return CachedNetworkImage(
      imageUrl: imagePath!,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      color: color,
      cacheManager: AppImageCacheManager.instance,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholder: (context, url) => _ShimmerPlaceholder(
        height: height,
        width: width,
      ),
      errorWidget: (context, url, error) => Image.asset(
        placeHolder,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progressive loading: thumbnail → full image fade-in
// ---------------------------------------------------------------------------

class _ProgressiveNetworkImage extends StatefulWidget {
  const _ProgressiveNetworkImage({
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.placeHolder,
    this.height,
    this.width,
    this.fit,
    this.color,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  final String imageUrl;
  final String thumbnailUrl;
  final String placeHolder;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  State<_ProgressiveNetworkImage> createState() =>
      _ProgressiveNetworkImageState();
}

class _ProgressiveNetworkImageState extends State<_ProgressiveNetworkImage> {
  bool _fullLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1 — low-quality thumbnail; visible while full image loads.
        CachedNetworkImage(
          imageUrl: widget.thumbnailUrl,
          height: widget.height,
          width: widget.width,
          fit: widget.fit ?? BoxFit.cover,
          color: widget.color,
          cacheManager: AppImageCacheManager.instance,
          placeholder: (context, url) => _ShimmerPlaceholder(
            height: widget.height,
            width: widget.width,
          ),
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
        // Layer 2 — full-resolution image that fades in once decoded.
        AnimatedOpacity(
          opacity: _fullLoaded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            height: widget.height,
            width: widget.width,
            fit: widget.fit ?? BoxFit.cover,
            color: widget.color,
            cacheManager: AppImageCacheManager.instance,
            memCacheWidth: widget.memCacheWidth,
            memCacheHeight: widget.memCacheHeight,
            imageBuilder: (context, imageProvider) {
              // Trigger fade-in after the first frame to avoid setState mid-build.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_fullLoaded) {
                  setState(() => _fullLoaded = true);
                }
              });
              return Image(
                image: imageProvider,
                height: widget.height,
                width: widget.width,
                fit: widget.fit ?? BoxFit.cover,
                color: widget.color,
              );
            },
            errorWidget: (context, url, error) => Image.asset(
              widget.placeHolder,
              height: widget.height,
              width: widget.width,
              fit: widget.fit ?? BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer skeleton placeholder
// ---------------------------------------------------------------------------

class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder({this.height, this.width});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height ?? 80.h,
        width: width ?? double.infinity,
        color: Colors.white,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Extension & enum
// ---------------------------------------------------------------------------

extension ImageTypeExtension on String {
  ImageType get imageType {
    if (startsWith('http') || startsWith('https')) {
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (startsWith('file://')) {
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, network, file, unknown }
