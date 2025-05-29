# 📱 Responsive Design Guide

## 📋 Overview

This guide provides comprehensive rules and best practices for implementing responsive UI designs in our Flutter application using `flutter_screenutil`. Follow these guidelines to ensure pixel-perfect, production-ready UI that works seamlessly across all device sizes.

## 🛠️ Setup & Configuration

### Current Setup
Our app is configured with the following design specifications:

```dart
ScreenUtilInit(
  designSize: const Size(411, 869), // Base design size (Figma/XD reference)
  minTextAdapt: true,                // Ensures minimum text scaling
  builder: (_, child) => MyApp(),
)
```

**Design Size Reference:** `411 x 869` (typically iPhone 11 Pro / standard mobile design)

## 📏 Responsive Units Guide

### 1. **Text Sizing** - Use `.sp`
```dart
// ✅ CORRECT
Text(
  'Hello World',
  style: TextStyle(fontSize: 16.sp), // Scales with screen size
)

// ❌ WRONG
Text(
  'Hello World',
  style: TextStyle(fontSize: 16), // Fixed size, not responsive
)
```

### 2. **Width Dimensions** - Use `.w`
```dart
// ✅ CORRECT
Container(
  width: 200.w, // Responsive width
  child: Text('Content'),
)

// ❌ WRONG
Container(
  width: 200, // Fixed width
  child: Text('Content'),
)
```

### 3. **Height Dimensions** - Use `.h`
```dart
// ✅ CORRECT
Container(
  height: 100.h, // Responsive height
  child: Text('Content'),
)

// ⚠️ CAUTION WITH FIXED HEIGHTS
Container(
  height: 100, // Use sparingly, can cause overflow
  child: Text('Content'),
)
```

### 4. **Border Radius** - Use `.r`
```dart
// ✅ CORRECT
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r), // Responsive radius
  ),
)

// ❌ WRONG
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12), // Fixed radius
  ),
)
```

### 5. **Padding & Margin** - Mix of responsive and fixed
```dart
// ✅ CORRECT - Responsive padding
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 12.h,
  ),
  child: Text('Content'),
)

// ✅ ALSO CORRECT - Using extension methods from your project
Text('Content').p16, // From widget_extension.dart
```

## 🚨 Edge Cases & Overflow Prevention

### 1. **Text Overflow Prevention**
```dart
// ✅ ALWAYS wrap text that might overflow
Text(
  'This is a very long text that might overflow on smaller screens',
  style: TextStyle(fontSize: 16.sp),
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
)

// ✅ For flexible text containers
Expanded(
  child: Text(
    'Long text content',
    style: TextStyle(fontSize: 16.sp),
  ),
)
```

### 2. **ListView & ScrollView Implementation**
```dart
// ✅ CORRECT - Always use Expanded or fixed height for scrollable content
Column(
  children: [
    Text('Header'),
    Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(items[index], style: TextStyle(fontSize: 14.sp)),
        ),
      ),
    ),
  ],
)

// ❌ WRONG - Can cause RenderFlex overflow
Column(
  children: [
    Text('Header'),
    ListView.builder(...), // Missing Expanded wrapper
  ],
)
```

### 3. **Row Overflow Prevention**
```dart
// ✅ CORRECT - Use Flexible/Expanded for dynamic content
Row(
  children: [
    Icon(Icons.star, size: 24.sp),
    SizedBox(width: 8.w),
    Expanded(
      child: Text(
        'Dynamic text content that might be long',
        style: TextStyle(fontSize: 14.sp),
        overflow: TextOverflow.ellipsis,
      ),
    ),
    Text('Fixed', style: TextStyle(fontSize: 12.sp)),
  ],
)

// ❌ WRONG - Fixed width without considering content
Row(
  children: [
    Container(
      width: 200.w, // Might overflow on smaller screens
      child: Text('Content'),
    ),
  ],
)
```

### 4. **Image Responsiveness**
```dart
// ✅ CORRECT - Responsive image sizing
Container(
  width: double.infinity,
  height: 200.h,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12.r),
    child: Image.network(
      imageUrl,
      fit: BoxFit.cover, // Prevents distortion
    ),
  ),
)

// ✅ For square images
AspectRatio(
  aspectRatio: 1.0,
  child: Image.network(imageUrl, fit: BoxFit.cover),
)
```

### 5. **Safe Area Implementation**
```dart
// ✅ ALWAYS consider safe areas for full-screen layouts
Scaffold(
  body: SafeArea(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: YourContent(),
    ),
  ),
)
```

## 🧪 Testing Responsive Design

### Setup Device Preview

