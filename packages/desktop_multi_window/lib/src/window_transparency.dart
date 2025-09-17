/// Window transparency modes for Windows platform.
enum WindowTransparencyMode {
  /// No transparency (default)
  none,

  /// Color-key transparency - specific color becomes transparent
  colorKey,

  /// Per-pixel alpha transparency
  alpha,
}

/// Configuration for window transparency.
class WindowTransparencyConfig {
  /// The transparency mode to use.
  final WindowTransparencyMode mode;

  /// For color-key mode: the RGB color that will be transparent.
  /// Default is RGB(1, 254, 1) - a bright green that's rarely used.
  final int? colorKey;

  /// For alpha mode: the alpha value (0-255). 255 = opaque, 0 = fully transparent.
  /// For color-key mode: ignored.
  final int? alpha;

  /// Whether to add WS_EX_TOOLWINDOW style (window won't appear in taskbar).
  final bool toolWindow;

  /// Whether to add WS_EX_TRANSPARENT style (window won't receive input).
  final bool transparent;

  const WindowTransparencyConfig({
    this.mode = WindowTransparencyMode.none,
    this.colorKey,
    this.alpha,
    this.toolWindow = false,
    this.transparent = false,
  });

  /// Creates a color-key transparency configuration.
  const WindowTransparencyConfig.colorKey({
    int colorKey = 0x01FE01, // RGB(1, 254, 1)
    bool toolWindow = false,
    bool transparent = false,
  }) : this(
          mode: WindowTransparencyMode.colorKey,
          colorKey: colorKey,
          toolWindow: toolWindow,
          transparent: transparent,
        );

  /// Creates a per-pixel alpha transparency configuration.
  const WindowTransparencyConfig.alpha({
    int alpha = 255,
    bool toolWindow = false,
    bool transparent = false,
  }) : this(
          mode: WindowTransparencyMode.alpha,
          alpha: alpha,
          toolWindow: toolWindow,
          transparent: transparent,
        );

  /// Creates a simple color-key transparency configuration with safe defaults.
  factory WindowTransparencyConfig.simple({
    bool colorKey = true,
    bool toolWindow = true,
    bool clickThrough = false,
  }) {
    if (colorKey) {
      return WindowTransparencyConfig.colorKey(
        colorKey: 0x01FE01, // Verde seguro
        toolWindow: toolWindow,
        transparent: clickThrough,
      );
    } else {
      return WindowTransparencyConfig.alpha(
        alpha: 200,
        toolWindow: toolWindow,
        transparent: clickThrough,
      );
    }
  }

  /// Converts to a Map for platform channel communication.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'mode': mode.index,
      'toolWindow': toolWindow,
      'transparent': transparent,
    };

    // Solo agregar colorKey si no es null
    if (colorKey != null) {
      map['colorKey'] = colorKey;
    }

    // Solo agregar alpha si no es null
    if (alpha != null) {
      map['alpha'] = alpha;
    }

    return map;
  }

  /// Creates from a Map received from platform channel.
  factory WindowTransparencyConfig.fromMap(Map<String, dynamic> map) {
    return WindowTransparencyConfig(
      mode: WindowTransparencyMode.values[map['mode'] ?? 0],
      colorKey: map['colorKey'],
      alpha: map['alpha'],
      toolWindow: map['toolWindow'] ?? false,
      transparent: map['transparent'] ?? false,
    );
  }
}
