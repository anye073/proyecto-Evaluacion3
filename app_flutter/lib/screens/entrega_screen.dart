import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_service.dart';

class EntregaScreen extends StatefulWidget {
  final Map paquete;
  const EntregaScreen({Key? key, required this.paquete}) : super(key: key);

  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  double? lat;
  double? lng;

  XFile? imagen;
  Uint8List? imagenBytes;

  @override
  void initState() {
    super.initState();
    obtenerUbicacion();
  }

  // -------- OBTENER GPS --------
  Future<void> obtenerUbicacion() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }

    if (permiso == LocationPermission.deniedForever) {
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      lat = pos.latitude;
      lng = pos.longitude;
    });
  }

  // -------- TOMAR FOTO (ANDROID + WEB) --------
  Future<void> tomarFoto() async {
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto != null) {
      final bytes = await foto.readAsBytes();

      setState(() {
        imagen = foto;
        imagenBytes = bytes;
      });
    }
  }

  // -------- ENVIAR ENTREGA --------
  Future<void> enviarEntrega() async {
    if (imagenBytes == null || lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Falta foto o ubicación")),
      );
      return;
    }

    bool ok = await ApiService.enviarEntrega(
      paqueteId: widget.paquete["id"],
      lat: lat!,
      lng: lng!,
      fileName: imagen!.name,
      fileBytes: imagenBytes!,
    );

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrega registrada correctamente")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar entrega")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Entrega - ${widget.paquete['codigo']}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ----------------------------------------------------
            //                     MAPA
            // ----------------------------------------------------
            if (lat != null && lng != null)
              SizedBox(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(lat!, lng!),
                    zoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(lat!, lng!),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            if (lat == null)
              const Text(
                "Obteniendo ubicación...",
                style: TextStyle(fontSize: 16),
              ),

            if (lat != null)
              Text(
                "Latitud: $lat\nLongitud: $lng",
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 20),

            // ----------------------------------------------------
            //                     FOTO
            // ----------------------------------------------------
            ElevatedButton(
              onPressed: tomarFoto,
              child: const Text("Tomar Foto"),
            ),

            if (imagenBytes != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Image.memory(
                  imagenBytes!,
                  height: 200,
                ),
              ),

            const SizedBox(height: 20),

            // ----------------------------------------------------
            //                 BOTÓN ENVIAR ENTREGA
            // ----------------------------------------------------
            ElevatedButton(
              onPressed: enviarEntrega,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 192, 147, 178),
              ),
              child: const Text("Registrar Entrega"),
            ),
          ],
        ),
      ),
    );
  }
}