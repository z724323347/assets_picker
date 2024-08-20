import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:wechat_assets_picker/src/widget/builder/value_listenable_builder_2.dart';
// ignore: implementation_imports
import 'package:wechat_assets_picker/src/widget/scale_text.dart';

import '../../app_assets_picker.dart';

class AppAssetPickerViewerBuilderDelegate
    extends DefaultAssetPickerViewerBuilderDelegate {
  AppAssetPickerViewerBuilderDelegate({
    required int currentIndex,
    required List<AssetEntity> previewAssets,
    AssetPickerProvider<AssetEntity, AssetPathEntity>? selectorProvider,
    required ThemeData themeData,
    AssetPickerViewerProvider<AssetEntity>? provider,
    List<AssetEntity>? selectedAssets,
    ThumbnailSize? previewThumbnailSize,
    SpecialPickerType? specialPickerType,
    int? maxAssets,
    bool shouldReversePreview = false,
    AssetSelectPredicate<AssetEntity>? selectPredicate,
  }) : super(
          currentIndex: currentIndex,
          previewAssets: previewAssets,
          selectorProvider: selectorProvider,
          themeData: themeData,
          provider: provider,
          selectedAssets: selectedAssets,
          previewThumbnailSize: previewThumbnailSize,
          specialPickerType: specialPickerType,
          maxAssets: maxAssets,
          shouldReversePreview: shouldReversePreview,
          selectPredicate: selectPredicate,
        );

  @override
  // 统一到Apple样式
  bool get isAppleOS => true;

  @override
  Widget bottomDetailBuilder(BuildContext context) {
    final Color backgroundColor = themeData.primaryColor.withOpacity(.9);
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return ValueListenableBuilder2<bool, int>(
      firstNotifier: isDisplayingDetail,
      secondNotifier: selectedNotifier,
      builder: (_, bool v, __, Widget? child) {
        return AnimatedPositionedDirectional(
          duration: kThemeAnimationDuration,
          curve: Curves.easeInOut,
          bottom: v ? 0 : -(mediaQuery.padding.bottom + bottomDetailHeight),
          start: 0,
          end: 0,
          height: mediaQuery.padding.bottom + bottomDetailHeight,
          child: child!,
        );
      },
      child:
          ChangeNotifierProvider<AssetPickerViewerProvider<AssetEntity>?>.value(
        value: provider,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (provider != null)
              ValueListenableBuilder<int>(
                valueListenable: selectedNotifier,
                builder: (_, int count, __) {
                  return Container(
                    width: count > 0 ? double.maxFinite : 0,
                    height: bottomPreviewHeight,
                    color: backgroundColor,
                    child: ListView.builder(
                      controller: previewingListController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      physics: const ClampingScrollPhysics(),
                      itemCount: count,
                      itemBuilder: bottomDetailItemBuilder,
                    ),
                  );
                },
              ),
            Container(
              height: bottomBarHeight + mediaQuery.padding.bottom,
              padding: const EdgeInsets.symmetric(horizontal: 20.0)
                  .copyWith(bottom: mediaQuery.padding.bottom),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: themeData.canvasColor),
                ),
                color: backgroundColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  editButton(context),
                  const Spacer(),
                  if (isAppleOS && (provider != null || isWeChatMoment))
                    confirmButton(context)
                  else
                    selectButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget editButton(BuildContext context) {
    return ChangeNotifierProvider<AssetPickerViewerProvider<AssetEntity>>.value(
      value: provider!,
      builder: (BuildContext context, Widget? child) {
        return StreamBuilder<int>(
          initialData: currentIndex,
          stream: pageStreamController.stream,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            final AssetEntity asset = previewAssets.elementAt(snapshot.data!);

            return Selector<AssetPickerViewerProvider<AssetEntity>,
                List<AssetEntity>>(
              selector: (BuildContext context,
                  AssetPickerViewerProvider<AssetEntity> provider) {
                return provider.currentlySelectedAssets;
              },
              builder: (BuildContext context, List<AssetEntity> assets,
                  Widget? child) {
                void onTap() => onEditTap(context, asset);

                return Semantics(
                  button: true,
                  label: semanticsTextDelegate.edit,
                  onTap: onTap,
                  onTapHint: semanticsTextDelegate.edit,
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        Feedback.forTap(context);
                        onTap();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: child,
                    ),
                  ),
                );
              },
              child: child,
            );
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ScaleText(
            textDelegate.edit,
            style: const TextStyle(fontSize: 17, height: 1),
            semanticsLabel: semanticsTextDelegate.select,
          ),
        ],
      ),
    );
  }

  Future<AssetEntity?> onEditTap(BuildContext context, AssetEntity asset) {
    return AppAssetPicker.pushToEditor(context, asset: asset)
        .then((AssetEntity? newAsset) {
      if (newAsset != null) {
        viewerState.setState(() {
          if (isSelectedPreviewing) {
            previewAssets.remove(asset);
          }

          unSelectAsset(asset);
          selectAsset(newAsset);

          currentIndex = shouldReversePreview ? 0 : previewAssets.length;
          previewAssets.insert(currentIndex, newAsset);
        });

        selectedNotifier.value = selectedCount;
        pageController.jumpToPage(currentIndex);
        pageStreamController.add(currentIndex);
      }

      return newAsset;
    });
  }
}
