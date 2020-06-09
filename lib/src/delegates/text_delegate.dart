/// Text delegate that controls text in widgets.
/// 控制部件中的文字实现
abstract class TextDelegate {
  /// Confirm string for confirm button.
  /// 确认按钮的字段
  String confirm;

  /// Cancel string for back button.
  /// 返回按钮的字段
  String cancel;

  /// Edit string for edit button.
  /// 编辑按钮的字段
  String edit;

  /// Placeholder when there's nothing can displayed in the picker.
  /// 选择器没有可显示的内容时的占位字段
  String emptyPlaceHolder;

  /// GIF indicator string.
  /// GIF指示的字段
  String gifIndicator;

  /// HEIC failed string.
  /// HEIC类型资源加载失败的字段
  String heicNotSupported;

  /// Load failed string for item.
  /// 资源加载失败时的字段
  String loadFailed;

  /// Original string for original selection.
  /// 选择是否原图的字段
  String original;

  /// Preview string for preview button.
  /// 预览按钮的字段
  String preview;

  /// Select string for select button.
  /// 选择按钮的字段
  String select;

  /// Un-supported asset type string for asset that belongs to [AssetType.other].
  /// 未支持的资源类型的字段
  String unSupportedAssetType;

  /// This is used in video asset item in picker, in order to display
  /// the duration of the video or audio type of asset.
  /// 该字段用在选择器视频或音频部件上，用于显示视频或音频资源的时长。
  String durationIndicatorBuilder(Duration duration);
}

/// Default text delegate implements with Chinese.
/// 中文文字实现
class DefaultTextDelegate implements TextDelegate {
  factory DefaultTextDelegate() => _instance;

  DefaultTextDelegate._internal();

  static final DefaultTextDelegate _instance = DefaultTextDelegate._internal();

  @override
  String confirm = '确认';

  @override
  String cancel = '取消';

  @override
  String edit = '编辑';

  @override
  String emptyPlaceHolder = '这里空空如也';

  @override
  String gifIndicator = 'GIF';

  @override
  String heicNotSupported = '尚未支持HEIC类型资源';

  @override
  String loadFailed = '加载失败';

  @override
  String original = '原图';

  @override
  String preview = '预览';

  @override
  String select = '选择';

  @override
  String unSupportedAssetType = '尚未支持的资源类型';

  @override
  String durationIndicatorBuilder(Duration duration) {
    const String separator = ':';
    final String minute = duration.inMinutes.toString().padLeft(2, '0');
    final String second =
        ((duration - Duration(minutes: duration.inMinutes)).inSeconds)
            .toString()
            .padLeft(2, '0');
    return '$minute$separator$second';
  }
}

/// [TextDelegate] implements with English.
/// 英文文字实现
class EnglishTextDelegate implements TextDelegate {
  factory EnglishTextDelegate() => _instance;

  EnglishTextDelegate._internal();

  static final EnglishTextDelegate _instance = EnglishTextDelegate._internal();

  @override
  String confirm = 'Confirm';

  @override
  String cancel = 'Cancel';

  @override
  String edit = 'Edit';

  @override
  String emptyPlaceHolder = 'Nothing here...';

  @override
  String gifIndicator = 'GIF';

  @override
  String heicNotSupported = 'Unsupported HEIC asset type.';

  @override
  String loadFailed = 'Load failed';

  @override
  String original = 'Origin';

  @override
  String preview = 'Preview';

  @override
  String select = 'Select';

  @override
  String unSupportedAssetType = 'Unsupported HEIC asset type.';

  @override
  String durationIndicatorBuilder(Duration duration) {
    const String separator = ':';
    final String minute = duration.inMinutes.toString().padLeft(2, '0');
    final String second =
        ((duration - Duration(minutes: duration.inMinutes)).inSeconds)
            .toString()
            .padLeft(2, '0');
    return '$minute$separator$second';
  }
}
