// lib/providers/task_provider.dart
// Provides a real-time stream of tasks assigned to the current volunteer.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/services/firebase_service.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  String? _filterStatus; // null = All
  bool _loading = true;
  String? _error;

  List<TaskModel> get tasks => _filteredTasks;
  bool get loading => _loading;
  String? get error => _error;
  String? get filterStatus => _filterStatus;

  List<TaskModel> get _filteredTasks {
    if (_filterStatus == null) return _tasks;
    return _tasks.where((t) => t.status == _filterStatus).toList();
  }

  Stream<QuerySnapshot>? _tasksStream;

  /// Starts listening to tasks for the given volunteer UID.
  void startListening(String volunteerId) {
    _loading = true;
    notifyListeners();

    _tasksStream = FirebaseService.streamTasks(volunteerId);
    _tasksStream!.listen(
      (snapshot) {
        _tasks = snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList();
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[TaskProvider] stream error: $e');
        _error = 'Failed to load tasks.';
        _loading = false;
        notifyListeners();
      },
    );
  }

  /// Sets the filter status (null = show all).
  void setFilter(String? status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Updates a task status in Firestore and locally.
  Future<bool> updateStatus(String taskId, String newStatus) async {
    final ok = await FirebaseService.updateTaskStatus(taskId, newStatus);
    if (ok) {
      _tasks = _tasks
          .map((t) => t.id == taskId ? t.copyWith(status: newStatus) : t)
          .toList();
      notifyListeners();
    }
    return ok;
  }
}
