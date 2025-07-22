import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/dialogs.dart';
import '../../../util/navigation/navigation_utils.dart';

class DoubleBackToClose extends StatefulWidget {
  /// Make Sure this child has a Scaffold widget as parent.
  final Widget child;

  /// Make Sure the child has a Scaffold widget as parent.
  const DoubleBackToClose({
    super.key,
    required this.child,
  });

  @override
  State<DoubleBackToClose> createState() => _DoubleBackToCloseState();
}

class _DoubleBackToCloseState extends State<DoubleBackToClose> {
  static const _exitTimeInMillis = Duration(seconds: 2);
  var _lastTimeBackButtonWasTapped = DateTime(0);
  bool _canPopNow = false;

  @override
  void initState() {
    super.initState();
  }

  void _setLastTapped() {
    setState(() {
      _lastTimeBackButtonWasTapped = DateTime.now();
      _canPopNow = true;
    });
  }

  void _resetCanPop() {
    setState(() {
      _lastTimeBackButtonWasTapped = DateTime(0);
      _canPopNow = false;
    });
  }

  bool _canPop() {
    return (DateTime.now().difference(_lastTimeBackButtonWasTapped) < _exitTimeInMillis);
  }

  bool get _isAndroid => Theme.of(context).platform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    if (_isAndroid) {
      return PopScope(
        canPop: _canPopNow,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          // is the drawer open? => first close the drawer
          if (NavigationUtils.closeDrawerIfOpen(context)) {
            return;
          }

          if (!_canPop()) {
            Dialogs.showSnackBar(LocaleKeys.commons_msg_pressBackAgainToExit.tr(), context);
            _setLastTapped();
            Future.delayed(_exitTimeInMillis, () => _resetCanPop());
          }
        },
        child: widget.child,
      );
    } else {
      return widget.child;
    }
  }
}
