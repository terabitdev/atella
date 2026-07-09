import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Drop-in replacement for Get.snackbar() compatible with Flutter 3.10+.
//
// GetX 4.7.x's overlayContext getter returns _Theater's context, but Flutter
// 3.10+ requires a context *inside* an overlay entry (where _RenderTheaterMarker
// lives) for Overlay.of() to succeed. We bypass Overlay.of() entirely by
// obtaining the OverlayState directly from Get.key.currentState?.overlay and
// inserting an OverlayEntry manually.
/// Shows the snackbar and returns a callback that dismisses this specific
/// instance. Needed for `showProgressIndicator: true` snackbars, which have
/// no auto-dismiss timer and must be closed manually — `Get.closeAllSnackbars()`
/// does NOT work here since this overlay entry is inserted directly and isn't
/// tracked by GetX's SnackbarController.
VoidCallback showAppSnackbar(
  String title,
  String message, {
  Color? colorText,
  Color? backgroundColor,
  SnackPosition? snackPosition,
  Duration? duration,
  EdgeInsets? margin,
  bool isDismissible = true,
  double? borderRadius,
  Widget? icon,
  bool showProgressIndicator = false,
}) {
  final overlayState = Get.key.currentState?.overlay;
  if (overlayState == null) return () {};

  final bgColor = backgroundColor ?? Colors.black;
  final txtColor = colorText ?? Colors.white;
  final dur = duration ?? const Duration(milliseconds: 1500);
  final isTop = (snackPosition ?? SnackPosition.TOP) != SnackPosition.BOTTOM;

  OverlayEntry? entry;
  var removed = false;

  void remove() {
    if (removed) return;
    removed = true;
    try {
      entry?.remove();
      entry?.dispose();
    } catch (_) {}
  }

  entry = OverlayEntry(
    builder: (context) => _AppSnackbarWidget(
      title: title,
      message: message,
      backgroundColor: bgColor,
      textColor: txtColor,
      isTop: isTop,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderRadius: borderRadius ?? 8,
      icon: icon,
      showProgressIndicator: showProgressIndicator,
      onDismiss: isDismissible ? remove : null,
    ),
  );

  overlayState.insert(entry);

  if (!showProgressIndicator) {
    Future.delayed(dur, remove);
  }

  return remove;
}

class _AppSnackbarWidget extends StatefulWidget {
  const _AppSnackbarWidget({
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.isTop,
    required this.margin,
    required this.borderRadius,
    this.icon,
    this.showProgressIndicator = false,
    this.onDismiss,
  });

  final String title;
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final bool isTop;
  final EdgeInsets margin;
  final double borderRadius;
  final Widget? icon;
  final bool showProgressIndicator;
  final VoidCallback? onDismiss;

  @override
  State<_AppSnackbarWidget> createState() => _AppSnackbarWidgetState();
}

class _AppSnackbarWidgetState extends State<_AppSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    final begin = widget.isTop ? const Offset(0, -1) : const Offset(0, 1);
    _slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Material(
      color: Colors.transparent,
      child: GestureDetector(
        onVerticalDragEnd: (_) => widget.onDismiss?.call(),
        child: Container(
          margin: widget.margin,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.showProgressIndicator) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(widget.textColor),
                  ),
                ),
                const SizedBox(width: 12),
              ] else if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.title.isNotEmpty)
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: widget.textColor,
                          fontSize: 14,
                        ),
                      ),
                    if (widget.title.isNotEmpty && widget.message.isNotEmpty)
                      const SizedBox(height: 2),
                    if (widget.message.isNotEmpty)
                      Text(
                        widget.message,
                        style:
                            TextStyle(color: widget.textColor, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return SafeArea(
      child: Align(
        alignment:
            widget.isTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(opacity: _fade, child: content),
        ),
      ),
    );
  }
}
