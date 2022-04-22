import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:todo_uygulamasi/data/local_storage.dart';
import 'package:todo_uygulamasi/helper/translation_helper.dart';
import 'package:todo_uygulamasi/main.dart';
import 'package:todo_uygulamasi/models/task_model.dart';
import 'package:todo_uygulamasi/widgets/custom_search_delegate.dart';
import 'package:todo_uygulamasi/widgets/task_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> _allTasks;
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = locator<LocalStorage>();
    _allTasks = <Task>[];
    _getAllTaskFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _showAddTaskBottomSheet();
          },
          child: const Text(
            "title",
            style: TextStyle(color: Colors.black),
          ).tr(),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              _showSearchPage();
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
              onPressed: () {
                _showAddTaskBottomSheet();
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: _allTasks.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                var _oAnkiListeElemani = _allTasks[index];
                // ignore: todo
                // TODO: dismissible sayesinde kaydırarak silme işlemi
                return Dismissible(
                  background: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Icon(
                              Icons.delete,
                              color: Colors.black,
                            ),
                            const Text('remove_task').tr(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Icon(
                              Icons.archive,
                              color: Colors.black,
                            ),
                            const Text('archive_text').tr(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  key: Key(_oAnkiListeElemani.id),
                  onDismissed: (direction) {
                    _allTasks.removeAt(index);
                    _localStorage.deleteTask(task: _oAnkiListeElemani);
                    setState(() {});
                  },
                  child: TaskItem(task: _oAnkiListeElemani),
                );
              },
              itemCount: _allTasks.length,
            )
          : Center(
              child: const Text(
              "empty_task_list",
              style: TextStyle(fontSize: 24),
            ).tr()),
    );
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              title: TextField(
                autofocus: true,
                textInputAction: TextInputAction.done,
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  hintText: "add_task".tr(),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                  if (value.length > 3) {
                    DatePicker.showDateTimePicker(context,
                        locale: TranslationHelper.getDeviceLanguage(context),
                        onConfirm: (time) async {
                      var yeniEklenecekGorev =
                          Task.create(name: value, createdAt: time);
                      _allTasks.insert(0, yeniEklenecekGorev);

                      await _localStorage.addTask(task: yeniEklenecekGorev);

                      setState(() {});
                    });
                  }
                },
              ),
            ),
          );
        });
  }

  void _getAllTaskFromDB() async {
    _allTasks = await _localStorage.getAllTask();
    setState(() {});
  }

  void _showSearchPage() async {
    await showSearch(
        context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
    _getAllTaskFromDB();
  }
}
