import 'package:atella/Data/Models/tech_pack_model.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:gal/gal.dart';

class PreviewScreen extends StatefulWidget {
  final TechPackModel techPack;
  final String version;

  const PreviewScreen({
    Key? key,
    required this.techPack,
    required this.version,
  }) : super(key: key);

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
  String _getImageTypeLabel(int index) {
    final hasDesignImage = widget.techPack.selectedDesignImageUrl != null && 
                          widget.techPack.selectedDesignImageUrl!.isNotEmpty;
    
    if (hasDesignImage && index == 0) {
      return 'Design Image';
    } else {
      final techPackIndex = hasDesignImage ? index : index + 1;
      return 'Tech Pack Image $techPackIndex';
    }
  }

void showPopup() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: Colors.white,
        child: SizedBox(
          width: 238.w,
          height: 80.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleEdit();
                  },
                  child: Container(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Edit',
                        style: dbTitleTextTextStyle14400,
                      ),
                    ),
                  ),
                ),
              ),
              Container(height: 1, color: Colors.grey.shade300),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleDownload();
                  },
                  child: Container(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Download',
                        style: dbTitleTextTextStyle14400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
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
    try {
      final images = allImages;
      if (images.isEmpty) {
        Get.snackbar(
          'Info',
          'No images available to download',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Filter out local asset images and keep only URL images
      final urlImages = images.where((image) => image.startsWith('http')).toList();
      
      if (urlImages.isEmpty) {
        Get.snackbar(
          'Info',
          'All images are local assets and cannot be downloaded',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return;
      }
      // Show loading dialog with progress indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Obx(() => AlertDialog(
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
              'Downloading ${_downloadProgress.value} of ${urlImages.length}...',
              style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
              ),
            ),
          ],
            ),
          ),
        )),
      );

      // Download all images
      await _downloadAllImages(urlImages);
      
    } catch (e) {
      // Close dialog if open
      if (Get.isDialogOpen!) Get.back();
      
      Get.snackbar(
        'Error',
        'Failed to download images: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Download all images method
  Future<void> _downloadAllImages(List<String> imageUrls) async {
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
              final techPackIndex = widget.techPack.images.values.toList().indexOf(imageUrl) + 1;
              fileName = '${widget.techPack.projectName}_TechPack_$techPackIndex.jpg';
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
              failedDownloads.add('Image ${i + 1} (Failed to save to gallery: $e)');
            }
          } else {
            failedDownloads.add('Image ${i + 1} (Status: ${response.statusCode})');
          }
        } catch (e) {
          failedDownloads.add('Image ${i + 1} (Error: $e)');
        }
        
        // Update progress
        _downloadProgress.value = i + 1;
      }

      // Close loading dialog
      Get.back();

      // Show result message
      if (downloadedFiles.isNotEmpty && failedDownloads.isEmpty) {
        // All downloads successful
        Get.snackbar(
          'Success',
          '${downloadedFiles.length} images saved to gallery in "Atella" album',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
        );
      } else if (downloadedFiles.isNotEmpty && failedDownloads.isNotEmpty) {
        // Partial success
        Get.snackbar(
          'Partial Success',
          '${downloadedFiles.length} images saved to gallery. ${failedDownloads.length} failed.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
        );
      } else {
        // All failed
        Get.snackbar(
          'Error',
          'Failed to save images to gallery.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
      }

    } catch (e) {
      // Close dialog if open
      if (Get.isDialogOpen!) Get.back();
      
      Get.snackbar(
        'Error',
        'Download failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
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
                  onTap: () => Get.back(),
                  child: Image.asset('assets/images/Arrow_Left.png', height: 40.h, width: 40.w),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Preview',
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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
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
                  SizedBox(height: 12.h),
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
                              // Check if this is the design image or tech pack image
                              final isDesignImage = widget.techPack.selectedDesignImageUrl != null && 
                                                   imageUrl == widget.techPack.selectedDesignImageUrl;
                              
                              return Center(
                                child: Container(
                                  width: 0.85.sw,
                                  height: 0.6.sh,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey.shade100,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      imageUrl,
                                      // Use different fit for design vs tech pack images
                                      fit: isDesignImage ? BoxFit.cover : BoxFit.contain,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: Lottie.asset(
                                            'assets/lottie/Loading_dots.json',
                                            width: 100.w,
                                            height: 100.h,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
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
                              );
                            },
                          ),
                        ),
                        
                        // Image indicators and labels
                        if (allImages.length > 1) ...[
                          SizedBox(height: 16.h),
                          
                          // Page indicators
                          Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              allImages.length,
                              (index) => Container(
                                width: 8.w,
                                height: 8.h,
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentImageIndex.value == index
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          )),
                          
                          SizedBox(height: 8.h),
                          
                          // Image type label
                          Obx(() => Text(
                            _getImageTypeLabel(currentImageIndex.value),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                        ],
                        
                        SizedBox(height: 16.h),
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
