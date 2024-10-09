import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension WidgetExtensions on Widget {
  // Responsive padding extension
  Padding get p8 => Padding(padding: EdgeInsets.all(8.w), child: this);
  Padding get p16 => Padding(padding: EdgeInsets.all(16.w), child: this);

  // Responsive margin extension
  Padding get m8 => Padding(padding: EdgeInsets.all(8.w), child: this);
  Padding get m16 => Padding(padding: EdgeInsets.all(16.w), child: this);

  // Symmetric padding for horizontal and vertical
  Padding get horizontalPadding16 => Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: this);
  Padding get verticalPadding8 => Padding(padding: EdgeInsets.symmetric(vertical: 8.h), child: this);

  // Rounded corners for cards, containers, etc.
  ClipRRect get roundedCorners => ClipRRect(borderRadius: BorderRadius.circular(12.r), child: this);
}