1. **Add Device Preview** (Already in your pubspec.yaml)
```yaml
dev_dependencies:
  device_preview: ^1.2.0
```

2. **Modify Main Entry Point for Testing**
```dart
// Create a separate main_preview.dart for testing
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Only in debug mode
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 869),
      minTextAdapt: true,
      builder: (_, child) {
        return MaterialApp(
          useInheritedMediaQuery: true, // Required for device preview
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          // ...rest of your app config
        );
      },
    );
  }
}
```

3. **Run with Device Preview**
```bash
flutter run -t lib/main_preview.dart
```

### Testing Checklist

#### 📱 **Small Screens (320-480px width)**
- [ ] All text is readable (minimum 12.sp)
- [ ] Buttons are touchable (minimum 44.h height)
- [ ] No horizontal overflow
- [ ] Images scale properly
- [ ] Navigation elements are accessible

#### 📱 **Medium Screens (481-768px width)**
- [ ] Layout adapts to increased width
- [ ] Text doesn't become too small
- [ ] Proper spacing maintained
- [ ] Images maintain aspect ratio

#### 📱 **Large Screens (769px+ width)**
- [ ] Content doesn't stretch unnaturally
- [ ] Proper maximum width constraints
- [ ] Text remains readable
- [ ] Layout remains centered or properly aligned

#### 🔄 **Orientation Testing**
- [ ] Portrait mode works correctly
- [ ] Landscape mode handles content appropriately
- [ ] No overflow in either orientation

### Device Preview Testing Process

1. **Launch Device Preview**
   ```bash
   flutter run -t lib/main_preview.dart
   ```

2. **Test Critical Devices**
   - iPhone SE (Small screen)
   - iPhone 12 Pro (Medium screen)
   - iPad (Large screen)
   - Various Android devices

3. **Test Each Screen**
   - Navigate to every page
   - Test all interactive elements
   - Check scrolling behavior
   - Verify text readability

4. **Orientation Testing**
   - Rotate each device
   - Check layout adaptation
   - Verify no content is cut off

## 🎯 Best Practices Checklist

### ✅ **Do's**
- Always use `.sp` for font sizes
- Use `.w` and `.h` for responsive dimensions
- Use `.r` for border radius
- Wrap text with overflow handling
- Use `Expanded` or `Flexible` in `Row`/`Column`
- Test on multiple screen sizes
- Consider minimum touch targets (44.h)
- Use `SafeArea` for full-screen layouts

### ❌ **Don'ts**
- Don't use fixed pixel values for text
- Don't ignore overflow warnings
- Don't assume one screen size fits all
- Don't use fixed heights for dynamic content
- Don't forget to test landscape orientation
- Don't ignore safe area insets

## 📖 Example Implementation

Based on your project structure, here's a responsive implementation example:

```dart
class ResponsiveExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.loc.title,
          style: context.headlineMedium?.copyWith(fontSize: 18.sp),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              
              // Responsive card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  children: [
                    Text(
                      'Responsive Title',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'This text will scale appropriately across all screen sizes',
                      style: TextStyle(fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Responsive button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Responsive Button',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
              
              // Scrollable content
              Expanded(
                child: ListView.builder(
                  itemCount: 20,
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Theme.of(context).cardColor,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          child: Text('${index + 1}'),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Responsive list item ${index + 1}',
                            style: TextStyle(fontSize: 14.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
```

## 🔧 Debugging Overflow Issues

### Common Overflow Causes & Solutions

1. **Text Overflow**
   ```dart
   // Add overflow handling
   Text(
     'Long text',
     overflow: TextOverflow.ellipsis,
     maxLines: 1,
   )
   ```

2. **Row Overflow**
   ```dart
   // Wrap flexible content
   Row(
     children: [
       Icon(Icons.star),
       Expanded(child: Text('Flexible text')),
     ],
   )
   ```

3. **Image Overflow**
   ```dart
   // Constrain image size
   Container(
     constraints: BoxConstraints(maxWidth: 200.w),
     child: Image.network(url),
   )
   ```

## 📋 Pre-Production Checklist

Before releasing any UI changes:

- [ ] Tested on minimum 3 different screen sizes
- [ ] No overflow warnings in debug console
- [ ] All text is readable on smallest target device
- [ ] All interactive elements are properly sized
- [ ] Landscape orientation works correctly
- [ ] Safe area insets are properly handled
- [ ] Performance is acceptable on lower-end devices

---

**Remember:** Responsive design is not just about making things fit—it's about creating an optimal user experience across all devices. Always prioritize usability over perfect pixel matching.
