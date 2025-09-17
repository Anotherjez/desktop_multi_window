import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  if (args.isNotEmpty && args.first == 'multi_window') {
    final windowId = int.parse(args[1]);
    runApp(SimpleTransparentWindow(windowId: windowId));
  } else {
    runApp(const MainApp());
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Transparency Test',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _createNormalWindow() async {
    try {
      // Crear ventana normal (sin transparencia)
      final controller = await DesktopMultiWindow.createWindow('normal_window');
      await controller.setFrame(const Rect.fromLTWH(100, 100, 400, 300));
      await controller.setTitle('Ventana Normal');
      await controller.show();
      print('Ventana normal creada exitosamente');
    } catch (e) {
      print('Error creando ventana normal: $e');
    }
  }

  Future<void> _createSimpleTransparentWindow() async {
    try {
      // Crear ventana con transparencia simple
      final config = WindowTransparencyConfig.simple(
        colorKey: true,
        toolWindow: true,
        clickThrough: false,
      );

      final controller = await DesktopMultiWindow.createWindow(
        'transparent_window',
        config,
      );

      await controller.setFrame(const Rect.fromLTWH(200, 150, 400, 300));
      await controller.setTitle('Ventana Transparente');
      await controller.show();
      print('Ventana transparente creada exitosamente');
    } catch (e) {
      print('Error creando ventana transparente: $e');
      // Fallback: crear ventana normal
      _createNormalWindow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Transparencia Simple'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test de Transparencia - Versión Segura',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _createNormalWindow,
              child: const Text('Crear Ventana Normal'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createSimpleTransparentWindow,
              child: const Text('Crear Ventana Transparente'),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Este ejemplo usa manejo de errores robusto.\n'
                'Si la transparencia falla, crea una ventana normal como fallback.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleTransparentWindow extends StatelessWidget {
  final int windowId;

  const SimpleTransparentWindow({Key? key, required this.windowId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ventana Transparente',
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.7),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF01FE01), // Color transparente
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Esta área debería ser transparente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ventana ID: $windowId',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    WindowController.fromWindowId(windowId).close();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
