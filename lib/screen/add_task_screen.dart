import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../widgets/color.dart';

import '../widgets/toast.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  var taskNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: taskNameController,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: ' Task Name ',
                hintText: 'Enter Your Task',
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
                    state: ToastStates.warning,
                  );

                  return;
                }
                User? user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  return;
                }
                // add take in realtime database
                var databaseRef = FirebaseDatabase.instance.reference();
                String key =
                    databaseRef.child('tasks').child(user.uid).push().key;
                try {
                  await databaseRef
                      .child(tasksCollection)
                      .child(user.uid)
                      .child(key)
                      .set({
                    'nodeId': key,
                    'taskName': taskName,
                    'dt': DateTime.now().millisecondsSinceEpoch,
                  });
                  showToast(
                    message: 'Task Added',
                    state: ToastStates.success,
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  showToast(
                      message: 'Something went wrong',
                      state: ToastStates.error);
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
                  'SAVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
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
