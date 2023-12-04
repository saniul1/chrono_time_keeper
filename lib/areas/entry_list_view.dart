import 'package:chrono_time_keeper/db/db.dart';
import 'package:chrono_time_keeper/extensions/datetime.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/commit_data_model.dart';

class EntryListView extends StatefulWidget {
  const EntryListView({
    super.key,
  });

  @override
  State<EntryListView> createState() => _EntryListViewState();
}

class _EntryListViewState extends State<EntryListView> {
  DateTime day = DateTime.now();

  @override
  void initState() {
    super.initState();
    DB.instance.addListener(() {
      setState(() {
        day = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      day = day.subtract(const Duration(days: 1));
                    });
                  },
                  child: const Text('<')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      day = DateTime.now();
                    });
                  },
                  child: day.isToday()
                      ? const Text('Today')
                      : day.isYesterday()
                          ? const Text('Yesterday')
                          : Text(DateFormat('dd/MM/yy').format(day)),
                ),
              ),
              TextButton(
                onPressed: day.isToday()
                    ? null
                    : () {
                        setState(() {
                          day = day.add(const Duration(days: 1));
                        });
                      },
                child: const Text('>'),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: DB.instance.getChronoForDay(day),
          builder: (context, data) {
            if (!data.hasData) {
              return const Text('fetching data...');
            }
            final List<CommitDataModel> commits =
                data.data == null || data.data!.isEmpty
                    ? []
                    : CommitDataModel.fromListOfMap(data.data!);
            return Padding(
              padding:
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 250,
                    child: commits.isEmpty
                        ? const Center(child: Text('No chronos found'))
                        : ListView.builder(
                            itemCount: commits.length,
                            itemBuilder: (context, i) {
                              final commit = commits[i];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(commit.action),
                                        SizedBox(
                                          width: 200,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('${commit.breakValue} min'),
                                              Text(commit
                                                  .calculdateTimeString()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  _footer(commits)
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _footer(List<CommitDataModel> commits) {
    return SizedBox(
      height: 18,
      child: Builder(builder: (context) {
        final total = commits.fold(
            Duration.zero, (prev, curr) => prev + curr.calculdateTime());
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '⌥Q',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.5),
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Text(
                    commits.firstOrNull?.calculdateTimeString(total) ?? ''),
              ),
            ],
          ),
        );
      }),
    );
  }
}
