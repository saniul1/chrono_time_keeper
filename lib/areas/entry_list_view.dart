import 'package:chrono_time_keeper/areas/footer_area.dart';
import 'package:chrono_time_keeper/db/db.dart';
import 'package:chrono_time_keeper/extensions/datetime.dart';
import 'package:chrono_time_keeper/extensions/string.dart';
import 'package:chrono_time_keeper/widgets/value_incrementor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_chart/time_chart.dart';

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
  bool _isChart = false;
  int _dayCount = 0;
  ViewMode _chartViewMode = ViewMode.weekly;
  ChartType _chartViewType = ChartType.time;
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
    var chartViewModeSelect = SizedBox(
      width: 60,
      child: DropdownButton<ViewMode>(
        value: _chartViewMode,
        isDense: true,
        underline: const SizedBox(),
        style: Theme.of(context).textTheme.bodyMedium,
        icon: const SizedBox(),
        items: ViewMode.values
            .map((e) => DropdownMenuItem<ViewMode>(
                  value: e,
                  child: Text(e.name.capitalize),
                ))
            .toList(),
        onChanged: (v) {
          setState(() {
            _chartViewMode = v ?? ViewMode.weekly;
          });
        },
      ),
    );
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
                        if (!_isChart)
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
                        else
                          chartViewModeSelect
                      ],
                    ),
                  )
                else if (_isChart)
                  Row(
                    children: [
                      chartViewModeSelect,
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 60,
                        child: DropdownButton<ChartType>(
                          value: _chartViewType,
                          isDense: true,
                          underline: const SizedBox(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          icon: const SizedBox(),
                          items: ChartType.values
                              .map((e) => DropdownMenuItem<ChartType>(
                                    value: e,
                                    child: Text(e.name.capitalize),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _chartViewType = v ?? ChartType.time;
                            });
                          },
                        ),
                      ),
                    ],
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
                if (!_isSearch)
                  SizedBox(
                    width: 60,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isChart = !_isChart;
                        });
                      },
                      child: Icon(
                        _isChart
                            ? Icons.candlestick_chart
                            : Icons.candlestick_chart_outlined,
                        size: 20,
                        color: !_isChart
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!_isChart)
          FutureBuilder(
            future: _isSearch
                ? DB.instance.getChronoForActionAndDays(
                    _searchController.text, _dayCount)
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
                                                            const EdgeInsets
                                                                .only(
                                                          right: 8.0,
                                                        ),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .background,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4.0,
                                                                    vertical:
                                                                        2),
                                                            child: Text(
                                                              commit.timeRange
                                                                      .start
                                                                      .isToday()
                                                                  ? 'Today'
                                                                  : commit.timeRange
                                                                          .start
                                                                          .isYesterday()
                                                                      ? 'Yesterday'
                                                                      : DateFormat(
                                                                              'dd/MM')
                                                                          .format(
                                                                              day),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.copyWith(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                            ),
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
                    SizedBox(
                      height: 22,
                      child: Footer(
                        commits: commits,
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        else
          TimeView(
            searchTerm: _searchController.text,
            viewMode: _chartViewMode,
            chartType: _chartViewType,
          ),
      ],
    );
  }
}

class TimeView extends StatelessWidget {
  const TimeView({
    super.key,
    this.searchTerm = '',
    required this.viewMode,
    required this.chartType,
  });

  final ViewMode viewMode;
  final ChartType chartType;
  final String searchTerm;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DB.instance
          .getChronoForActionAndDays(searchTerm, viewMode.dayCount - 1),
      builder: (context, data) {
        if (!data.hasData) {
          return const Text('fetching data...');
        }
        final List<DateTimeRange> commits =
            data.data == null || data.data!.isEmpty
                ? []
                : CommitDataModel.dateRangeFromListOfMap(data.data!);

        return TimeChart(
          height: MediaQuery.of(context).size.height - 236,
          data: commits,
          chartType: chartType,
          viewMode: viewMode,
          activeTooltip: true,
          tooltipBackgroundColor:
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
        );
      },
    );
  }
}
