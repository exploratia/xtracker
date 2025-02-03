import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/dialogs.dart';
import '../../util/globals.dart';

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
    return (DateTime.now().difference(_lastTimeBackButtonWasTapped) <
        _exitTimeInMillis);
  }

  bool get _isAndroid => Theme.of(context).platform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (_isAndroid) {
      return PopScope(
        canPop: _canPopNow,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          // is the drawer open? => first close the drawer
          if (Globals.scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Globals.scaffoldKey.currentState?.closeDrawer();
            return;
          }

          if (!_canPop()) {
            Dialogs.showSnackBar(t.commonsMsgPressBackAgainToExit, context);
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
