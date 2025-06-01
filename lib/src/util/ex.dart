/// simple exception with message. toString() returns the message.
class Ex implements Exception {
  final dynamic message;

  Ex(this.message);

  @override
  String toString() {
    if (message == null) return "Ex";
    return message.toString();
  }
}
