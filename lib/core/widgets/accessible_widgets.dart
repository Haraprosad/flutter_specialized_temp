import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessible button that guarantees a minimum 48×48 touch target (WCAG 2.5.5)
/// and exposes a semantic label to screen readers.
///
/// Use instead of bare [IconButton] or small [GestureDetector] wrappers.
class AccessibleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String semanticLabel;
  final double size;
  final Color? color;
  final String? tooltip;

  const AccessibleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.semanticLabel,
    this.size = 24,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Center(
              child: Icon(icon, size: size, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

/// Accessible image that provides [semanticLabel] for screen readers and
/// marks decorative images as excluded from the semantic tree.
class AccessibleImage extends StatelessWidget {
  final ImageProvider image;
  final String? semanticLabel;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Pass null for [semanticLabel] to mark the image as decorative
  /// (excluded from accessibility tree per WCAG 1.1.1).
  const AccessibleImage({
    super.key,
    required this.image,
    this.semanticLabel,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: semanticLabel == null,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}

/// Wraps any widget in a [Semantics] node with a [label] and optional [hint].
///
/// Use when Flutter's built-in widget doesn't surface the right semantic label
/// to TalkBack / VoiceOver (e.g. custom cards, stat tiles, chart segments).
class AccessibleLabel extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final bool isButton;
  final bool liveRegion;
  final VoidCallback? onTap;

  const AccessibleLabel({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.isButton = false,
    this.liveRegion = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      liveRegion: liveRegion,
      onTap: onTap,
      child: child,
    );
  }
}

/// Screen-reader-friendly loading indicator.
///
/// Announces "Loading, please wait" via [liveRegion] so VoiceOver / TalkBack
/// users know content is being fetched.
class AccessibleLoadingIndicator extends StatelessWidget {
  final String? semanticLabel;

  const AccessibleLoadingIndicator({
    super.key,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: semanticLabel ?? 'Loading, please wait',
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

/// Wraps a [TextField] with an explicit semantic label when the visual label
/// alone is insufficient (e.g. icon-only inputs, chat bubbles).
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String semanticLabel;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const AccessibleTextField({
    super.key,
    this.controller,
    required this.semanticLabel,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.decoration,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      textField: true,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        textInputAction: textInputAction,
        focusNode: focusNode,
        decoration: decoration ??
            InputDecoration(
              hintText: hintText,
              labelText: semanticLabel,
            ),
      ),
    );
  }
}

/// Announces a status message to screen readers without moving focus.
///
/// Useful for ephemeral status changes (form submission result, network
/// status change) that don't warrant a dialog or navigation.
class AnnouncementWidget extends StatefulWidget {
  final String message;
  final Widget child;

  const AnnouncementWidget({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  State<AnnouncementWidget> createState() => _AnnouncementWidgetState();
}

class _AnnouncementWidgetState extends State<AnnouncementWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(widget.message, TextDirection.ltr);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
