// lib/screens/medication_list_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_medication_screen.dart'; // Importar a nova tela

class MedicationListScreen extends StatefulWidget {
  @override
  _MedicationListScreenState createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  final TextEditingController _medicationController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addMedication() async {
    final medication = _medicationController.text;
    if (medication.isNotEmpty) {
      await _firestore.collection('medications').add({
        'name': medication,
        'timestamp': Timestamp.now(),
      });
      _medicationController.clear();
    }
  }

  void _editMedication(String documentId, String currentName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicationScreen(
          documentId: documentId,
          currentName: currentName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication List'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _medicationController,
              decoration: InputDecoration(
                labelText: 'Medication Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addMedication,
            child: Text('Add Medication'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('medications').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final medications = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];
                    return ListTile(
                      title: Text(medication['name']),
                      subtitle:
                          Text(medication['timestamp'].toDate().toString()),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editMedication(
                            medication.id,
                            medication['name'],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
