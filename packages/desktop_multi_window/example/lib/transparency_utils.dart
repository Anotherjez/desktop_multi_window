import 'dart:ui';
import 'package:desktop_multi_window/desktop_multi_window.dart';

/// Función de utilidad para crear ventanas transparentes de forma segura
Future<WindowController?> createTransparentWindowSafe({
  String? arguments,
  bool colorKey = true,
  int? customColorKey,
  int? alpha,
  bool toolWindow = true,
  bool clickThrough = false,
}) async {
  try {
    WindowTransparencyConfig? config;

    if (colorKey) {
      config = WindowTransparencyConfig.colorKey(
        colorKey: customColorKey ?? 0x01FE01,
        toolWindow: toolWindow,
        transparent: clickThrough,
      );
    } else if (alpha != null) {
      config = WindowTransparencyConfig.alpha(
        alpha: alpha,
        toolWindow: toolWindow,
        transparent: clickThrough,
      );
    }

    final controller = await DesktopMultiWindow.createWindow(arguments, config);
    print(
        'Ventana transparente creada exitosamente con ID: ${controller.windowId}');
    return controller;
  } catch (e) {
    print('Error creando ventana transparente: $e');
    print('Intentando crear ventana normal como fallback...');

    try {
      final controller = await DesktopMultiWindow.createWindow(arguments);
      print(
          'Ventana normal creada como fallback con ID: ${controller.windowId}');
      return controller;
    } catch (e2) {
      print('Error creando ventana normal: $e2');
      return null;
    }
  }
}

/// Función simple para testing rápido
Future<void> testTransparency() async {
  print('=== Iniciando test de transparencia ===');

  // Test 1: Ventana normal
  print('\n1. Creando ventana normal...');
  final normal = await createTransparentWindowSafe(
    arguments: 'test_normal',
  );

  if (normal != null) {
    await normal.setFrame(const Rect.fromLTWH(100, 100, 300, 200));
    await normal.setTitle('Test Normal');
    await normal.show();
  }

  // Esperar un poco
  await Future.delayed(const Duration(seconds: 1));

  // Test 2: Ventana con color-key
  print('\n2. Creando ventana color-key...');
  final colorKey = await createTransparentWindowSafe(
    arguments: 'test_colorkey',
    colorKey: true,
    toolWindow: false,
  );

  if (colorKey != null) {
    await colorKey.setFrame(const Rect.fromLTWH(200, 150, 300, 200));
    await colorKey.setTitle('Test Color-Key');
    await colorKey.show();
  }

  // Esperar un poco
  await Future.delayed(const Duration(seconds: 1));

  // Test 3: Ventana con alpha
  print('\n3. Creando ventana alpha...');
  final alphaWindow = await createTransparentWindowSafe(
    arguments: 'test_alpha',
    colorKey: false,
    alpha: 200,
    toolWindow: false,
  );

  if (alphaWindow != null) {
    await alphaWindow.setFrame(const Rect.fromLTWH(300, 200, 300, 200));
    await alphaWindow.setTitle('Test Alpha');
    await alphaWindow.show();
  }

  print('\n=== Test completado ===');
}

/// Ejemplo de uso básico para copiar y pegar
/// 
/// ```dart
/// import 'package:your_package/transparency_utils.dart';
/// 
/// // Crear ventana transparente simple
/// final window = await createTransparentWindowSafe(
///   arguments: 'my_window',
///   colorKey: true,
///   toolWindow: true,
/// );
/// 
/// if (window != null) {
///   await window.show();
/// }
/// ```