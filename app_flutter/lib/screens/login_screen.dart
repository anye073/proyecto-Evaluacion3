import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../utils/prefs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usuarioCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void login() async {
    try {
      var data = await ApiService.login(
        usuarioCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (data["usuario"] == null) {
        throw Exception("Usuario no encontrado");
      }

      // Guardar solo el ID del usuario
      await Prefs.saveUserId(data["usuario"]["id"]);

      Navigator.pushReplacementNamed(context, '/paquetes');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usuarioCtrl,
              decoration: const InputDecoration(labelText: "Usuario"),
            ),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contraseña"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text("Ingresar"),
            )
          ],
        ),
      ),
    );
  }
}
