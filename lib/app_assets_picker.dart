library app_assets_picker;

import 'dart:io';

import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:wechat_assets_picker/src/internal/singleton.dart';

import 'app_assets_picker.dart';

export 'package:wechat_assets_picker/wechat_assets_picker.dart';
export 'package:wechat_camera_picker/wechat_camera_picker.dart';

export 'src/config/asset_picker_config.dart';
export 'src/config/camera_picker_config.dart';
export 'src/delegate/picker_builder_delegate.dart';
export 'src/delegate/viewer_builder_delegate.dart';
export 'src/editor_page.dart';

// ignore: avoid_classes_with_only_static_members
class AppAssetPicker {
  static Future<List<AssetEntity>?> pickAssets(
    BuildContext context, {
    AssetPickerConfigBuilder pickerConfigBuilder =
        const AssetPickerConfigBuilder(),
    bool useRootNavigator = true,
    AssetPickerPageRouteBuilder<List<AssetEntity>>? pageRouteBuilder,
  }) async {
    final PermissionState permissionState = await AssetPicker.permissionCheck();

    final AssetPickerConfig pickerConfig = pickerConfigBuilder.build();
    final DefaultAssetPickerProvider provider = DefaultAssetPickerProvider(
      maxAssets: pickerConfig.maxAssets,
      pageSize: pickerConfig.pageSize,
      pathThumbnailSize: pickerConfig.pathThumbnailSize,
      selectedAssets: pickerConfig.selectedAssets,
      requestType: pickerConfig.requestType,
      sortPathDelegate: pickerConfig.sortPathDelegate,
      filterOptions: pickerConfig.filterOptions,
    );
    final AppAssetPickerBuilderDelegate delegate =
        AppAssetPickerBuilderDelegate(
      provider: provider,
      initialPermission: permissionState,
      gridCount: pickerConfig.gridCount,
      pickerTheme: pickerConfig.pickerTheme,
      gridThumbnailSize: pickerConfig.gridThumbnailSize,
      previewThumbnailSize: pickerConfig.previewThumbnailSize,
      specialPickerType: pickerConfig.specialPickerType,
      specialItemPosition: pickerConfig.specialItemPosition,
      specialItemBuilder: pickerConfig.specialItemBuilder,
      loadingIndicatorBuilder: pickerConfig.loadingIndicatorBuilder,
      selectPredicate: pickerConfig.selectPredicate,
      shouldRevertGrid: pickerConfig.shouldRevertGrid,
      limitedPermissionOverlayPredicate:
          pickerConfig.limitedPermissionOverlayPredicate,
      pathNameBuilder: pickerConfig.pathNameBuilder,
      textDelegate: pickerConfig.textDelegate,
      themeColor: pickerConfig.themeColor,
      // ignore: use_build_context_synchronously
      locale: Localizations.maybeLocaleOf(context),
    );

    final Widget picker = AssetPicker<AssetEntity, AssetPathEntity>(
      // key: Singleton.pickerKey,
      builder: delegate,
    );

    // ignore: use_build_context_synchronously
    return Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).push<List<AssetEntity>>(
      pageRouteBuilder?.call(picker) ??
          AssetPickerPageRoute<List<AssetEntity>>(builder: (_) => picker),
    );
  }

  static Future<List<AssetEntity>?> pushToViewer(
    BuildContext context, {
    int currentIndex = 0,
    required List<AssetEntity> previewAssets,
    required ThemeData themeData,
    DefaultAssetPickerProvider? selectorProvider,
    ThumbnailSize? previewThumbnailSize,
    List<AssetEntity>? selectedAssets,
    SpecialPickerType? specialPickerType,
    int? maxAssets,
    bool shouldReversePreview = false,
    AssetSelectPredicate<AssetEntity>? selectPredicate,
  }) {
    final AppAssetPickerViewerBuilderDelegate delegate =
        AppAssetPickerViewerBuilderDelegate(
      currentIndex: currentIndex,
      previewAssets: previewAssets,
      provider: selectedAssets != null
          ? AssetPickerViewerProvider<AssetEntity>(selectedAssets)
          : null,
      themeData: themeData,
      previewThumbnailSize: previewThumbnailSize,
      specialPickerType: specialPickerType,
      selectedAssets: selectedAssets,
      selectorProvider: selectorProvider,
      maxAssets: maxAssets,
      shouldReversePreview: shouldReversePreview,
      selectPredicate: selectPredicate,
    );

    return AssetPickerViewer.pushToViewerWithDelegate(
      context,
      delegate: delegate,
    );
  }

  static Future<AssetEntity?> pickFromCamera(
    BuildContext context, {
    CameraPickerConfigBuilder pickerConfigBuilder =
        const CameraPickerConfigBuilder(),
    bool useRootNavigator = true,
    // CameraPickerPageRoute<AssetEntity>? pageRouteBuilder,
  }) {
    return CameraPicker.pickFromCamera(
      context,
      pickerConfig: pickerConfigBuilder.build(),
      useRootNavigator: useRootNavigator,
      // pageRouteBuilder: (_) => pageRouteBuilder!,
    );
  }

  static Future<AssetEntity?> pushToEditor(
    BuildContext context, {
    required dynamic asset,
    double? cropAspectRatio,
    VoidCallback? onEditStart,
    VoidCallback? onEditEnd,
    void Function(dynamic error, StackTrace stackTrace)? onEditError,
    bool useRootNavigator = true,
  }) async {
    final File file;
    if (asset is File) {
      file = asset;
    } else if (asset is AssetEntity) {
      file = await asset.file.then((File? file) {
        if (file == null) {
          throw StateError('Get file failed.');
        }
        return file;
      });
    } else {
      throw UnimplementedError('Not supported for ${asset.runtimeType}');
    }

    final PageRouteBuilder<AssetEntity> pageRoute =
        PageRouteBuilder<AssetEntity>(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return ImageEditorPage(
          file: file,
          cropAspectRatio: cropAspectRatio,
          onEditStart: onEditStart,
          onEditEnd: onEditEnd,
          onEditError: onEditError,
        );
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return FadeTransition(opacity: animation, child: child);
      },
    );

    // ignore: use_build_context_synchronously
    return Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).push(pageRoute);
  }
}
