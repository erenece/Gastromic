import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:gastromic/core/models/gastromic_map_marker.dart';

/// İstanbul merkez — konum alınamazsa varsayılan.
const kDefaultMapCenter = LatLng(41.0082, 28.9784);

/// Canlı Google Maps — yalnızca Bul ekranı gibi etkileşimli haritalarda kullanın.
class GastromicGoogleMap extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final double zoom;
  final List<GastromicMapMarker> markers;
  final String? selectedMarkerId;
  final bool interactive;
  final bool showMyLocation;
  final bool liteMode;
  final void Function(String markerId)? onMarkerTap;

  const GastromicGoogleMap({
    super.key,
    this.latitude,
    this.longitude,
    this.zoom = 13,
    this.markers = const [],
    this.selectedMarkerId,
    this.interactive = true,
    this.showMyLocation = true,
    this.liteMode = false,
    this.onMarkerTap,
  });

  @override
  State<GastromicGoogleMap> createState() => _GastromicGoogleMapState();
}

class _GastromicGoogleMapState extends State<GastromicGoogleMap> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  bool _cameraFitted = false;

  @override
  void didUpdateWidget(covariant GastromicGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markers != widget.markers ||
        oldWidget.selectedMarkerId != widget.selectedMarkerId) {
      setState(_buildMarkers);
    }
  }

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  LatLng get _center {
    if (widget.latitude != null &&
        widget.longitude != null &&
        (widget.latitude != 0 || widget.longitude != 0)) {
      return LatLng(widget.latitude!, widget.longitude!);
    }
    if (widget.markers.isNotEmpty) {
      final first = widget.markers.first;
      return LatLng(first.latitude, first.longitude);
    }
    return kDefaultMapCenter;
  }

  void _buildMarkers() {
    _markers = widget.markers
        .where((m) => m.latitude != 0 || m.longitude != 0)
        .map((marker) {
          final selected = marker.id == widget.selectedMarkerId;
          return Marker(
            markerId: MarkerId(marker.id),
            position: LatLng(marker.latitude, marker.longitude),
            infoWindow: InfoWindow(title: marker.title),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              selected
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueRed,
            ),
            onTap: () => widget.onMarkerTap?.call(marker.id),
          );
        })
        .toSet();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    if (!_cameraFitted) {
      _cameraFitted = true;
      await _fitCamera();
    }
  }

  Future<void> _fitCamera() async {
    final controller = _controller;
    if (controller == null) return;

    final points = <LatLng>[_center];
    for (final marker in widget.markers) {
      if (marker.latitude != 0 || marker.longitude != 0) {
        points.add(LatLng(marker.latitude, marker.longitude));
      }
    }

    if (points.length <= 1) {
      await controller.moveCamera(
        CameraUpdate.newLatLngZoom(_center, widget.zoom),
      );
      return;
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await controller.moveCamera(CameraUpdate.newLatLngBounds(bounds, 56));
    } catch (_) {
      await controller.moveCamera(
        CameraUpdate.newLatLngZoom(_center, widget.zoom),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _center, zoom: widget.zoom),
      markers: _markers,
      myLocationEnabled: widget.showMyLocation && widget.interactive,
      myLocationButtonEnabled: widget.interactive,
      zoomControlsEnabled: widget.interactive,
      scrollGesturesEnabled: widget.interactive,
      rotateGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      liteModeEnabled: widget.liteMode,
      onMapCreated: _onMapCreated,
      onTap: widget.interactive ? null : (_) {},
    );
  }
}
