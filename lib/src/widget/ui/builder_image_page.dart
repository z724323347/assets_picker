import 'package:assets_picker/src/provider/asset_entity_image_provider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class BuilderImagePage extends StatelessWidget {
  const BuilderImagePage({
    Key key,
    this.asset,
  }) : super(key: key);

  /// Asset currently displayed.
  /// 展示的资源
  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ExtendedImage(
        image: AssetEntityImageProvider(asset),
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        onDoubleTap: (v) {},
        initGestureConfigHandler: (ExtendedImageState state) {
          return GestureConfig(
            initialScale: 1.0,
            minScale: 1.0,
            maxScale: 3.0,
            animationMinScale: 0.6,
            animationMaxScale: 4.0,
            cacheGesture: false,
            inPageView: true,
          );
        },
        loadStateChanged: (s) {
          return null;
        },
      ),
    );
  }
}
