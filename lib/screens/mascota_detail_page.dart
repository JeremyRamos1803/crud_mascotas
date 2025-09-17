import 'dart:io';
import 'package:flutter/material.dart';
import '../models/mascota.dart';
import '../db/database_helper.dart';
import 'mascota_page.dart';

class MascotaDetailPage extends StatelessWidget {
  final Mascota mascota;

  const MascotaDetailPage({super.key, required this.mascota});

  void _editarMascota(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MascotaPage(mascota: mascota)),
    );
    if (result == true) {
      Navigator.pop(context, true); // ✅ Para recargar la lista al volver
    }
  }

  void _eliminarMascota(BuildContext context) async {
    await DatabaseHelper.instance.deleteMascota(mascota.id!);
    Navigator.pop(context, true); // ✅ Volvemos y recargamos lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mascota.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editarMascota(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _eliminarMascota(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (mascota.imagen != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(mascota.imagen!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.pets, size: 120),
            const SizedBox(height: 20),
            Text(
              mascota.nombre,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Especie: ${mascota.especie}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 5),
            Text("Edad: ${mascota.edad} años", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 5),
            Text("Dueño: ${mascota.dueno}", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
