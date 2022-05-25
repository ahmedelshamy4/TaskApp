import 'package:firebase_database/firebase_database.dart';

class TaskModel {
  String nodeId;
  String taskName;
  int dt;

  TaskModel({
    required this.nodeId,
    required this.taskName,
    required this.dt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      nodeId: map['nodeId'],
      taskName: map['taskName'],
      dt: map['dt'],
    );
  }
}
