import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({Key? key}) : super(key: key);

  @override
  _MedicationListScreenState createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  final TextEditingController _medicationController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addMedication() async {
    final medication = _medicationController.text;
    if (medication.isNotEmpty) {
      try {
        await _firestore.collection('medications').add({
          'name': medication,
          'timestamp': Timestamp.now(),
        });
        _medicationController.clear();
      } catch (e) {
        print('Error adding medication: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication List'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _medicationController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addMedication,
            child: const Text('Add Medication'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('medications').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
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
