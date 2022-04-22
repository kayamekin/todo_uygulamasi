import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:todo_uygulamasi/data/local_storage.dart';
import 'package:todo_uygulamasi/main.dart';
import 'package:todo_uygulamasi/models/task_model.dart';
import 'package:todo_uygulamasi/widgets/task_list_item.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<Task> allTasks;

  CustomSearchDelegate({required this.allTasks});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      // IconButton(
      //     onPressed: () {
      //       query.isEmpty ? null : query = '';
      //     },
      //     icon: Icon(Icons.clear)),
      GestureDetector(
        onTap: () {
          query.isEmpty ? null : query = '';
        },
        child: TextButton(
          child: const Text('clear_text').tr(),
          onPressed: () {
            query.isEmpty ? null : query = '';
          },
        ),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return GestureDetector(
      onTap: () {
        close(context, null);
      },
      child: const Icon(
        Icons.arrow_back_ios,
        color: Colors.red,
        size: 24,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    var filteredList = allTasks
        .where(
            (gorev) => gorev.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // ignore: prefer_is_empty
    return filteredList.length > 0
        ? ListView.builder(
            itemBuilder: (context, index) {
              var _oAnkiListeElemani = filteredList[index];
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
                          const Text("remove_text").tr(),
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
                          const Text("archive_text").tr(),
                        ],
                      ),
                    ),
                  ],
                ),
                key: Key(_oAnkiListeElemani.id),
                onDismissed: (direction) async {
                  filteredList.removeAt(index);
                  await locator<LocalStorage>()
                      .deleteTask(task: _oAnkiListeElemani);
                },
                child: TaskItem(task: _oAnkiListeElemani),
              );
            },
            itemCount: filteredList.length,
          )
        : Center(
            child: const Text(
              'not_search_task',
              style: TextStyle(fontSize: 24),
            ).tr(),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
