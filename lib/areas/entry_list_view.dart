import 'package:chrono_time_keeper/db/db.dart';
import 'package:chrono_time_keeper/extensions/datetime.dart';
import 'package:chrono_time_keeper/states/time_commit_info_states.dart';
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
  bool _isSearch = false;
  int _dayCount = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    DB.instance.addListener(() {
      setState(() {
        day = DateTime.now();
      });
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 60,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isSearch = !_isSearch;
                      });
                    },
                    child: Icon(
                      _isSearch ? Icons.search_off : Icons.search,
                      size: 20,
                      color: !_isSearch
                          ? Theme.of(context).colorScheme.secondary
                          : null,
                    ),
                  ),
                ),
                if (_isSearch)
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.6),
                                    ),
                                border: InputBorder.none,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        ValueIncrementor(
                          onLeft: () {
                            setState(() {
                              _dayCount += 1;
                            });
                          },
                          onRight: _dayCount == 0
                              ? null
                              : () {
                                  setState(() {
                                    _dayCount -= 1;
                                  });
                                },
                          onTap: () {
                            setState(() {
                              _dayCount = 0;
                            });
                          },
                          valueInText: Text('${_dayCount + 1}'),
                        )
                      ],
                    ),
                  )
                else
                  ValueIncrementor(
                    onLeft: () {
                      setState(() {
                        day = day.subtract(const Duration(days: 1));
                      });
                    },
                    onTap: () {
                      setState(() {
                        day = DateTime.now();
                      });
                    },
                    onRight: day.isToday()
                        ? null
                        : () {
                            setState(() {
                              day = day.add(const Duration(days: 1));
                            });
                          },
                    valueInText: day.isToday()
                        ? const Text('Today')
                        : day.isYesterday()
                            ? const Text('Yesterday')
                            : Text(DateFormat('dd/MM/yy').format(day)),
                  ),
                if (!_isSearch) const SizedBox(width: 60),
              ],
            ),
          ),
        ),
        FutureBuilder(
          future: _isSearch
              ? DB.instance
                  .getChronoForActionAndDays(_searchController.text, _dayCount)
              : DB.instance.getChronoForDay(day),
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
                    height: MediaQuery.of(context).size.height - 254,
                    child: commits.isEmpty
                        ? const Center(child: Text('No chronos found'))
                        : ListView.builder(
                            itemCount: commits.length,
                            itemBuilder: (context, i) {
                              final commit = commits[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 6.0),
                                child: GestureDetector(
                                  onDoubleTap: () {
                                    // TODO: add confirm dialog
                                    // DB.instance.deleteEntryById(commit.id);
                                  },
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
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Text(commit.action),
                                                if (_isSearch)
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        right: 8.0,
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .background,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Text(commit
                                                                  .start
                                                                  .isToday()
                                                              ? 'Today'
                                                              : commit.end
                                                                      .isYesterday()
                                                                  ? 'Yesterday'
                                                                  : DateFormat(
                                                                          'dd/MM')
                                                                      .format(
                                                                          day)),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 200,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    '${commit.breakValue} min'),
                                                Text(commit
                                                    .calculateTimeString()),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
      height: 22,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
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
              padding: const EdgeInsets.only(right: 12.0),
              child: (commits.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CheckBadge(
                        commits: commits,
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckBadge extends StatefulWidget {
  const CheckBadge({
    super.key,
    required this.commits,
  });

  final List<CommitDataModel> commits;

  @override
  State<CheckBadge> createState() => _CheckBadgeState();
}

class _CheckBadgeState extends State<CheckBadge> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'What would you like to track',
                      hintStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.6),
                              ),
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      const Text('In hours'),
                      ValueListenableBuilder(
                        valueListenable: trackValue,
                        builder: (context, value, _) {
                          return ValueIncrementor(
                            onLeft: () {
                              if (trackValue.value > 0) {
                                trackValue.value -= 1;
                              }
                            },
                            onRight: () {
                              trackValue.value += 1;
                            },
                            onTap: () {
                              trackValue.value = 0;
                            },
                            valueInText: Text('${trackValue.value}'),
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
      child: ValueListenableBuilder(
        valueListenable: trackValue,
        builder: (context, value, _) {
          final filteredCommits = controller.text == ''
              ? widget.commits
              : widget.commits
                  .where((commit) => commit.action
                      .toLowerCase()
                      .contains(controller.text.toLowerCase()))
                  .toList();

          final total = filteredCommits.fold(
              Duration.zero, (prev, curr) => prev + curr.calculateTime());
          bool isGreen =
              trackValue.value != 0 && trackValue.value <= total.inHours;

          return Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isGreen
                      ? Colors.green
                      : Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Text(
                    controller.text == '' ? 'Total' : controller.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 10,
                          color: isGreen ? Colors.amber : null,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.commits.firstOrNull?.calculateTimeString(total) ?? '',
              ),
            ],
          );
        },
      ),
    );
  }
}

class ValueIncrementor extends StatelessWidget {
  const ValueIncrementor({
    super.key,
    required this.onRight,
    required this.onLeft,
    required this.onTap,
    required this.valueInText,
  });

  final void Function()? onLeft;
  final void Function()? onRight;
  final void Function()? onTap;
  final Text valueInText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: onLeft,
          child: const Text('<'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            onTap: onTap,
            child: valueInText,
          ),
        ),
        TextButton(
          onPressed: onRight,
          child: const Text('>'),
        ),
      ],
    );
  }
}
