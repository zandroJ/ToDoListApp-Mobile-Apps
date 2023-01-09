import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//DATABASE
class ToDoDataBase {
  List to_do_list = [];
  List deleted_tasks = [];

  // reference our box
  final box = Hive.box('mybox');
  // run this method if this is the 1st time ever opening this app
  void first_time_open_app() {
    to_do_list.add(["App Development Assessment", true]);
    to_do_list.add(["By Alezandro Intal", true]);
    deleted_tasks.add(["Task 1", false]);
    deleted_tasks.add(["Task 2", false]);

    // remove default tasks from the deleted_tasks list
    deleted_tasks.remove(["Task 1", false]);
    deleted_tasks.remove(["Task 2", false]);

    update_data(); //calling update data
  }

  // load the data from database
  void load_data() {
    to_do_list = box.get("to_do_list");
  }

  // update the database
  void update_data() {
    box.put("to_do_list", to_do_list);
  }

// delete task method
  void deleteAllTasks(BuildContext context) {
    // Check if the deleted tasks list is empty
    if (deleted_tasks.isEmpty) {
      // Show a dialog with a message that the deleted tasks list is empty
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Empty List"),
            content: Text("There are no tasks to delete."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      // Clear the deleted tasks list and show a message that the tasks were deleted successfully
      deleted_tasks.clear();
      update_data();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Deleted tasks successfully deleted."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}

//BUTTON
class MyButton extends StatelessWidget {
  final String text;
  VoidCallback onPressed;
  MyButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Theme.of(context).primaryColor,
      child: Text(text),
    );
  }
}

//DIALOG BOX
class DialogBox extends StatelessWidget {
  final controller;
  VoidCallback onSave;
  VoidCallback onCancel;
  DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    //box for adding tasks
    return AlertDialog(
      backgroundColor: Colors.blue[300],
      content: Container(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // get user input
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Add a new task",
              ),
            ),

            // buttons -> save + cancel
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // save button
                MyButton(text: "Save", onPressed: onSave),

                const SizedBox(width: 8),

                // cancel button
                MyButton(text: "Cancel", onPressed: onCancel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//TO DO TILE
class ToDoTile extends StatelessWidget {
  final String task_name;
  final bool completed_task;
  Function(bool?)? swap;
  Function(BuildContext)? deleteFunction;

  ToDoTile({
    super.key,
    required this.task_name,
    required this.completed_task,
    required this.swap,
    required this.deleteFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        //BOX LIST TILE
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue, //color for the tasks that is added
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // checkbox
              Checkbox(
                value: completed_task,
                onChanged: swap,
                activeColor: Colors.black,
              ),

              // task name
              Text(
                task_name,
                style: TextStyle(
                  decoration: completed_task
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//MAIN HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // reference the hive box
  final box = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();
  int _currentIndex = 0; // current page index
  bool showDeletedTasks = false;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      showDeletedTasks = index ==
          1; // Update showDeletedTasks when navigating to "deleted tasks" page
    });
  }

  @override
  void initState() {
    // if this is the 1st time ever openin the app, then create default data
    if (box.get("to_do_list") == null) {
      db.first_time_open_app();
    } else {
      // there already exists data
      db.load_data();
    }

    super.initState();
  }

  // text controller
  final _controller = TextEditingController();

  // checkbox was tapped
  void box_check(bool? value, int index) {
    setState(() {
      db.to_do_list[index][1] = !db.to_do_list[index][1];
    });
    db.update_data();
  }

  // save new task
  void save_task() {
    setState(() {
      db.to_do_list.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.update_data();
  }

  // create a new task
  void create_task() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: save_task,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

// delete task
  void delete(int index) {
    setState(() {
      // add the deleted task to the list of deleted tasks
      db.deleted_tasks.add(db.to_do_list[index]);
      // remove the task from the to-do list
      db.to_do_list.removeAt(index);
    });
    db.update_data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38, // body color
      appBar: AppBar(
        title: Text('TO DO'),
        elevation: 0,
      ),

      floatingActionButton: !showDeletedTasks
          ? FloatingActionButton(
              onPressed: create_task,
              child: Icon(Icons.add),
            )
          : FloatingActionButton(
              onPressed: () =>
                  db.deleteAllTasks(context), // Call deleteAllTasks function
              child: Icon(Icons.delete_forever),
            ),

      body: IndexedStack(
        index: _currentIndex, // display current page
        children: [
          ListView.builder(
            itemCount: db.to_do_list.length,
            itemBuilder: (context, index) {
              return ToDoTile(
                task_name: db.to_do_list[index][0],
                completed_task: db.to_do_list[index][1],
                swap: (value) => box_check(value, index),
                deleteFunction: (context) => delete(index),
              );
            },
          ),
          db.deleted_tasks == null || db.deleted_tasks.isEmpty // Add this line
              ? Center(child: Text("No tasks have been deleted."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: db.deleted_tasks.length,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.all(14),
                                child: ListTile(
                                  title: Text(
                                    db.deleted_tasks[index][0],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // use current page index
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'to do list',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'deleted task',
          ),
        ],
      ),
    );
  }
}
