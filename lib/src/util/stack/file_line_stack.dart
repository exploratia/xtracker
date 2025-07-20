class FileLineStack {
  final String fileName;
  final String fileFullName;
  final String lineNo;
  final String? stack;

  FileLineStack(this.fileName, this.fileFullName, this.lineNo, this.stack);

  String toConsoleFileLine() {
    return '$fileFullName:$lineNo';
  }

  String toLogFileLine() {
    return '$fileName:$lineNo';
  }
}
