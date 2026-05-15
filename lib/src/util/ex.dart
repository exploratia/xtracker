/// simple exception with message. toString() returns the message.
class Ex implements Exception {
  final String? message;
  final String? localizedMessage;

  Ex(
    this.message, {
    this.localizedMessage,
  });

  @override
  String toString() {
    if (message == null) return "Ex";
    return message!;
  }

  String localizedToString() {
    if (localizedMessage != null) return localizedMessage!;
    return toString();
  }
}
