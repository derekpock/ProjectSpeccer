String coaop = "";

void initCoaop() {
  // Using asserts because they are ignored (tree-shaken) in production.
  // We only want to set the coaop value in debug mode.
  assert(() {
    coaop = "";
    return true;
  }());
}