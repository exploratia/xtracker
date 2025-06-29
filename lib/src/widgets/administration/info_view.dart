import 'package:flutter/material.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/infoType.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../layout/single_child_scroll_view_with_scrollbar.dart';
import '../navigation/hide_bottom_navigation_bar.dart';

class InfoView extends StatelessWidget {
  const InfoView({super.key, required this.infoType});

  final InfoType infoType;

  Future<void> _launchUrl(dynamic lnk) async {
    try {
      var url = Uri.parse(lnk);
      if (!await launchUrl(url)) {
        SimpleLogging.w('Could not launch $url');
      }
    } catch (err) {
      SimpleLogging.w('Could not launch $lnk');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var defaultTextStyle = TextStyle(
      color: themeData.textTheme.bodyMedium?.color,
      fontSize: 14,
    );
    Map<String, TextStyle> overrideStyle = {
      "a": TextStyle(color: themeData.colorScheme.primary, fontWeight: themeData.textTheme.bodyMedium?.fontWeight),
    };
    var richText = HTML.toRichText(context, infoType.infoHTML, defaultTextStyle: defaultTextStyle, overrideStyle: overrideStyle, linksCallback: (link) {
      _launchUrl(link);
    });

    return SingleChildScrollViewWithScrollbar(
      scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
      child: richText,
    );
  }
}
