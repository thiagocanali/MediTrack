import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditMedicationScreen extends StatefulWidget {
  const EditMedicationScreen({
    super.key,
    required this.userId,
    required this.documentId,
    required this.currentName,
  });
  final String userId;
  final String documentId;
  final String currentName;

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  late final TextEditingController _name;
  bool _busy = false;

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('users')
          .doc(widget.userId).collection('medications').doc(widget.documentId);

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      await _doc.update({'name': name, 'updatedAt': FieldValue.serverTimestamp()});
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir medicamento?'),
        content: const Text('Esta ação remove o cadastro.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _doc.delete();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar medicamento')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _name, maxLength: 160,
          decoration: const InputDecoration(labelText: 'Nome')),
        FilledButton(onPressed: _busy ? null : _save, child: const Text('Salvar')),
        TextButton(onPressed: _busy ? null : _delete,
          child: const Text('Excluir medicamento')),
      ]),
    );
  }
}
