import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:wechat_assets_picker/src/widget/scale_text.dart';

import '../../app_assets_picker.dart';

class AppAssetPickerBuilderDelegate extends DefaultAssetPickerBuilderDelegate {
  AppAssetPickerBuilderDelegate({
    required DefaultAssetPickerProvider provider,
    required PermissionState initialPermission,
    int gridCount = 4,
    ThemeData? pickerTheme,
    SpecialItemPosition specialItemPosition = SpecialItemPosition.none,
    SpecialItemBuilder<AssetPathEntity>? specialItemBuilder,
    LoadingIndicatorBuilder? loadingIndicatorBuilder,
    AssetSelectPredicate<AssetEntity>? selectPredicate,
    bool? shouldRevertGrid,
    LimitedPermissionOverlayPredicate? limitedPermissionOverlayPredicate,
    PathNameBuilder<AssetPathEntity>? pathNameBuilder,
    ThumbnailSize gridThumbnailSize = defaultAssetGridPreviewSize,
    ThumbnailSize? previewThumbnailSize,
    SpecialPickerType? specialPickerType,
    bool keepScrollOffset = false,
    Color? themeColor,
    AssetPickerTextDelegate? textDelegate,
    Locale? locale,
  }) : super(
          provider: provider,
          initialPermission: initialPermission,
          gridCount: gridCount,
          pickerTheme: pickerTheme,
          specialItemPosition: specialItemPosition,
          specialItemBuilder: specialItemBuilder,
          loadingIndicatorBuilder: loadingIndicatorBuilder,
          selectPredicate: selectPredicate,
          shouldRevertGrid: shouldRevertGrid,
          limitedPermissionOverlayPredicate: limitedPermissionOverlayPredicate,
          pathNameBuilder: pathNameBuilder,
          gridThumbnailSize: gridThumbnailSize,
          previewThumbnailSize: previewThumbnailSize,
          specialPickerType: specialPickerType,
          keepScrollOffset: keepScrollOffset,
          themeColor: themeColor,
          textDelegate: textDelegate,
          locale: locale,
        );

  @override
  // 统一到Apple样式
  bool get isAppleOS => true;

