///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-19 10:06
///
import 'dart:ui' as ui;

import 'package:assets_picker/src/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom app bar.
/// 自定义的顶栏
class FixedAppBar extends StatelessWidget {
  const FixedAppBar({
    Key key,
    this.automaticallyImplyLeading = true,
    this.title,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation,
    this.actions,
    this.actionsPadding,
    this.height,
    this.blurRadius = 0.0,
  }) : super(key: key);

  /// Title widget.
  /// 标题部件
  final Widget title;

  /// Leading widget.
  /// 头部部件
  final Widget leading;

  /// Action widgets.
  /// 尾部操作部件
  final List<Widget> actions;

  /// Padding for actions.
  /// 尾部操作部分的内边距
  final EdgeInsetsGeometry actionsPadding;

  /// Whether it should imply leading with [BackButton] automatically.
  /// 是否会自动检测并添加返回按钮至头部
  final bool automaticallyImplyLeading;

  /// Whether the [title] should be at the center of the [FixedAppBar].
  /// [title] 是否会在正中间
  final bool centerTitle;

  /// Background color.
  /// 背景颜色
  final Color backgroundColor;

  /// The size of the shadow below the app bar.
  /// 底部阴影的大小
  final double elevation;

  /// Height of the app bar.
  /// 高度
  final double height;

  /// Value that can enable the app bar using filter with [ui.ImageFilter]
  /// 实现高斯模糊效果的值
  final double blurRadius;

  @override
  Widget build(BuildContext context) {
    final Color color = (backgroundColor ?? Theme.of(context).primaryColor)
        .withOpacity(blurRadius > 0.0 ? 0.90 : 1.0);

    Widget _title = title;
    if (centerTitle) {
      _title = Center(child: _title);
    }

    Widget child = Container(
      width: MediaQuery.of(context).size.width,
      height: (height ?? kToolbarHeight) + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: <Widget>[
          if (automaticallyImplyLeading && Navigator.of(context).canPop())
            leading ?? const BackButton(),
          if (_title != null)
            Positioned(
              top: 0.0,
              bottom: 0.0,
              left: automaticallyImplyLeading && Navigator.of(context).canPop()
                  ? kMinInteractiveDimension
                  : 0.0,
              right: kMinInteractiveDimension,
              child: Align(
                alignment: centerTitle
                    ? Alignment.center
                    : AlignmentDirectional.centerStart,
                child: DefaultTextStyle(
                  child: _title,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontSize: 23.0),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          if (automaticallyImplyLeading &&
              Navigator.of(context).canPop() &&
              (actions?.isEmpty ?? true))
            const SizedBox(width: kMinInteractiveDimension)
          else if (actions?.isNotEmpty ?? false)
            PositionedDirectional(
              end: 0.0,
              height: kToolbarHeight,
              child: Padding(
                padding: actionsPadding ?? EdgeInsets.zero,
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
            ),
        ],
      ),
    );

    if (blurRadius > 0.0) {
      child = ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
          child: child,
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.themeData.appBarTheme.brightness.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Material(
        type: color.isTransparent
            ? MaterialType.transparency
            : MaterialType.canvas,
        color: (backgroundColor ?? Theme.of(context).primaryColor)
            .withOpacity(blurRadius > 0.0 ? 0.90 : 1.0),
        elevation: elevation ?? context.themeData.appBarTheme.elevation ?? 4.0,
        child: child,
      ),
    );
  }
}

/// Wrapper for [FixedAppBar]. Avoid elevation covered by body.
/// 顶栏封装。防止内容块层级高于顶栏导致遮挡阴影。
class FixedAppBarWrapper extends StatelessWidget {
  const FixedAppBarWrapper({
    Key key,
    @required this.appBar,
    @required this.body,
  })  : assert(
          appBar != null && body != null,
          'All fields must not be null.',
        ),
        super(key: key);

  final FixedAppBar appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: body,
          ),
          Positioned(top: 0.0, left: 0.0, right: 0.0, child: appBar),
        ],
      ),
    );
  }
}
