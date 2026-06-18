import 'dart:js' as js;

void launchWebUrl(String url) {
  try {
    js.context.callMethod('open', [url, '_blank']);
  } catch (e) {
    // Fail-safe
  }
}
