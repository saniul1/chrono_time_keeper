import 'package:chrono_time_keeper/db/db.dart';
import 'package:chrono_time_keeper/states/time_commit_info_states.dart';
import 'package:chrono_time_keeper/themes/get_theme.dart';
import 'package:flutter/material.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:macos_window_utils/widgets/transparent_macos_sidebar.dart';

import 'areas/commit_area.dart';
import 'areas/entry_list_view.dart';
import 'widgets/value_slider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    WindowManipulator.setMaterial(NSVisualEffectViewMaterial.fullScreenUI);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: getThemeData(),
      home: const TransparentMacOSSidebar(child: Home()),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    DB.instance.db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TitlebarSafeArea(
        child: FutureBuilder(
          future: DB.instance.open(),
          builder: (context, db) {
            if (db.connectionState != ConnectionState.done) {
              return const Center(child: Text('connectiong to database...'));
            }
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: ValueSlider(),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20, bottom: 12.0),
                  child: ValueListenableBuilder(
                    valueListenable: startTime,
                    builder: (context, start, child) {
                      return ValueListenableBuilder(
                        valueListenable: endTime,
                        builder: (context, end, child) {
                          return ValueListenableBuilder(
                            valueListenable: breakValue,
                            builder: (context, breakVal, _) {
                              return CommitData(
                                start: start,
                                end: end,
                                breakBetween: breakVal,
                                child: child!,
                              );
                            },
                          );
                        },
                        child: child,
                      );
                    },
                    child: const CommitAria(),
                  ),
                ),
                Divider(
                  indent: 0,
                  endIndent: 0,
                  height: 0,
                  thickness: 1.2,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const EntryListView()
              ],
            );
          },
        ),
      ),
    );
  }
}
