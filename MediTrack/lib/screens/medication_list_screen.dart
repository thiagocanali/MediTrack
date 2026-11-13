import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit_medication_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key, required this.userId});
  final String userId;

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  final _name = TextEditingController();
  bool _saving = false;

  CollectionReference<Map<String, dynamic>> get _medications =>
      FirebaseFirestore.instance.collection('users')
          .doc(widget.userId).collection('medications');

  Future<void> _addMedication() async {
    final name = _name.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await _medications.add({
        'name': name,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _name.clear();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o medicamento.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus medicamentos'),
        actions: [IconButton(
          tooltip: 'Sair', icon: const Icon(Icons.logout),
          onPressed: () => FirebaseAuth.instance.signOut(),
        )],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: TextField(
                controller: _name,
                maxLength: 160,
                decoration: const InputDecoration(labelText: 'Nome do medicamento'),
              )),
              IconButton(
                tooltip: 'Adicionar',
                onPressed: _saving ? null : _addMedication,
                icon: const Icon(Icons.add_circle),
              ),
            ]),
          ),
          Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _medications.orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar medicamentos.'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('Nenhum medicamento cadastrado.'));
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  return ListTile(
                    title: Text(data['name'] as String? ?? 'Sem nome'),
                    trailing: IconButton(
                      tooltip: 'Editar', icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => EditMedicationScreen(
                          userId: widget.userId,
                          documentId: doc.id,
                          currentName: data['name'] as String? ?? '',
                        ),
                      )),
                    ),
                  );
                },
              );
            },
          )),
        ],
      ),
    );
  }
}
