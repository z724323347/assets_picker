import 'package:assets_picker/src/constants/constants.dart';
import 'package:flutter/material.dart';

class AssetPicker extends StatelessWidget {
  AssetPicker({
    Key key,
    this.pickerTheme,
    int gridCount = 4,
    Color themeColor,
  })  : assert(
          pickerTheme == null || themeColor == null,
          'Theme and theme color cannot be set at the same time.',
        ),
        gridCount = gridCount ?? 4,
        themeColor = pickerTheme?.colorScheme?.primary ??
            themeColor ??
            PickerColor.themeColor,
        super(key: key) {}

  /// Assets count for picker.
  /// 资源网格数
  final int gridCount;

  /// Main color for picker.
  /// 选择器的主题色
  final Color themeColor;

  /// Theme for the picker.
  /// 选择器的主题
  ///
  /// Usually the WeChat uses the dark version (dark background color) for the picker,
  /// but some developer wants a light theme version for some reasons.
  /// 通常情况下微信选择器使用的是暗色（暗色背景）的主题，可自定义主题。
  final ThemeData pickerTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      child: const Text('test'),
    );
  }
}
