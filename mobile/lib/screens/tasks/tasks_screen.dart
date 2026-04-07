import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assignments', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<QuerySnapshot>(
        // In a real app we'd filter where assignedVolunteerId == currentUser
        stream: FirebaseFirestore.instance.collection('tasks').limit(10).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
             return const Center(child: Text('No active assignments.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
               final data = docs[i].data() as Map<String, dynamic>;
               final title = data['title'] ?? 'Task';
               final desc = data['recommendedAction'] ?? '';
               return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                               child: Text('Urgency: ${data['urgencyScore']}', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 12))
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(desc, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                             TextButton(
                               onPressed: (){}, 
                               child: const Text('View on Map')
                             ),
                             ElevatedButton(
                               onPressed: (){
                                  FirebaseFirestore.instance.collection('tasks').doc(docs[i].id).update({'status': 'completed'});
                               },
                               child: const Text('Mark Complete')
                             )
                          ],
                        )
                      ],
                    ),
                  ),
               );
            },
          );
        },
      ),
    );
  }
}
