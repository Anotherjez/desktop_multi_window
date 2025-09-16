import 'dart:ui';

import 'window_controller_impl.dart';
import 'window_transparency.dart';

/// The [WindowController] instance that is used to control this window.
abstract class WindowController {
  WindowController();

  factory WindowController.fromWindowId(int id) {
    return WindowControllerMainImpl(id);
  }

  factory WindowController.main() {
    return WindowControllerMainImpl(0);
  }

  /// The id of the window.
  /// 0 means the main window.
  int get windowId;

  /// Close the window.
  Future<void> close();

  /// Show the window.
  Future<void> show();

  /// Hide the window.
  Future<void> hide();

  /// Set the window frame rect.
  Future<void> setFrame(Rect frame);

  /// Center the window on the screen.
  Future<void> center();

  /// Set the window's title.
  Future<void> setTitle(String title);

  /// Whether the window can be resized. Available only on macOS.
  ///
  /// Most useful for ensuring windows *cannot* be resized. Windows are
  /// resizable by default, so there is no need to explicitly define a window
  /// as resizable by calling this function.
  Future<void> resizable(bool resizable);

  /// Available only on macOS.
  Future<void> setFrameAutosaveName(String name);

  /// Set window transparency. Available only on Windows.
  ///
  /// [config] - The transparency configuration to apply.
  Future<void> setTransparency(WindowTransparencyConfig config);

  /// Set color-key transparency. Available only on Windows.
  ///
  /// [colorKey] - RGB color that will become transparent (default: 0x01FE01).
  /// [toolWindow] - Whether to hide from taskbar.
  /// [transparent] - Whether to make window click-through.
  Future<void> setColorKeyTransparency({
    int colorKey = 0x01FE01,
    bool toolWindow = false,
    bool transparent = false,
  });

  /// Set per-pixel alpha transparency. Available only on Windows.
  ///
  /// [alpha] - Alpha value 0-255 (255 = opaque, 0 = fully transparent).
  /// [toolWindow] - Whether to hide from taskbar.
  /// [transparent] - Whether to make window click-through.
  Future<void> setAlphaTransparency({
    int alpha = 255,
    bool toolWindow = false,
    bool transparent = false,
  });
}
