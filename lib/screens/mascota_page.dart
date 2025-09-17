import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/mascota.dart';
import '../db/database_helper.dart';

class MascotaPage extends StatefulWidget {
  final Mascota? mascota;

  const MascotaPage({super.key, this.mascota});

  @override
  State<MascotaPage> createState() => _MascotaPageState();
}

class _MascotaPageState extends State<MascotaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _especieController;
  late TextEditingController _edadController;
  late TextEditingController _duenoController;
  String? _imagenPath;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.mascota?.nombre ?? '');
    _especieController = TextEditingController(text: widget.mascota?.especie ?? '');
    _edadController = TextEditingController(text: widget.mascota?.edad.toString() ?? '');
    _duenoController = TextEditingController(text: widget.mascota?.dueno ?? '');
    _imagenPath = widget.mascota?.imagen;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _especieController.dispose();
    _edadController.dispose();
    _duenoController.dispose();
    super.dispose();
  }

  /// Capitaliza la primera letra
  String _capitalizar(String valor) {
    if (valor.isEmpty) return valor;
    return valor[0].toUpperCase() + valor.substring(1);
  }

  /// Seleccionar imagen de la galería
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagenPath = image.path;
      });
    }
  }

  /// Guardar mascota
  Future<void> _guardarMascota() async {
    if (_formKey.currentState!.validate()) {
      final mascota = Mascota(
        id: widget.mascota?.id,
        nombre: _capitalizar(_nombreController.text.trim()),
        especie: _capitalizar(_especieController.text.trim()),
        edad: int.parse(_edadController.text.trim()),
        dueno: _capitalizar(_duenoController.text.trim()),
        imagen: _imagenPath,
      );

      if (widget.mascota == null) {
        await DatabaseHelper.instance.insertMascota(mascota);
      } else {
        await DatabaseHelper.instance.updateMascota(mascota);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mascota == null ? 'Agregar Mascota' : 'Editar Mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              TextFormField(
                controller: _especieController,
                decoration: const InputDecoration(labelText: 'Especie'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese la especie' : null,
              ),
              TextFormField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Edad'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese la edad' : null,
              ),
              TextFormField(
                controller: _duenoController,
                decoration: const InputDecoration(labelText: 'Dueño'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el dueño' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Seleccionar Imagen"),
              ),
              if (_imagenPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(File(_imagenPath!), height: 100),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarMascota,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
