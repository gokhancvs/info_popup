import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:info_popup/info_popup.dart';

/// A widget that shows a popup with text.
class InfoPopupWidget extends StatefulWidget {
  /// Creates a [InfoPopupWidget] widget.
  const InfoPopupWidget({
    required this.child,
    this.onControllerCreated,
    this.infoPopupDismissed,
    this.contentTitle,
    this.customContent,
    this.areaBackgroundColor,
    this.arrowTheme,
    this.contentTheme,
    this.onAreaPressed,
    this.onLayoutMounted,
    this.dismissTriggerBehavior = PopupDismissTriggerBehavior.onTapArea,
    this.contentOffset,
    this.indicatorOffset,
    this.contentMaxWidth,
    super.key,
  }) : assert(customContent == null || contentTitle == null,
            'You can not use both customContent and contentTitle at the same time.');

  /// The [child] of the [InfoPopupWidget].
  final Widget child;

  /// [onControllerCreated] is called when the [InfoPopupController] is created.
  final OnControllerCreated? onControllerCreated;

  /// The [infoPopupDismissed] is the callback function when the popup is dismissed.
  final VoidCallback? infoPopupDismissed;

  /// The [contentTitle] to show in the popup.
  final String? contentTitle;

  /// The [customContent] is the widget that will be custom shown in the popup.
  final Widget? customContent;

  /// The [areaBackgroundColor] is the background color of the area that
  final Color? areaBackgroundColor;

  /// [arrowTheme] is the arrow theme of the popup.
  final InfoPopupArrowTheme? arrowTheme;

  /// [contentTheme] is the content theme of the popup.
  final InfoPopupContentTheme? contentTheme;

  /// [onAreaPressed] Called when the area outside the popup is pressed.
  final OnAreaPressed? onAreaPressed;

  /// [onLayoutMounted] Called when the info layout is mounted.
  final Function(Size size)? onLayoutMounted;

  /// The [dismissTriggerBehavior] is the showing behavior of the popup.
  final PopupDismissTriggerBehavior dismissTriggerBehavior;

  /// The [contentOffset] is the offset of the content..
  final Offset? contentOffset;

  /// The [indicatorOffset] is the offset of the indicator.
  final Offset? indicatorOffset;

  /// [contentMaxWidth] is the max width of the content that is shown.
  /// If the [contentMaxWidth] is null, the max width will be eighty percent
  /// of the screen.
  final double? contentMaxWidth;

  @override
  State<InfoPopupWidget> createState() => _InfoPopupWidgetState();
}

class _InfoPopupWidgetState extends State<InfoPopupWidget> {
  final GlobalKey<State<StatefulWidget>> _infoPopupTargetKey = GlobalKey();
  InfoPopupController? _infoPopupController;
  bool _isControllerInitialized = false;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    if (_infoPopupController != null && _infoPopupController!.isShowing) {
      _infoPopupController!.dismissInfoPopup();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _updateRenderBox());
    return GestureDetector(
      onTap: () {
        if (_infoPopupController != null && !_infoPopupController!.isShowing) {
          _infoPopupController!.show();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          key: _infoPopupTargetKey,
          child: widget.child,
        ),
      ),
    );
  }

  Future<void> _updateRenderBox() async {
    final BuildContext? context = _infoPopupTargetKey.currentContext;

    if (!mounted || context == null) {
      return;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return;
    }

    _infoPopupController = _infoPopupController ??= InfoPopupController(
      context: context,
      targetRenderBox: renderBox,
      layerLink: _layerLink,
      contentTitle: widget.contentTitle,
      customContent: widget.customContent,
      areaBackgroundColor: widget.areaBackgroundColor ??
          PopupConstants.defaultAreaBackgroundColor,
      arrowTheme: widget.arrowTheme ?? const InfoPopupArrowTheme(),
      contentTheme: widget.contentTheme ?? const InfoPopupContentTheme(),
      onAreaPressed: widget.onAreaPressed,
      onLayoutMounted: widget.onLayoutMounted,
      dismissTriggerBehavior: widget.dismissTriggerBehavior,
      infoPopupDismissed: widget.infoPopupDismissed,
      contentOffset: widget.contentOffset ?? const Offset(0, 0),
      indicatorOffset: widget.indicatorOffset ?? const Offset(0, 0),
      contentMaxWidth: widget.contentMaxWidth,
    );

    if (!_isControllerInitialized && widget.onControllerCreated != null) {
      widget.onControllerCreated!.call(_infoPopupController!);
    }

    _infoPopupController!.updateInfoPopupTargetRenderBox(renderBox);

    _isControllerInitialized = true;
  }
}
