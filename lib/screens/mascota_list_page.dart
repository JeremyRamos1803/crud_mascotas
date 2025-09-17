import 'dart:io';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/mascota.dart';
import 'mascota_page.dart';
import 'mascota_detail_page.dart';

class MascotaListPage extends StatefulWidget {
  const MascotaListPage({super.key});

  @override
  State<MascotaListPage> createState() => _MascotaListPageState();
}

class _MascotaListPageState extends State<MascotaListPage> {
  List<Mascota> _mascotas = [];
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _loadMascotas();
  }

  Future<void> _loadMascotas() async {
    final mascotas = await DatabaseHelper.instance.getMascotas(filtro: _filtro);
    setState(() {
      _mascotas = mascotas;
    });
  }

  Future<void> _deleteMascota(int id) async {
    await DatabaseHelper.instance.deleteMascota(id);
    _loadMascotas();
  }

  void _navigateToForm({Mascota? mascota}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MascotaPage(mascota: mascota)),
    );
    if (result == true) _loadMascotas();
  }

  void _navigateToDetail(Mascota mascota) async{
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MascotaDetailPage(mascota: mascota)),
    );
    if (result == true) _loadMascotas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Mascotas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _filtro = value;
                });
                _loadMascotas();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _mascotas.length,
              itemBuilder: (context, index) {
                final mascota = _mascotas[index];
                return ListTile(
                  leading: mascota.imagen != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(mascota.imagen!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover, // ✅ recorta para que quede cuadrado
                          ),
                        )
                      : const Icon(Icons.pets, size: 40),
                  title: Text(mascota.nombre),
                  subtitle: Text('${mascota.especie}, ${mascota.edad} años'),
                  onTap: () => _navigateToDetail(mascota), // ✅ ver detalle
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToForm(mascota: mascota),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteMascota(mascota.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
