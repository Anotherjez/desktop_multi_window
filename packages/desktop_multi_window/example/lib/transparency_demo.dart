import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  if (args.isNotEmpty && args.first == 'multi_window') {
    // Este es el punto de entrada para ventanas secundarias
    final windowId = int.parse(args[1]);
    runApp(TransparencyDemoSubWindow(windowId: windowId));
  } else {
    // Este es el punto de entrada para la ventana principal
    runApp(const TransparencyDemoMainWindow());
  }
}

/// Ventana principal que puede crear ventanas transparentes
class TransparencyDemoMainWindow extends StatelessWidget {
  const TransparencyDemoMainWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desktop Multi Window - Transparency Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainWindowPage(),
    );
  }
}

class MainWindowPage extends StatelessWidget {
  const MainWindowPage({Key? key}) : super(key: key);

  Future<void> _createColorKeyWindow() async {
    // Crear ventana con transparencia color-key
    final transparencyConfig = WindowTransparencyConfig.colorKey(
      colorKey: 0x01FE01, // RGB(1, 254, 1) - verde brillante
      toolWindow: true, // No aparece en la barra de tareas
      transparent: false, // Recibe clics normalmente
    );

    final controller = await DesktopMultiWindow.createWindow(
      'color_key_window',
      transparencyConfig,
    );

    await controller.setFrame(const Rect.fromLTWH(100, 100, 400, 300));
    await controller.setTitle('Ventana Color-Key Transparente');
    await controller.show();
  }

  Future<void> _createAlphaWindow() async {
    // Crear ventana con transparencia per-pixel alpha
    final transparencyConfig = WindowTransparencyConfig.alpha(
      alpha: 200, // Semi-transparente
      toolWindow: false, // Aparece en la barra de tareas
      transparent: false, // Recibe clics normalmente
    );

    final controller = await DesktopMultiWindow.createWindow(
      'alpha_window',
      transparencyConfig,
    );

    await controller.setFrame(const Rect.fromLTWH(200, 150, 400, 300));
    await controller.setTitle('Ventana Alpha Transparente');
    await controller.show();
  }

  Future<void> _createOverlayWindow() async {
    // Crear ventana overlay click-through
    final transparencyConfig = WindowTransparencyConfig.colorKey(
      colorKey: 0x01FE01, // RGB(1, 254, 1)
      toolWindow: true, // No aparece en la barra de tareas
      transparent: true, // Click-through
    );

    final controller = await DesktopMultiWindow.createWindow(
      'overlay_window',
      transparencyConfig,
    );

    await controller.setFrame(const Rect.fromLTWH(300, 200, 400, 300));
    await controller.setTitle('Overlay Click-Through');
    await controller.show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transparency Demo - Ventana Principal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Demo de Transparencia en Windows',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _createColorKeyWindow,
              child: const Text('Crear Ventana Color-Key Transparente'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createAlphaWindow,
              child: const Text('Crear Ventana Alpha Transparente'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createOverlayWindow,
              child: const Text('Crear Overlay Click-Through'),
            ),
            const SizedBox(height: 40),
            const Text(
              'Características implementadas:\n'
              '• Color-key transparency (RGB específico se vuelve transparente)\n'
              '• Per-pixel alpha transparency\n'
              '• Tool window (no aparece en barra de tareas)\n'
              '• Click-through windows (no reciben eventos de mouse)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ventana secundaria que muestra contenido transparente
class TransparencyDemoSubWindow extends StatefulWidget {
  final int windowId;

  const TransparencyDemoSubWindow({Key? key, required this.windowId})
      : super(key: key);

  @override
  State<TransparencyDemoSubWindow> createState() =>
      _TransparencyDemoSubWindowState();
}

class _TransparencyDemoSubWindowState extends State<TransparencyDemoSubWindow> {
  WindowController? controller;
  String windowType = 'unknown';

  @override
  void initState() {
    super.initState();
    controller = WindowController.fromWindowId(widget.windowId);

    // Determinar el tipo de ventana basado en argumentos
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      // Manejar comunicación entre ventanas si es necesario
      return null;
    });
  }

  Future<void> _changeTransparency() async {
    if (controller == null) return;

    if (windowType == 'color_key_window') {
      // Cambiar a modo alpha
      await controller!.setAlphaTransparency(alpha: 150);
    } else if (windowType == 'alpha_window') {
      // Cambiar a color-key
      await controller!.setColorKeyTransparency(colorKey: 0xFF00FF); // Magenta
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ventana Transparente',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        backgroundColor: windowType == 'overlay_window'
            ? const Color(0x0001FE01) // Color transparente para overlay
            : null,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: windowType == 'color_key_window'
                  ? [
                      Colors.red.withOpacity(0.8),
                      Colors.blue.withOpacity(0.8),
                      const Color(0xFF01FE01), // Color transparente
                    ]
                  : [
                      Colors.purple.withOpacity(0.6),
                      Colors.orange.withOpacity(0.6),
                    ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ventana ${widget.windowId}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (windowType != 'overlay_window') ...[
                  ElevatedButton(
                    onPressed: _changeTransparency,
                    child: const Text('Cambiar Transparencia'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller?.close(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cerrar Ventana'),
                  ),
                ],
                if (windowType == 'overlay_window') ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Overlay Click-Through\nLos clics pasan a través de esta ventana',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
