import 'package:flutter/material.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/utils/venue_image_fallback.dart';

/// Mekan görseli — Firebase Storage URL veya kategori stok fotoğrafı.
class VenueImage extends StatefulWidget {
  const VenueImage({
    super.key,
    required this.imageUrl,
    this.category = '',
    this.types = '',
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final String category;
  final String types;
  final BoxFit fit;

  @override
  State<VenueImage> createState() => _VenueImageState();
}

class _VenueImageState extends State<VenueImage> {
  late String _url;
  bool _usingFallback = false;

  @override
  void initState() {
    super.initState();
    _url = _resolveUrl(widget.imageUrl);
    _usingFallback = !VenueImageFallback.isUsableNetworkUrl(widget.imageUrl);
  }

  @override
  void didUpdateWidget(covariant VenueImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.category != widget.category) {
      _url = _resolveUrl(widget.imageUrl);
      _usingFallback = !VenueImageFallback.isUsableNetworkUrl(widget.imageUrl);
    }
  }

  String _resolveUrl(String imageUrl) {
    if (VenueImageFallback.isUsableNetworkUrl(imageUrl)) return imageUrl;
    return VenueImageFallback.forCategory(widget.category, types: widget.types);
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _url,
      fit: widget.fit,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) {
        if (!_usingFallback) {
          final fallback = VenueImageFallback.forCategory(
            widget.category,
            types: widget.types,
          );
          if (fallback != _url) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _url = fallback;
                  _usingFallback = true;
                });
              }
            });
          }
        }
        return _iconPlaceholder(context);
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            _iconPlaceholder(context),
            Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: context.cPrimary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _iconPlaceholder(BuildContext context) {
    return Container(
      color: context.cPrimary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_outlined,
        size: 36,
        color: context.cPrimary.withValues(alpha: 0.4),
      ),
    );
  }
}
