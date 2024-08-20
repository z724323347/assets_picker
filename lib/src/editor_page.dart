import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';
import 'package:path/path.dart' as path;

import '../app_assets_picker.dart';

const double _bottomBarHeight = 36.0;

class ImageEditorPage extends StatefulWidget {
  const ImageEditorPage({
    Key? key,
    required this.file,
    this.cropAspectRatio,
    this.onEditStart,
    this.onEditEnd,
    this.onEditError,
  }) : super(key: key);

  final File file;
  final double? cropAspectRatio;
  final VoidCallback? onEditStart;
  final VoidCallback? onEditEnd;
  final void Function(dynamic error, StackTrace stackTrace)? onEditError;

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  final GlobalKey<ExtendedImageEditorState> _editorKey = GlobalKey();

  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ExtendedImage.file(
            widget.file,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.editor,
            extendedImageEditorKey: _editorKey,
            initEditorConfigHandler: _initEditorConfig,
            cacheRawData: true,
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: _buildBottomBar(context),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Container(
      height: _bottomBarHeight,
      margin: const EdgeInsets.symmetric(horizontal: 10) + mediaQuery.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            color: Colors.white,
            onPressed: _isEditing ? null : Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
          IconButton(
            color: Colors.white,
            onPressed: _isEditing ? null : _onConfirmPressed,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }

  EditorConfig? _initEditorConfig(ExtendedImageState? state) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return EditorConfig(
      maxScale: 8.0,
      // 裁剪框跟图片 layout 区域之间的距离。最好是保持一定距离，不然裁剪框边界很难进行拖拽
      cropRectPadding: const EdgeInsets.all(10) +
          // 留出底部栏的距离
          const EdgeInsets.only(bottom: _bottomBarHeight) +
          mediaQuery.padding,
      cornerSize: Size(30.0, 2.5),
      editorMaskColorHandler: _handleEditorMaskColor,
      cropAspectRatio: widget.cropAspectRatio,
    );
  }

  Color _handleEditorMaskColor(BuildContext context, bool pointerDown) {
    return Colors.black.withOpacity(pointerDown ? 0.3 : 0.7);
  }

  void _onConfirmPressed() {
    final ExtendedImageEditorState? editorState = _editorKey.currentState;
    final EditActionDetails? editAction = editorState?.editAction;
    // 从 ExtendedImageEditorState 中获取裁剪区域
    final Rect? cropRect = editorState?.getCropRect();

    if (editorState == null || editAction == null || cropRect == null) {
      return;
    }

    final ImageEditorOption option = ImageEditorOption()
      ..outputFormat = const OutputFormat.png();
    if (editAction.needCrop) {
      option.addOption(ClipOption.fromRect(cropRect));
    }

    widget.onEditStart?.call();
    setState(() {
      _isEditing = true;
    });

    ImageEditor.editImage(
      image: editorState.rawImageData,
      imageEditorOption: option,
    ).then((Uint8List? outImageData) {
      if (outImageData == null) {
        throw StateError('Edit image failed.');
      }
      final String title = path.basename(widget.file.path);
      // 将图片保存到图库
      return PhotoManager.editor.saveImage(outImageData, title: title);
    }).then((AssetEntity? entity) {
      if (!mounted) {
        return;
      }
      widget.onEditEnd?.call();
      Navigator.of(context).pop(entity);
    }).catchError((dynamic error, StackTrace stackTrace) {
      widget.onEditError?.call(error, stackTrace);
    }).whenComplete(() {
      if (!mounted) {
        return;
      }
      setState(() {
        _isEditing = false;
      });
    });
  }
}
