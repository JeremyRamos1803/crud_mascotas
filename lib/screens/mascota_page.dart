import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/database_helper.dart';
import '../models/mascota.dart';

class MascotaPage extends StatefulWidget {
  final Mascota? mascota;
  const MascotaPage({super.key, this.mascota});

  @override
  State<MascotaPage> createState() => _MascotaPageState();
}

class _MascotaPageState extends State<MascotaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _especieController = TextEditingController();
  final _edadController = TextEditingController();
  final _duenoController = TextEditingController();
  String? _imagenPath;

  @override
  void initState() {
    super.initState();
    if (widget.mascota != null) {
      _nombreController.text = widget.mascota!.nombre;
      _especieController.text = widget.mascota!.especie;
      _edadController.text = widget.mascota!.edad.toString();
      _duenoController.text = widget.mascota!.dueno;
      _imagenPath = widget.mascota!.imagen;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagenPath = image.path;
      });
    }
  }

  Future<void> _saveMascota() async {
    if (_formKey.currentState!.validate()) {
      final mascota = Mascota(
        id: widget.mascota?.id,
        nombre: _nombreController.text,
        especie: _especieController.text,
        edad: int.parse(_edadController.text),
        dueno: _duenoController.text,
        imagen: _imagenPath,
      );

      if (widget.mascota == null) {
        await DatabaseHelper.instance.insertMascota(mascota);
      } else {
        await DatabaseHelper.instance.updateMascota(mascota);
      }

      if (mounted) Navigator.pop(context, true);
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
                validator: (value) => value == null || value.isEmpty ? 'Ingrese una especie' : null,
              ),
              TextFormField(
                controller: _edadController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Ingrese una edad' : null,
              ),
              TextFormField(
                controller: _duenoController,
                decoration: const InputDecoration(labelText: 'Dueño'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el nombre del dueño' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Seleccionar Imagen"),
              ),
              if (_imagenPath != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(File(_imagenPath!), height: 150),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMascota,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
