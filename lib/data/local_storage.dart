// soyutlama yapılacak  abstract kullanılacak öyle bir sınıf ki tek yerde her yere hakim
import 'package:hive/hive.dart';
import 'package:todo_uygulamasi/models/task_model.dart';

// todo : get it paketi kuruldu -> sınıflarımızın birbirine bağımlılıkları olabilir.
// tododevam : bunları tek bir çatı altında toplamaya yarar

abstract class LocalStorage {
  //  gorev ekle ->
  //  required kullanılması nedendir ? => Bir nesneyi çağırır. Ekleyeceği nesneyi objeyi bildirmeliyiz. alt sınıftan bir nesne göndermeli ki biz bunu veritabanına kaydedelim

  Future<void> addTask({required Task task});
  //  geriye bir task döndürmeli. girilen id döndürmeli
  Future<Task?> getTask({required String id});
  // <list<Task>> -> İçinde task olan bir liste döndürmesi için oluşturuldu
  Future<List<Task>> getAllTask();
  //  Silinecek task ı bilmeli silme işlemi yapar. Bool değer döndürsün. eğer silindiyse true döndürsün
  Future<bool> deleteTask({required Task task});
  // update task güncellenecek task
  Future<Task> updateTask({required Task task});
}

class HiveLocalStorage extends LocalStorage {
  late Box<Task> _taskBox;
  HiveLocalStorage() {
    _taskBox = Hive.box<Task>('tasks');
  }

  @override
  Future<void> addTask({required Task task}) async {
    await _taskBox.put(task.id, task);
  }

  @override
  Future<bool> deleteTask({required Task task}) async {
    await task.delete();
    return true;
  }

  @override
  Future<List<Task>> getAllTask() async {
    List<Task> _allTask = <Task>[];
    _allTask = _taskBox.values.toList();

    if (_allTask.isNotEmpty) {
      _allTask.sort((Task a, Task b) => b.createdAt.compareTo(a.createdAt));
    }
    return _allTask;
  }

  @override
  Future<Task?> getTask({required String id}) async {
    if (_taskBox.containsKey(id)) {
      return _taskBox.get(id);
    } else {
      return null;
    }
  }

  @override
  Future<Task> updateTask({required Task task}) async {
    await task.save();
    return task;
  }
}
