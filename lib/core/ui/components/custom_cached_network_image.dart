import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../constants/api_endpoints.dart';
import '../../extensions/build_context_extensions.dart';
import '../../routing/navigation_service.dart';

/// A production-ready cached network image with:
/// - Skeleton loading state
/// - Name-initial avatar fallback
/// - Asset image fallback
/// - Full-screen preview on long-press
/// - Smooth fade-in on load
class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.height,
    this.width,
    this.isLoading = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.name,
    this.defaultImage,
    this.canOpen = true,
    this.addPrefix = true,
  });

  /// Network image path or full URL.
  final String? imageUrl;

  final BoxFit? fit;
  final double? height;
  final double? width;

  /// Shows a skeleton placeholder while true.
  final bool isLoading;

  final BorderRadiusGeometry borderRadius;

  /// Shown as initials avatar when the image is unavailable.
  final String? name;

  /// Asset path shown when the network image fails.
  final String? defaultImage;

  /// Enables long-press full-screen preview.
  final bool canOpen;

  /// Prepends [ApiEndpoints.assetUrl] to [imageUrl] when true.
  final bool addPrefix;

  String _resolvedUrl(String url) =>
      addPrefix ? ApiEndpoints.assetUrl(url) : url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: imageUrl != null && canOpen
          ? () => _openFullScreen(context)
          : null,
      child: Skeletonizer(
        enabled: isLoading,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (imageUrl != null) {
      return _buildNetworkImage(context);
    }
    if (defaultImage != null) {
      return _buildAssetImage();
    }
    if (name != null && name!.isNotEmpty) {
      return _buildAvatar(context);
    }
    return _buildErrorPlaceholder(context);
  }

  // ─── Network image ────────────────────────────────────────────────────────

  Widget _buildNetworkImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _resolvedUrl(imageUrl!),
      fit: fit ?? BoxFit.cover,
      width: width ?? double.infinity,
      height: height,
      imageBuilder: (_, imageProvider) => _FadeIn(
        child: Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit ?? BoxFit.cover,
            ),
          ),
        ),
      ),
      placeholder: (context, _) => _buildSkeleton(context),
      errorWidget: (context, _, __) {
        if (defaultImage != null) {
          return _buildAssetImage();
        }
        if (name != null && name!.isNotEmpty) {
          return _buildAvatar(context);
        }
        return _buildErrorPlaceholder(context);
      },
    );
  }

  // ─── Fallbacks ────────────────────────────────────────────────────────────

  Widget _buildSkeleton(BuildContext context) => Container(
        width: width ?? double.infinity,
        height: height,
        color: context.colors.secondary.withValues(alpha: 0.3),
      );

  Widget _buildAvatar(BuildContext context) {
    final radius = min(height ?? 56, width ?? 56) / 2;
    final initials = name!
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: context.colors.primary,
      child: Text(
        initials,
        style: context.styles.semiBold18.copyWith(
          fontSize: radius > 24 ? 18 : 14,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAssetImage() => Image.asset(
        defaultImage!,
        fit: fit ?? BoxFit.cover,
        width: width ?? double.infinity,
        height: height,
      );

  Widget _buildErrorPlaceholder(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: Icon(
          Icons.broken_image_outlined,
          size: min(height ?? 56, width ?? 56) / 2,
          color: context.colors.error,
        ),
      );

  // ─── Full-screen ──────────────────────────────────────────────────────────

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => _FullScreenImage(
          imageUrl: _resolvedUrl(imageUrl!),
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Fades a widget in from transparent to fully opaque.
class _FadeIn extends StatefulWidget {
  const _FadeIn({required this.child});
  final Widget child;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _controller,
        child: widget.child,
      );
}

/// Full-screen image viewer — tap anywhere to close.
class _FullScreenImage extends StatelessWidget {
  const _FullScreenImage({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: NavigationService.pop<void>,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
