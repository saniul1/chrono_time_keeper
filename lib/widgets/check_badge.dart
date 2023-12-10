import 'package:chrono_time_keeper/models/commit_data_model.dart';
import 'package:chrono_time_keeper/states/time_commit_info_states.dart';
import 'package:chrono_time_keeper/widgets/value_incrementor.dart';
import 'package:flutter/material.dart';

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
              Duration.zero, (prev, cur) => prev + cur.calculateTime());
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
                    controller.text == '' ? 'All' : controller.text,
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
