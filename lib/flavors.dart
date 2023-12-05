enum Flavor {
  dev,
  prod,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Chrono-dev';
      case Flavor.prod:
        return 'Chrono';
      default:
        return 'title';
    }
  }

}
