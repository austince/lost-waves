/*
Just helpful little functions that don't really have a home elsewhere

*/

void log(Object ...args) {
  if (debug) {
    println(args);
  }
}
