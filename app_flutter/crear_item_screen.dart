// import 'package:flutter/material.dart';
import '../api/api_service.dart';

// class CrearItemScreen extends StatefulWidget {
//   const CrearItemScreen({super.key});

//   @override
//   State<CrearItemScreen> createState() => _CrearItemScreenState();
// }

// class _CrearItemScreenState extends State<CrearItemScreen> {
//   final tituloCtrl = TextEditingController();
//   final descCtrl = TextEditingController();
//   String msg = "";

//   void crear() async {
//     final ok = await ApiService.createItem(
//       tituloCtrl.text.trim(),
//       descCtrl.text.trim(),
//     );

//     if (ok) {
//       setState(() => msg = "Item creado correctamente");
//       tituloCtrl.clear();
//       descCtrl.clear();
//     } else {
//       setState(() => msg = "Error al crear item");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Crear Item")),
//       body: Padding(
//         padding: const EdgeInsets.all(25),
//         child: Column(
//           children: [
//             TextField(
//               controller: tituloCtrl,
//               decoration: const InputDecoration(labelText: "Título"),
//             ),
//             TextField(
//               controller: descCtrl,
//               decoration: const InputDecoration(labelText: "Descripción"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: crear,
//               child: const Text("Guardar"),
//             ),
//             const SizedBox(height: 15),
//             Text(msg),
//           ],
//         ),
//       ),
//     );
//   }
// }
