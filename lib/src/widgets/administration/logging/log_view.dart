import 'package:flutter/material.dart';

import '../../../util/logging/daily_files.dart';
import '../../../util/media_query_utils.dart';
import '../../controls/future/future_builder_with_progress_indicator.dart';
import '../../controls/layout/scroll_footer.dart';
import '../../controls/navigation/hide_bottom_navigation_bar.dart';

class LogView extends StatefulWidget {
  const LogView(this.logFileName, {super.key});

  final String logFileName;

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // In the ListViewBuilder we have no ScrollPosHandler -> hide BottomNavBar always.
    WidgetsBinding.instance.addPostFrameCallback((_) => HideBottomNavigationBar.setVisible(false));

    return SizedBox(
      width: double.infinity,
      child: FutureBuilderWithProgressIndicator(
        future: DailyFiles.readLogLines(widget.logFileName, context, !MediaQueryUtils.of(context).isTablet),
        errorBuilder: (error) => 'Failed to load log!',
        widgetBuilder: (logFileContent, _) {
          if (logFileContent == null) {
            return Center(child: Text('Log file "${widget.logFileName}" not found!'));
          }

          return _LogLines(
            logLines: logFileContent,
            refreshHandler: _rebuild,
          );
        },
      ),
    );
  }
}

class _LogLines extends StatelessWidget {
  const _LogLines({required this.logLines, required this.refreshHandler});

  final List<String> logLines;
  final VoidCallback refreshHandler;

  static const double linePad = 4;
  static const double outerPad = 8;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        refreshHandler();
      },
      child: ListView.builder(
          itemBuilder: (context, index) {
            var logLineText = logLines[index];
            var logLine = _LogLine(
              logLine: logLineText,
              key: ValueKey(logLineText.length > 28 ? logLineText.substring(0, 27) : logLineText),
            );

            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: outerPad, right: outerPad, top: outerPad, bottom: linePad),
                child: logLine,
              );
            }
            if (index == logLines.length - 1) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: outerPad, right: outerPad, top: linePad),
                    child: logLine,
                  ),
                  const Center(child: ScrollFooter()),
                ],
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: linePad, horizontal: outerPad),
              child: logLine,
            );
          },
          itemCount: logLines.length),
    );
  }
}

class _LogLine extends StatelessWidget {
  const _LogLine({
    super.key,
    required this.logLine,
  });

  final String logLine;

  @override
  Widget build(BuildContext context) {
    Color? col;
    if (logLine.contains('WARN')) {
      col = Colors.orange;
    } else if (logLine.contains('ERROR')) {
      col = Colors.red;
    } else if (logLine.contains('WTF')) {
      col = Colors.purple;
    }
    return Text(
      logLine,
      style: TextStyle(color: col),
    );
  }
}
