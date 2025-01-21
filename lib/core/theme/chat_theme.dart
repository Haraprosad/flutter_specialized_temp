import 'package:flutter/material.dart';

class ChatTheme extends ThemeExtension<ChatTheme> {
  final Color outgoingBubbleColor;    // For messages sent by current user
  final Color outgoingTextColor;
  final Color humanReplyBubbleColor;   // For messages from other human
  final Color humanReplyTextColor;
  final Color aiReplyBubbleColor;      // For AI responses
  final Color aiReplyTextColor;
  final TextStyle timestampTextStyle;
  final BorderRadius bubbleBorderRadius;
  final TextStyle messageTextStyle;
  final InputDecoration chatInputDecoration;

  ChatTheme({
    required this.outgoingBubbleColor,
    required this.outgoingTextColor,
    required this.humanReplyBubbleColor,
    required this.humanReplyTextColor,
    required this.aiReplyBubbleColor,
    required this.aiReplyTextColor,
    required this.timestampTextStyle,
    required this.bubbleBorderRadius,
    required this.messageTextStyle,
    required this.chatInputDecoration,
  });

  @override
  ThemeExtension<ChatTheme> copyWith({
    Color? outgoingBubbleColor,
    Color? outgoingTextColor,
    Color? humanReplyBubbleColor,
    Color? humanReplyTextColor,
    Color? aiReplyBubbleColor,
    Color? aiReplyTextColor,
    TextStyle? timestampTextStyle,
    BorderRadius? bubbleBorderRadius,
    TextStyle? messageTextStyle,
    InputDecoration? chatInputDecoration,
  }) {
    return ChatTheme(
      outgoingBubbleColor: outgoingBubbleColor ?? this.outgoingBubbleColor,
      outgoingTextColor: outgoingTextColor ?? this.outgoingTextColor,
      humanReplyBubbleColor: humanReplyBubbleColor ?? this.humanReplyBubbleColor,
      humanReplyTextColor: humanReplyTextColor ?? this.humanReplyTextColor,
      aiReplyBubbleColor: aiReplyBubbleColor ?? this.aiReplyBubbleColor,
      aiReplyTextColor: aiReplyTextColor ?? this.aiReplyTextColor,
      timestampTextStyle: timestampTextStyle ?? this.timestampTextStyle,
      bubbleBorderRadius: bubbleBorderRadius ?? this.bubbleBorderRadius,
      messageTextStyle: messageTextStyle ?? this.messageTextStyle,
      chatInputDecoration: chatInputDecoration ?? this.chatInputDecoration,
    );
  }

  @override
  ThemeExtension<ChatTheme> lerp(ThemeExtension<ChatTheme>? other, double t) {
    if (other is! ChatTheme) {
      return this;
    }
    return ChatTheme(
      outgoingBubbleColor: Color.lerp(outgoingBubbleColor, other.outgoingBubbleColor, t)!,
      outgoingTextColor: Color.lerp(outgoingTextColor, other.outgoingTextColor, t)!,
      humanReplyBubbleColor: Color.lerp(humanReplyBubbleColor, other.humanReplyBubbleColor, t)!,
      humanReplyTextColor: Color.lerp(humanReplyTextColor, other.humanReplyTextColor, t)!,
      aiReplyBubbleColor: Color.lerp(aiReplyBubbleColor, other.aiReplyBubbleColor, t)!,
      aiReplyTextColor: Color.lerp(aiReplyTextColor, other.aiReplyTextColor, t)!,
      timestampTextStyle: TextStyle.lerp(timestampTextStyle, other.timestampTextStyle, t)!,
      bubbleBorderRadius: BorderRadius.lerp(bubbleBorderRadius, other.bubbleBorderRadius, t)!,
      messageTextStyle: TextStyle.lerp(messageTextStyle, other.messageTextStyle, t)!,
      chatInputDecoration: chatInputDecoration,
    );
  }
}
