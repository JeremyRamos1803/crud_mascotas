import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/mascota.dart';

class MascotaPage extends StatefulWidget {
  const MascotaPage({super.key});

  @override
  State<MascotaPage> createState() => _MascotaPageState();
}

class _MascotaPageState extends State<MascotaPage> {
  late Future<List<Mascota>> mascotas;
  String filtro = '';

  @override
  void initState() {
    super.initState();
    refreshMascotas();
  }

  void refreshMascotas() {
    setState(() {
      mascotas = DatabaseHelper.instance.getMascotas();
    });
  }

  void showForm({Mascota? mascota}) {
    final nombreCtrl = TextEditingController(text: mascota?.nombre ?? '');
    final especieCtrl = TextEditingController(text: mascota?.especie ?? '');
    final edadCtrl = TextEditingController(text: mascota?.edad.toString() ?? '');
    final duenoCtrl = TextEditingController(text: mascota?.dueno ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(mascota == null ? "Nueva Mascota" : "Editar Mascota"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: especieCtrl, decoration: const InputDecoration(labelText: "Especie")),
              TextField(controller: edadCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Edad")),
              TextField(controller: duenoCtrl, decoration: const InputDecoration(labelText: "Dueño")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.isEmpty || especieCtrl.text.isEmpty || edadCtrl.text.isEmpty || duenoCtrl.text.isEmpty) return;

              final mascotaNueva = Mascota(
                id: mascota?.id,
                nombre: nombreCtrl.text,
                especie: especieCtrl.text,
                edad: int.tryParse(edadCtrl.text) ?? 0,
                dueno: duenoCtrl.text,
              );

              if (mascota == null) {
                await DatabaseHelper.instance.insertMascota(mascotaNueva);
              } else {
                await DatabaseHelper.instance.updateMascota(mascotaNueva);
              }

              if (!mounted) return;
              refreshMascotas();
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  List<Mascota> filtrar(List<Mascota> lista) {
    if (filtro.isEmpty) return lista;
    return lista.where((m) => m.nombre.toLowerCase().contains(filtro.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mascotas Registradas"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Buscar por nombre",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  filtro = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Mascota>>(
              future: mascotas,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final listaFiltrada = filtrar(snapshot.data!);
                if (listaFiltrada.isEmpty) return const Center(child: Text("No hay mascotas"));

                return ListView(
                  children: listaFiltrada.map((m) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text("${m.nombre} (${m.especie})"),
                        subtitle: Text("Edad: ${m.edad} años - Dueño: ${m.dueno}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => showForm(mascota: m)),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await DatabaseHelper.instance.deleteMascota(m.id!);
                                if (!mounted) return;
                                refreshMascotas();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
