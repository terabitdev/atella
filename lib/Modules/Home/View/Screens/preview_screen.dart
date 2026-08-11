import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/Routes/app_routes.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:atella/core/utils/app_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:gal/gal.dart';

class PreviewScreen extends StatefulWidget {
  final TechPackModel techPack;
  final String version;

  const PreviewScreen({Key? key, required this.techPack, required this.version})
    : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late PageController _pageController;
  final RxInt currentImageIndex = 0.obs;
  final RxInt _downloadProgress = 0.obs;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Get all images for the slider
  List<String> get allImages {
    List<String> images = [];

    // Add design image first if available
    if (widget.techPack.selectedDesignImageUrl != null &&
        widget.techPack.selectedDesignImageUrl!.isNotEmpty) {
      images.add(widget.techPack.selectedDesignImageUrl!);
    }

    // Add tech pack images
    images.addAll(widget.techPack.images.values);

    return images;
  }

  // Get image type label for current index
  String _getImageTypeLabel(int index, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasDesignImage =
        widget.techPack.selectedDesignImageUrl != null &&
        widget.techPack.selectedDesignImageUrl!.isNotEmpty;

    if (hasDesignImage && index == 0) {
      return l10n.designImage;
    } else {
      final techPackIndex = hasDesignImage ? index : index + 1;
      return l10n.techPackImage(techPackIndex);
    }
  }

