import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../utils/prefs.dart';
import 'entrega_screen.dart';

class PaquetesScreen extends StatefulWidget {
  const PaquetesScreen({super.key});

  @override
  State<PaquetesScreen> createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  List paquetes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    // Obtener ID del usuario guardado
    int? usuarioId = await Prefs.getUserId();

    if (usuarioId == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    try {
      paquetes = await ApiService.obtenerPaquetes(usuarioId);
    } catch (e) {
      print("Error cargando paquetes: $e");
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paquetes Asignados"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Prefs.clear();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())

          : paquetes.isEmpty
              ? const Center(
                  child: Text(
                    "No hay paquetes asignados",
                    style: TextStyle(fontSize: 18),
                  ),
                )

              : ListView.builder(
                  itemCount: paquetes.length,
                  itemBuilder: (context, index) {
                    final p = paquetes[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Paquete #${p['id']}"),
                        subtitle: Text("Dirección: ${p['direccion_destino']}"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EntregaScreen(paquete: p),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}