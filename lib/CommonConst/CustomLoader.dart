import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// TODO:  Working loader indicator

// TODO: loader class - in use working
//full screen laoder
class LoaderManager {
  static OverlayEntry? _loaderOverlay;

  static void callLoader(BuildContext context, bool show) {
    if (show) {
      if (_loaderOverlay == null) {
        _loaderOverlay = OverlayEntry(
          builder: (_) => Container(
            color: Colors.black.withOpacity(0.2), // Semi-transparent background
            child: Center(
              child: CircularProgressIndicator(), // Loader in the center
            ),
          ),
        );
        Overlay.of(context)?.insert(_loaderOverlay!);
      }
    } else {
      _loaderOverlay?.remove();
      _loaderOverlay = null;
    }
  }
}
