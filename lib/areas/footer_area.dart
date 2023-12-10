import 'package:chrono_time_keeper/models/commit_data_model.dart';
import 'package:chrono_time_keeper/widgets/check_badge.dart';
import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({
    super.key,
    required this.commits,
  });

  final List<CommitDataModel> commits;

  @override
  Widget build(BuildContext context) {
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
              child: Offstage(
                offstage: commits.isEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CheckBadge(
                    commits: commits,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
