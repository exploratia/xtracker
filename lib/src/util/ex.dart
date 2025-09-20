/// simple exception with message. toString() returns the message.
class Ex implements Exception {
  final dynamic message;
  final dynamic localizedMessage;

  Ex(
    this.message, {
    this.localizedMessage,
  });

  @override
  String toString() {
    if (message == null) return "Ex";
    return message.toString();
  }

  String localizedToString() {
    if (localizedMessage != null) return localizedMessage.toString();
    return toString();
  }
}
