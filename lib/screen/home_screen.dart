import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_task_screen.dart';
import '../widgets/color.dart';
import '../model/task_model.dart';
import '../widgets/toast.dart';
import 'add_task_screen.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  DatabaseReference? taskRef;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      taskRef =
          FirebaseDatabase.instance.reference().child('tasks').child(user!.uid);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tasks List'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return const LoginScreen();
                }));
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: mainColor,
          child: const Icon(
            Icons.add,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const AddTaskScreen();
            }));
          },
        ),
        body: StreamBuilder(
          stream: taskRef != null ? taskRef!.onValue : null,
          builder: (context, snap) {
            if (snap.hasData && !snap.hasError) {
              var event = snap.data as Event;
              var snshot = event.snapshot.value;

              if (snshot == null) {
                return const Center(child: Text('No tasks yet'));
              }
              var tasks = <TaskModel>[];
              Map<String, dynamic> map = Map<String, dynamic>.from(snshot);

              for (var taskMap in map.values) {
                tasks
                    .add(TaskModel.fromMap(Map<String, dynamic>.from(taskMap)));
              }

              return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    TaskModel taskModel = tasks[index];

                    return Container(
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                        left: 10.0,
                        right: 10.0,
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black,
                            offset: Offset(1, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  taskModel.taskName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(getHumanReadableDate(taskModel.dt)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  if (taskRef != null) {
                                    // show alertdialog

                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (ctx) {
                                          return AlertDialog(
                                            title: const Text('Confirmation'),
                                            content: const Text(
                                                'Are you sure to delete ?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                  },
                                                  child: const Text('No')),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    await taskRef!
                                                        .child(taskModel.nodeId)
                                                        .remove();
                                                  } catch (e) {
                                                    print(e.toString());
                                                    showToast(
                                                        message: 'failed',
                                                        state:
                                                            ToastStates.error);
                                                  }
                                                  showToast(
                                                      message: 'Tasks Deleted',
                                                      state:
                                                          ToastStates.success);
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: const Text(
                                                  'Yes',
                                                  style: TextStyle(
                                                      color: mainColor),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  }
                                },
                                icon: const Icon(Icons.delete),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return EditTaskScreen(taskModel: taskModel);
                                  }));
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }

  String getHumanReadableDate(int dt) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt);
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}
