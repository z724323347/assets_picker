import 'constants.dart';

export '../delegates/sort_path_delegate.dart';
export '../delegates/text_delegate.dart';

export 'custom_scroll_physics.dart';
export 'picker_color.dart';

class Constants {
  const Constants._();

  static TextDelegate textDelegate = DefaultTextDelegate();
  static SortPathDelegate sortPathDelegate = SortPathDelegate.common;
}