  @override
  Widget previewButton(BuildContext context) {
    return Consumer<DefaultAssetPickerProvider>(
      builder: (_, DefaultAssetPickerProvider p, Widget? child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isSwitchingPath,
          builder: (_, bool isSwitchingPath, __) {
            return Semantics(
              enabled: p.isSelectedNotEmpty,
              focusable: !isSwitchingPath,
              hidden: isSwitchingPath,
              onTapHint: semanticsTextDelegate.sActionPreviewHint,
              child: child,
            );
          },
        );
      },
      child: Consumer<DefaultAssetPickerProvider>(
        builder: (_, DefaultAssetPickerProvider p, __) {
          return GestureDetector(
            onTap: p.isSelectedNotEmpty
                ? () => _onPreviewTap(context: context)
                : null,
            child: Selector<DefaultAssetPickerProvider, String>(
              selector: (_, DefaultAssetPickerProvider p) {
                return p.selectedDescriptions;
              },
              builder: (BuildContext c, __, ___) {
                final ThemeData theme = Theme.of(c);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ScaleText(
                    '${textDelegate.preview}'
                    '${p.isSelectedNotEmpty ? ' (${p.selectedAssets.length})' : ''}',
                    style: TextStyle(
                      color: p.isSelectedNotEmpty
                          ? null
                          : theme.textTheme.caption?.color,
                      fontSize: 17,
                    ),
                    maxScaleFactor: 1.2,
                    semanticsLabel: '${semanticsTextDelegate.preview}'
                        '${p.isSelectedNotEmpty ? ' (${p.selectedAssets.length})' : ''}',
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget selectedBackdrop(BuildContext context, int index, AssetEntity asset) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double indicatorSize = mediaQuery.size.width / gridCount / 3;

    return Positioned.fill(
      child: GestureDetector(
        onTap: isPreviewEnabled
            ? () => _onPreviewTap(
                  context: context,
                  index: index,
                  currentAsset: asset,
                  // 通常用户使用苹果系统时，点击网格内容进行预览，是反向进行预览。
                  shouldReversePreview: isAppleOS,
                )
            : null,
        child: Consumer<DefaultAssetPickerProvider>(
          builder: (_, DefaultAssetPickerProvider p, __) {
            final int index = p.selectedAssets.indexOf(asset);
            final bool selected = index != -1;
            return AnimatedContainer(
              duration: switchingPathDuration,
              padding: EdgeInsets.all(indicatorSize * .35),
              color: selected
                  ? theme.colorScheme.primary.withOpacity(.45)
                  : theme.backgroundColor.withOpacity(.1),
              child: selected && !isSingleAssetMode
                  ? Align(
                      alignment: AlignmentDirectional.topStart,
                      child: SizedBox(
                        height: indicatorSize / 2.5,
                        child: FittedBox(
                          alignment: AlignmentDirectional.topStart,
                          fit: BoxFit.cover,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: theme.textTheme.bodyText1?.color
                                  ?.withOpacity(.75),
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onPreviewTap({
    required BuildContext context,
    int index = 0,
    AssetEntity? currentAsset,
    bool shouldReversePreview = false,
  }) {
    final DefaultAssetPickerProvider provider =
        context.read<DefaultAssetPickerProvider>();

    final List<AssetEntity> previewAssets;
    final List<AssetEntity>? selectedAssets;
    final int currentIndex;

    if (currentAsset == null) {
      if (isWeChatMoment) {
        previewAssets = provider.selectedAssets
            .where((AssetEntity e) => e.type == AssetType.image)
            .toList();
      } else {
        previewAssets = provider.selectedAssets;
      }
      selectedAssets = previewAssets;
      currentIndex = index;
    } else {
      bool selectedAllAndNotSelected() =>
          !provider.selectedAssets.contains(currentAsset) &&
          provider.selectedMaximumAssets;
      bool selectedPhotosAndIsVideo() =>
          isWeChatMoment &&
          currentAsset.type == AssetType.video &&
          provider.selectedAssets.isNotEmpty;
      // When we reached the maximum select count and the asset
      // is not selected, do nothing.
      // When the special type is WeChat Moment, pictures and videos cannot
      // be selected at the same time. Video select should be banned if any
      // pictures are selected.
      if (selectedAllAndNotSelected() || selectedPhotosAndIsVideo()) {
        return Future<void>.value();
      }

      if (isWeChatMoment) {
        if (currentAsset.type == AssetType.video) {
          previewAssets = <AssetEntity>[currentAsset];
          selectedAssets = null;
          currentIndex = 0;
        } else {
          previewAssets = provider.currentAssets
              .where((AssetEntity e) => e.type == AssetType.image)
              .toList();
          selectedAssets = provider.selectedAssets;
          currentIndex = previewAssets.indexOf(currentAsset);
        }
      } else {
        previewAssets = provider.currentAssets;
        selectedAssets = provider.selectedAssets;
        currentIndex = index;
      }
    }

    final List<AssetEntity>? selectedAssetsSnapshot =
        selectedAssets?.toList(growable: false);

    return AppAssetPicker.pushToViewer(
      context,
      currentIndex: currentIndex,
      previewAssets: previewAssets,
      themeData: theme,
      previewThumbnailSize: previewThumbnailSize,
      selectPredicate: selectPredicate,
      selectedAssets: selectedAssets,
      selectorProvider: provider,
      specialPickerType: specialPickerType,
      maxAssets: provider.maxAssets,
      shouldReversePreview: shouldReversePreview,
    ).then((List<AssetEntity>? result) {
      if (result != null) {
        Navigator.of(context).maybePop(result);
        return;
      }

      final bool selectedChanged = !const ListEquality<AssetEntity>()
          .equals(selectedAssetsSnapshot, provider.selectedAssets);
      if (selectedChanged) {
        // Refresh image list
        provider.currentPath?.path
            .obtainForNewProperties()
            .then((AssetPathEntity currentPath) {
          provider
            ..currentPath = PathWrapper(path: currentPath)
            ..switchPath(PathWrapper(path: currentPath));
        });
      }
    });
  }
}
