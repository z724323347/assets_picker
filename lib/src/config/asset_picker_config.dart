import 'package:flutter/material.dart';

import '../../app_assets_picker.dart';

class AssetPickerConfigBuilder {
  const AssetPickerConfigBuilder({
    this.selectedAssets,
    this.maxAssets = 1,
    this.requestType = RequestType.all,
    this.themeColor,
    this.specialItemPosition = SpecialItemPosition.prepend,
    this.specialItemBuilder,
    this.selectPredicate,
    this.shouldRevertGrid = true,
    this.cameraPickerConfigBuilder = const CameraPickerConfigBuilder(),
  });

  final List<AssetEntity>? selectedAssets;
  final int maxAssets;
  final RequestType requestType;
  final Color? themeColor;
  final SpecialItemPosition specialItemPosition;
  final SpecialItemBuilder<AssetPathEntity>? specialItemBuilder;
  final AssetSelectPredicate<AssetEntity>? selectPredicate;
  final bool? shouldRevertGrid;

  final CameraPickerConfigBuilder? cameraPickerConfigBuilder;

  AssetPickerConfig build() {
    return AssetPickerConfig(
      selectedAssets: selectedAssets,
      maxAssets: maxAssets,
      requestType: requestType,
      themeColor: themeColor,
      specialItemPosition: specialItemPosition,
      specialItemBuilder: specialItemBuilder ??
          (specialItemPosition != SpecialItemPosition.none
              ? buildCameraItem
              : null),
      selectPredicate: selectPredicate,
      shouldRevertGrid: shouldRevertGrid,
    );
  }

  CameraPickerConfigBuilder buildForCamera() {
    return CameraPickerConfigBuilder(
      enableRecording: requestType.containsVideo(),
      onlyEnableRecording: requestType == RequestType.video,
    );
  }

  Widget? buildCameraItem(
    BuildContext context,
    AssetPathEntity? path,
    int length,
  ) {
    if (path?.isAll != true) {
      return null;
    }

    const AssetPickerTextDelegate textDelegate = AssetPickerTextDelegate();

    return Semantics(
      label: textDelegate.sActionUseCameraHint,
      button: true,
      onTapHint: textDelegate.sActionUseCameraHint,
      child: GestureDetector(
        onTap: () => onShotPressed(context),
        behavior: HitTestBehavior.opaque,
        child: const Center(
          child: Icon(Icons.camera_enhance, size: 42.0),
        ),
      ),
    );
  }

  void onShotPressed(BuildContext context) {
    Feedback.forTap(context);

    AppAssetPicker.pickFromCamera(
      context,
      pickerConfigBuilder: cameraPickerConfigBuilder ?? buildForCamera(),
    ).then((AssetEntity? entity) {
      if (entity == null) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pop(<AssetEntity>[entity]);
    });
  }
}