  void showPopup() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
          child: SizedBox(
            width: 260.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PopupMenuItem(
                  icon: Icons.edit_outlined,
                  label: l10n.edit,
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleEdit();
                  },
                ),
                _popupDivider(),
                _PopupMenuItem(
                  icon: Icons.download_outlined,
                  label: l10n.download,
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleDownload();
                  },
                ),
                _popupDivider(),
                _PopupMenuItem(
                  icon: Icons.factory_outlined,
                  label: l10n.manufactureSuggestions,
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleManufactureSuggestions();
                  },
                ),
                _popupDivider(),
                _PopupMenuItem(
                  icon: Icons.send_outlined,
                  label: 'Send to Manufacturing Partner',
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleSendToSupplier();
                  },
                  isLast: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _popupDivider() => Container(height: 1, color: Colors.grey.shade200);

  // Send this tech pack to a supplier via the invite-only marketplace.
  void _handleSendToSupplier() {
    Get.toNamed(
      AppRoutes.supplierDirectory,
      arguments: {
        'techPackId': widget.techPack.id,
        'techPackProjectName': widget.techPack.projectName,
        'techPackImageUrl': widget.techPack.displayImage,
      },
    );
  }

  // Handle Edit functionality - Navigate to creative brief with existing data
  void _handleEdit() {
    print('=== EDIT BUTTON CLICKED ===');
    print('TechPack ID: ${widget.techPack.id}');
    print('Project Name: ${widget.techPack.projectName}');
    print('Collection Name: ${widget.techPack.collectionName}');

    final arguments = {
      'editMode': true,
      'techPackModel': widget.techPack,
      'projectName': widget.techPack.projectName,
      'collectionName': widget.techPack.collectionName,
    };

    print('=== ARGUMENTS BEING PASSED ===');
    print('Arguments: $arguments');
    print('EditMode: ${arguments['editMode']}');
    print('TechPack: ${arguments['techPackModel']}');

    // In edit mode, skip onboarding and go directly to creative brief questionnaire
    Get.toNamed('/creative_brief', arguments: arguments);

    print('=== NAVIGATION TO EDIT MODE TRIGGERED ===');
  }

  // Handle Download functionality - Download all images
  Future<void> _handleDownload() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final images = allImages;
      if (images.isEmpty) {
        showAppSnackbar(
          l10n.info,
          l10n.noImagesAvailable,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
        );
        return;
      }

      // Filter out local asset images and keep only URL images
      final urlImages = images
          .where((image) => image.startsWith('http'))
          .toList();

      if (urlImages.isEmpty) {
        showAppSnackbar(
          l10n.info,
          l10n.allImagesLocal,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
        );
        return;
      }
      // Show loading dialog with progress indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Obx(
          () => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            content: SizedBox(
              height: 100.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _downloadProgress.value / urlImages.length,
                    color: Colors.black,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.downloading(_downloadProgress.value, urlImages.length),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Download all images
      await _downloadAllImages(urlImages);
    } catch (e) {
      // Close dialog if open
      if (Get.overlayContext != null && Navigator.of(Get.overlayContext!).canPop()) {
        Navigator.of(Get.overlayContext!).pop();
      }

      showAppSnackbar(
        l10n.error,
        l10n.failedToDownloadImages(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  void _handleManufactureSuggestions() {
    print('=== MANUFACTURE SUGGESTIONS BUTTON CLICKED ===');
    print('TechPack ID: ${widget.techPack.id}');
    print('Project Name: ${widget.techPack.projectName}');

    // Navigate to RecommendedTechPackScreen
    Get.toNamed('/recommended_tech_pack');

    print('=== NAVIGATION TO MANUFACTURE SUGGESTIONS TRIGGERED ===');
  }

  // Download all images method
  Future<void> _downloadAllImages(List<String> imageUrls) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      _downloadProgress.value = 0;
      List<String> downloadedFiles = [];
      List<String> failedDownloads = [];

      // Download each image and save to gallery
      for (int i = 0; i < imageUrls.length; i++) {
        try {
          final imageUrl = imageUrls[i];
          final response = await http.get(Uri.parse(imageUrl));

          if (response.statusCode == 200) {
            // Determine file name based on image type
            String fileName;
            if (widget.techPack.selectedDesignImageUrl != null &&
                imageUrl == widget.techPack.selectedDesignImageUrl) {
              fileName = '${widget.techPack.projectName}_Design.jpg';
            } else {
              final techPackIndex =
                  widget.techPack.images.values.toList().indexOf(imageUrl) + 1;
              fileName =
                  '${widget.techPack.projectName}_TechPack_$techPackIndex.jpg';
            }

            // Save directly to gallery using Gal
            try {
              await Gal.putImageBytes(
                response.bodyBytes,
                name: fileName.replaceAll('.jpg', ''),
                album: 'Atella',
              );
              downloadedFiles.add(fileName);
            } catch (e) {
              failedDownloads.add(
                'Image ${i + 1} (Failed to save to gallery: $e)',
              );
            }
          } else {
            failedDownloads.add(
              'Image ${i + 1} (Status: ${response.statusCode})',
            );
          }
        } catch (e) {
          failedDownloads.add('Image ${i + 1} (Error: $e)');
        }

        // Update progress
        _downloadProgress.value = i + 1;
      }

      // Close loading dialog
      Navigator.of(Get.overlayContext!).pop();

      // Show result message
      if (downloadedFiles.isNotEmpty && failedDownloads.isEmpty) {
        // All downloads successful
        showAppSnackbar(
          l10n.success,
          l10n.imagesSavedToGallery(downloadedFiles.length),
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
          snackPosition: SnackPosition.TOP,
        );
      } else if (downloadedFiles.isNotEmpty && failedDownloads.isNotEmpty) {
        // Partial success
        showAppSnackbar(
          l10n.partialSuccess,
          l10n.partialDownloadSuccess(downloadedFiles.length, failedDownloads.length),
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
          snackPosition: SnackPosition.TOP,
        );
      } else {
        // All failed
        showAppSnackbar(
          l10n.error,
          l10n.failedToSaveImages,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      // Close dialog if open
      if (Get.overlayContext != null && Navigator.of(Get.overlayContext!).canPop()) {
        Navigator.of(Get.overlayContext!).pop();
      }

      showAppSnackbar(
        l10n.error,
        l10n.downloadFailed(e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 54.h),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Image.asset(
                    'assets/images/Arrow_Left.png',
                    height: 40.h,
                    width: 40.w,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  l10n.preview,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.techPack.projectName} (${widget.techPack.collectionName})',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.version,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 15.w),
                        IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.black,
                            size: 24.sp,
                          ),
                          onPressed: () {
                            showPopup();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Expanded(
                    child: Column(
                      children: [
                        // Image slider
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              currentImageIndex.value = index;
                            },
                            itemCount: allImages.length,
                            itemBuilder: (context, index) {
                              final imageUrl = allImages[index];

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => _FullScreenGallery(
                                        imageUrls: allImages,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: Center(
                                  child: Container(
                                    width: 0.85.sw,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey.shade100,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.contain,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child: Lottie.asset(
                                                  'assets/lottie/Loading_dots.json',
                                                  width: 100.w,
                                                  height: 100.h,
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.error_outline,
                                                  color: Colors.grey,
                                                  size: 48.sp,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Image indicators and labels
                        if (allImages.length > 1) ...[
                          SizedBox(height: 8.h),

                          // Page indicators
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                allImages.length,
                                (index) {
                                  final isActive = currentImageIndex.value == index;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: isActive ? 20.w : 8.w,
                                    height: 8.h,
                                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.r),
                                      color: isActive
                                          ? Colors.black
                                          : Colors.grey.shade300,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: 6.h),

                          // Image type label
                          Obx(
                            () => Text(
                              _getImageTypeLabel(currentImageIndex.value, context),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Three-dot action menu row ───────────────────────────────────────────────

class _PopupMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _PopupMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomRadius = isLast ? Radius.circular(16.r) : Radius.zero;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.vertical(bottom: bottomRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(bottom: bottomRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: Colors.black87),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Full-screen gallery with pinch-to-zoom + dot indicators ────────────────

class _FullScreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenGallery({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Swipeable + zoomable pages
          PageView.builder(
            controller: _pageController,
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, i) {
              return _ZoomableImage(
                imageUrl: widget.imageUrls[i],
                onZoomChanged: (zoomed) {
                  if (_isZoomed != zoomed) {
                    setState(() => _isZoomed = zoomed);
                  }
                },
              );
            },
          ),

          // Close button – top right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),

          // Dot indicators – bottom centre
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageUrls.length, (i) {
                  final isActive = _currentIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isActive ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive ? Colors.white : Colors.white38,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableImage({
    required this.imageUrl,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransform);
  }

  void _onTransform() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.01);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransform);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 1.0,
      maxScale: 5.0,
      child: Center(
        child: Image.network(
          widget.imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error_outline, color: Colors.white54, size: 48),
            );
          },
        ),
      ),
    );
  }
}
