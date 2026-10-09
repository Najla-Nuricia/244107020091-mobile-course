abstract class Failure implements Exception {
  const Failure(this.message);

  final String message;
}
