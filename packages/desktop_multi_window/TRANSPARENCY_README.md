# Soporte de Transparencia en Windows para desktop_multi_window

Esta implementación agrega soporte completo para transparencia real en Windows, incluyendo color-key transparency, per-pixel alpha transparency, y opciones avanzadas como tool windows y click-through windows.

## Características Implementadas

### 1. Color-Key Transparency
- Un color específico RGB se vuelve completamente transparente
- Ideal para crear overlays con formas irregulares
- Por defecto usa RGB(1, 254, 1) - un verde brillante raramente usado

### 2. Per-Pixel Alpha Transparency
- Transparencia basada en el canal alpha de cada pixel
- Permite efectos de transparencia graduales y suaves
- Valor alpha de 0-255 (255 = opaco, 0 = completamente transparente)

### 3. Tool Window
- La ventana no aparece en la barra de tareas
- Útil para overlays y ventanas auxiliares

### 4. Click-Through (Transparent)
- Los eventos de mouse pasan a través de la ventana
- Útil para overlays informativos que no deben interferir con la interacción

## API de Uso

### Crear Ventana con Transparencia

```dart
import 'package:desktop_multi_window/desktop_multi_window.dart';

// Color-key transparency
final transparencyConfig = WindowTransparencyConfig.colorKey(
  colorKey: 0x01FE01, // RGB(1, 254, 1)
  toolWindow: true,   // No aparece en barra de tareas
  transparent: false, // Recibe clics normalmente
);

final controller = await DesktopMultiWindow.createWindow(
  'my_transparent_window',
  transparencyConfig,
);

// Per-pixel alpha transparency
final alphaConfig = WindowTransparencyConfig.alpha(
  alpha: 200,         // Semi-transparente
  toolWindow: false,  // Aparece en barra de tareas
  transparent: false, // Recibe clics normalmente
);

final controller2 = await DesktopMultiWindow.createWindow(
  'my_alpha_window',
  alphaConfig,
);
```

### Modificar Transparencia Después de Crear la Ventana

```dart
// Cambiar a color-key transparency
await controller.setColorKeyTransparency(
  colorKey: 0xFF00FF, // Magenta
  toolWindow: true,
  transparent: false,
);

// Cambiar a alpha transparency
await controller.setAlphaTransparency(
  alpha: 150,
  toolWindow: false,
  transparent: false,
);

// Configuración personalizada
await controller.setTransparency(
  WindowTransparencyConfig(
    mode: WindowTransparencyMode.colorKey,
    colorKey: 0x000001, // Negro
    toolWindow: true,
    transparent: true,   // Click-through
  ),
);
```

## Casos de Uso

### 1. Overlay de Telemetría para Gaming
```dart
final overlayConfig = WindowTransparencyConfig.colorKey(
  colorKey: 0x01FE01,
  toolWindow: true,    // No interfiere con la barra de tareas
  transparent: true,   // Los clics pasan al juego
);

final overlay = await DesktopMultiWindow.createWindow(
  'gaming_overlay',
  overlayConfig,
);
```

### 2. Ventana de Streaming con Transparencia
```dart
final streamConfig = WindowTransparencyConfig.alpha(
  alpha: 180,          // Semi-transparente
  toolWindow: false,   // Visible en barra de tareas
  transparent: false,  // Permite interacción
);

final streamWindow = await DesktopMultiWindow.createWindow(
  'stream_overlay',
  streamConfig,
);
```

### 3. Notificación Flotante
```dart
final notificationConfig = WindowTransparencyConfig.alpha(
  alpha: 230,
  toolWindow: true,    // No clutters taskbar
  transparent: false,  // Clickeable para cerrar
);
```

## Consideraciones Técnicas

### Colores Recomendados para Color-Key
- `0x01FE01` (RGB(1, 254, 1)) - Verde brillante (por defecto)
- `0xFF00FF` (RGB(255, 0, 255)) - Magenta
- `0x000001` (RGB(0, 0, 1)) - Casi negro

### Rendimiento
- Color-key transparency es más eficiente para formas simples
- Per-pixel alpha es mejor para efectos graduales pero consume más recursos
- Tool windows tienen menor overhead del sistema

### Limitaciones
- Solo disponible en Windows
- Per-pixel alpha requiere que el contenido de Flutter tenga canal alpha
- Click-through windows no pueden recibir eventos de teclado

## Implementación Técnica

### Cambios en el Código Nativo (C++)

1. **Estilos de Ventana Extendidos**:
   - `WS_EX_LAYERED` - Habilita transparencia
   - `WS_EX_TRANSPARENT` - Click-through
   - `WS_EX_TOOLWINDOW` - No aparece en barra de tareas

2. **SetLayeredWindowAttributes**:
   - `LWA_COLORKEY` para color-key transparency
   - `LWA_ALPHA` para per-pixel alpha

3. **Creación de Ventana**:
   - Los estilos se aplican durante `CreateWindowEx`
   - Configuración de transparencia se aplica después de la creación

### Estructura de Archivos Modificados

- **Dart API**: `lib/src/window_transparency.dart`
- **Plugin Principal**: `windows/desktop_multi_window_plugin.cpp`
- **Gestor de Ventanas**: `windows/multi_window_manager.h/.cc`
- **Ventana Base**: `windows/base_flutter_window.h/.cc`
- **Ventana Flutter**: `windows/flutter_window.h/.cc`

## Ejemplo Completo

Ver `example/lib/transparency_demo.dart` para una implementación completa que demuestra todos los modos de transparencia y sus casos de uso.

## Compatibilidad

- **Windows 10/11**: Soporte completo
- **Windows 8.1**: Soporte básico
- **Windows 7**: Color-key funciona, alpha puede tener limitaciones
- **Otras plataformas**: Las llamadas fallan graciosamente con `MissingPluginException`