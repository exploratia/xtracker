import 'dart:io';

Future<bool> isDropboxInternetAvailable(Duration timeout) async {
  Socket? socket;
  try {
    socket = await Socket.connect('api.dropboxapi.com', 443, timeout: timeout);
    return true;
  } on SocketException {
    return false;
  } finally {
    socket?.destroy();
  }
}
