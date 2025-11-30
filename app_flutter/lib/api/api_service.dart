import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Para emulador de Android SIEMPRE usa 10.0.2.2
  static const String baseUrl = "http://10.0.2.2:8000";

  // -------- LOGIN --------
  static Future<Map<String, dynamic>> login(String user, String pass) async {
    try {
      print("🔄 Intentando conectar a: $baseUrl/login");
      
      final res = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: { "Content-Type": "application/json" },
        body: jsonEncode({
          "username": user,
          "password": pass,
        }),
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Timeout: El servidor no responde");
        },
      );

      print("✅ Respuesta: ${res.statusCode}");

      if (res.statusCode != 200) {
        throw Exception("Error en login: ${res.body}");
      }
      
      return jsonDecode(utf8.decode(res.bodyBytes));
    } on SocketException catch (e) {
      print("❌ Error de conexión: $e");
      throw Exception("No se puede conectar al servidor");
    } catch (e) {
      print("❌ Error: $e");
      rethrow;
    }
  }

  // -------- OBTENER PAQUETES --------
  static Future<List<dynamic>> obtenerPaquetes(int usuarioId) async {
    try {
      print("🔄 Obteniendo paquetes para usuario: $usuarioId");
      
      final res = await http.get(
        Uri.parse("$baseUrl/paquetes/$usuarioId"),
      ).timeout(Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception("Error al obtener paquetes: ${res.body}");
      }
      
      return jsonDecode(utf8.decode(res.bodyBytes));
    } on SocketException {
      throw Exception("No se puede conectar al servidor");
    } catch (e) {
      print("❌ Error: $e");
      rethrow;
    }
  }

  // -------- ENVIAR ENTREGA CON FOTO Y GPS --------
  static Future<bool> enviarEntrega({
    required int paqueteId,
    required double lat,
    required double lng,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      print("🔄 Enviando entrega del paquete: $paqueteId");
      
      final uri = Uri.parse("$baseUrl/entregar-paquete");
      final request = http.MultipartRequest("POST", uri);
      
      request.fields["paquete_id"] = paqueteId.toString();
      request.fields["latitud"] = lat.toString();
      request.fields["longitud"] = lng.toString();
      
      request.files.add(
        http.MultipartFile.fromBytes(
          "foto",
          Uint8List.fromList(fileBytes),
          filename: fileName,
        ),
      );

      final response = await request.send().timeout(Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        print("✅ Entrega enviada exitosamente");
        return true;
      } else {
        print("❌ Error: ${response.statusCode}");
        return false;
      }
    } on SocketException {
      throw Exception("No se puede conectar al servidor");
    } catch (e) {
      print("❌ Error: $e");
      rethrow;
    }
  }
 }
// Verifica AndroidManifest.xml
// En android/app/src/main/AndroidManifest.xml:
// xml<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
//     <!-- Permisos necesarios -->
//     <uses-permission android:name="android.permission.INTERNET"/>
//     <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//     <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
//     <uses-permission android:name="android.permission.CAMERA"/>

//     <application
//         android:label="tu_app"
//         android:usesCleartextTraffic="true"
//         android:icon="@mipmap/ic_launcher">
        
//         <!-- resto de tu configuración -->
        
//     </application>
// </manifest>
// ```

// ### Pasos finales:

// 1. **Guarda los cambios** en `api_service.dart`
// 2. **Hot restart** en Flutter (no hot reload):
//    - Presiona `R` en la terminal donde corre Flutter
//    - O detén la app y vuelve a ejecutar: `flutter run`
// 3. **Prueba el login**

// ### Prueba desde el navegador del emulador

// Para verificar que la conexión funciona, abre el navegador del emulador y visita:
// ```
// http://10.0.2.2:8000/docs