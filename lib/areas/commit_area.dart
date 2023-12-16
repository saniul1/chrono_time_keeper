import 'package:chrono_time_keeper/extensions/list.dart';
import 'package:chrono_time_keeper/widgets/commit_info.dart';
import 'package:chrono_time_keeper/widgets/time_stamp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/db.dart';
import '../states/time_commit_info_states.dart';

class CommitAria extends StatefulWidget {
  const CommitAria({
    super.key,
  });

  @override
  State<CommitAria> createState() => _CommitAriaState();
}

class _CommitAriaState extends State<CommitAria> {
  final actionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            TimeStamp(
              setTime: (isDoubleTap) async {
                final duration = Duration(minutes: sliderValue.value.toInt());
                DateTime value = DateTime.now().subtract(duration);
                if (startTime.value != null && !isDoubleTap) {
                  value = startTime.value!.subtract(duration);
                }
                if (await DB.isDateValueWithinAnyEntry(value)) return;
                startTime.value = value;
              },
              buildChild: (context) {
                final time = CommitData.of(context).start;
                return Text(
                  time != null ? DateFormat('hh:mm a').format(time) : 'Start',
                );
              },
            ),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: const BoxConstraints(minWidth: 100),
              child: const CommitInfo(),
            ),
            TimeStamp(
              setTime: (isDoubleTap) async {
                final duration = Duration(minutes: sliderValue.value.toInt());
                DateTime value = DateTime.now().subtract(duration);
                if (endTime.value != null && !isDoubleTap) {
                  value = endTime.value!.subtract(duration);
                }
                if (await DB.isDateValueWithinAnyEntry(value)) return;
                endTime.value = value;
              },
              buildChild: (context) {
                final time = CommitData.of(context).end;
                return Text(
                  time != null ? DateFormat('hh:mm a').format(time) : 'End',
                );
              },
            ),
          ].wrapWithExpanded([1]).inBetweenSizedBox(10),
        ),
        Row(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: const BoxConstraints(minWidth: 100),
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8),
                child: Autocomplete(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return DB.instance.getRecentUniqueActions(10);
                    }
                    return DB.instance
                        .getMatchingActions(actionController.text);
                  },
                  optionsViewBuilder: (BuildContext context,
                      AutocompleteOnSelected<String> onSelected,
                      Iterable<String> options) {
                    final double width =
                        MediaQuery.of(context).size.width - 180;
                    final double itemHeight = 50.0 * options.length;
                    double height = MediaQuery.of(context).size.height - 150;
                    height = itemHeight > height
                        ? height < 50
                            ? 50
                            : height
                        : itemHeight;

                    return Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Material(
                          color: Theme.of(context).colorScheme.background,
                          shadowColor:
                              Theme.of(context).colorScheme.onBackground,
                          elevation: 10.0,
                          child: SizedBox(
                            width: width,
                            height: height,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return GestureDetector(
                                  onTap: () {
                                    onSelected(option);
                                    actionController.text = option;
                                  },
                                  child: Focus(
                                    child: ListTile(
                                      title: Text(
                                        option,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return TextField(
                      onChanged: (text) {
                        actionController.text = text;
                      },
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'What were you doing?',
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
                    );
                  },
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                final data = CommitData.of(context);
                final end = data.end ?? DateTime.now();
                if (data.start == null ||
                    end.difference(data.start!).inMinutes < 2.0) return;
                if (actionController.text != '') {
                  await DB.instance.addChrono(
                    data.start!,
                    end,
                    data.breakBetween?.toInt() ?? 0,
                    actionController.text,
                  );

                  startTime.value = null;
                  endTime.value = null;
                  breakValue.value = 0;
                }
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                constraints: const BoxConstraints(minWidth: 100),
                child: Center(
                  child: Text(
                    'Commit',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              ),
            ),
          ].wrapWithExpanded([0]).inBetweenSizedBox(10),
        ),
      ].inBetweenSizedBox(0, 16),
    );
  }
}
