import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_uygulamasi/data/local_storage.dart';
import 'package:todo_uygulamasi/models/task_model.dart';
import 'package:todo_uygulamasi/pages/home_page.dart';
import 'package:easy_localization/easy_localization.dart';
// ignore: unused_import
import 'package:flutter_localizations/flutter_localizations.dart';
// todo : get it paketi kuruldu -> sınıflarımızın birbirine bağımlılıkları olabilir.
// tododevam : bunları tek bir çatı altında toplamaya yarar

final locator = GetIt.instance;

void setup() {
  // mockData burada kullanılabilir
  locator.registerSingleton<LocalStorage>(HiveLocalStorage());
}

Future<void> setupHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  // kutu açma
  var taskBox = await Hive.openBox<Task>('tasks');

  // bugünden önceki gün ekelenen verileri silen for döngüsü
  for (var task in taskBox.values) {
    if (task.createdAt.day != DateTime.now().day) {
      taskBox.delete(task.id);
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.black),
  );
  await setupHive();

  setup();
  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('tr', 'TR')],
        path:
            'assets/translations', // <-- change the path of the translation files
        fallbackLocale: const Locale('en', 'US'),
        child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.deviceLocale,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const HomePage(),
    );
  }
}
