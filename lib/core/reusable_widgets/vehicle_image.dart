import 'dart:io';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../features/vehicle/model/vehicle_model.dart';
import '../utils/image_cache_helper.dart';

class VehicleImage extends StatefulWidget {
  final VehicleModel vehicle;
  final double width;
  final double? height;
  final BoxFit fit;
  const VehicleImage({
    super.key,
    required this.vehicle,
    this.width = double.infinity,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  State<VehicleImage> createState() => _VehicleImageState();
}

class _VehicleImageState extends State<VehicleImage> {
  final ImageCacheHelper _cacheHelper = ImageCacheHelper();
  bool _isLocalImageValid = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkLocalImage();
  }

  @override
  Widget build(BuildContext context) {
    // Show loader while checking
    if (_isChecking) {
      return _buildLoader();
    }

    // Priority 1: Local file exists
    if (_isLocalImageValid && widget.vehicle.localImagePath != null) {
      return _buildLocalImage();
    }

    // Priority 2: Remote URL (cached network image)
    if (widget.vehicle.vehicleImage != null && widget.vehicle.vehicleImage!.isNotEmpty) {
      return _buildCachedNetworkImage();
    }

    // Priority 3: No image
    return _buildPlaceholder();
  }

  Widget _buildLoader() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[100],
      child: const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildLocalImage() {
    return  Image.file(
      File(widget.vehicle.localImagePath!),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading local image: $error');
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildCachedNetworkImage() {
    return CachedNetworkImage(
        imageUrl: widget.vehicle.vehicleImage!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (context, url) => _buildLoader(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('No Image', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _checkLocalImage() async {
    setState(() => _isChecking = true);

    final exists = await _cacheHelper.localImageExists(widget.vehicle.localImagePath);

    setState(() {
      _isLocalImageValid = exists;
      _isChecking = false;
    });
  }
}
