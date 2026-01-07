import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import '../../controllers/tech_pack_ready_controller.dart';

class SaveTechPackDialog extends StatelessWidget {
  final Function(String projectName, String collectionName) onSave;

  const SaveTechPackDialog({super.key, required this.onSave});

  void _showAddCollectionDialog(
    BuildContext context,
    TechPackReadyController controller,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return AddCollectionDialog(
          onAdd: (String newCollection) {
            controller.addNewCollection(newCollection);
          },
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
    );
  }

  String _getLocalizedCollectionName(BuildContext context, String collectionName) {
    final l10n = AppLocalizations.of(context)!;
    if (collectionName == 'SUMMER COLLECTION') {
      return l10n.collectionSummer;
    } else if (collectionName == 'WINTER COLLECTION') {
      return l10n.collectionWinter;
    }
    return collectionName;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TechPackReadyController>();
    final l10n = AppLocalizations.of(context)!;

    return Material(
      type: MaterialType.transparency,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.tpwSaveTechPack, style: dbTitleTextTextStyle18700),
              SizedBox(height: 20.h),

              // Project Name Field
              Text(l10n.tpwProjectName, style: dbTitleTextTextStyle12400),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.projectNameController,
                decoration: InputDecoration(
                  hintText: l10n.tpwEnterProjectName,
                  hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Color(0xFF1A1A1A), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Collection Name Field
              Text(l10n.tpwCollectionName, style: dbTitleTextTextStyle12400),
              SizedBox(height: 8.h),
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedCollection.value,
                      items: controller.collections.map((String collection) {
                        return DropdownMenuItem<String>(
                          value: collection,
                          child: Text(
                            _getLocalizedCollectionName(context, collection),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Color(0xFF333333),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.updateSelectedCollection(newValue);
                        }
                      },
                      isExpanded: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _showAddCollectionDialog(context, controller),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: BorderSide(color: Color(0xFF1A1A1A)),
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 20.w,
                        ),
                      ),
                      child: Text(
                        l10n.tpwAdd,
                        style: dbTitleTextTextStyle12500,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (controller.projectNameController.text
                            .trim()
                            .isEmpty) {
                          Get.snackbar(
                            l10n.tpwError,
                            l10n.tpwPleaseEnterProjectName,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // Close dialog first using Navigator to ensure it closes
                        Navigator.of(context).pop();

                        // Add small delay to ensure dialog closes before calling onSave
                        await Future.delayed(Duration(milliseconds: 100));

                        onSave(
                          controller.projectNameController.text.trim(),
                          controller.selectedCollection.value,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A1A1A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        l10n.tpwSave,
                        style: dbTitleTextTextStyle12500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddCollectionDialog extends StatefulWidget {
  final Function(String) onAdd;

  const AddCollectionDialog({super.key, required this.onAdd});

  @override
  State<AddCollectionDialog> createState() => _AddCollectionDialogState();
}

class _AddCollectionDialogState extends State<AddCollectionDialog> {
  final TextEditingController _collectionController = TextEditingController();

  @override
  void dispose() {
    _collectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tpwAddCollection,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 20.h),

            TextField(
              controller: _collectionController,
              decoration: InputDecoration(
                hintText: l10n.tpwEnterCollectionName,
                hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xFF1A1A1A), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_collectionController.text.trim().isEmpty) {
                    Get.snackbar(
                      l10n.tpwError,
                      l10n.tpwPleaseEnterCollectionName,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  widget.onAdd(_collectionController.text.trim().toUpperCase());
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  l10n.tpwSave,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
