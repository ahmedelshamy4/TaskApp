import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '../widgets/color.dart';

import '../model/task_model.dart';
import '../widgets/toast.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel taskModel;

  const EditTaskScreen({
    Key? key,
    required this.taskModel,
  }) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  var taskNameController = TextEditingController();
  @override
  void initState() {
    taskNameController.text = widget.taskModel.taskName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks Edit '),
        elevation: 0.0,
        actions: [
          TextButton.icon(
            icon: const Icon(
              Icons.share,
              size: 18.0,
              color: white,
            ),
            onPressed: () {
              Share.share(('https://taskappone.page.link/mVFa'));
            },
            label: const Text(
              'Copy Link',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: taskNameController,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Task Name Update',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                var taskName = taskNameController.text;
                if (taskName.isEmpty) {
                  showToast(
                      message: 'Please provide task name',
                      state: ToastStates.warning);
                  return;
                }
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // update take  in realtime database
                  var taskRef = FirebaseDatabase.instance
                      .reference()
                      .child('tasks')
                      .child(user.uid);

                  await taskRef.child(widget.taskModel.nodeId).update(
                    {
                      'taskName': taskName,
                    },
                  );
                  showToast(
                      message: 'Task Updated', state: ToastStates.success);
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                margin: const EdgeInsets.symmetric(horizontal: 50.0),
                decoration: BoxDecoration(
                    color: mainColor,
                    border: Border.all(
                        color: mainColor, // Set border color
                        width: 3.0), // Set border width
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10.0)), // Set rounded corner radius
                    boxShadow: const [
                      BoxShadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(1, 3))
                    ] // Make rounded corner of border
                    ),
                child: const Text(
                  'UPDATE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
