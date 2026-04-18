/// All application routes in one place.
enum AppRoute {
  splashScreen('/'),
  loginScreen('/login'),
  productsScreen('/products');

  const AppRoute(this.path);

  final String path;

  static AppRoute? fromPath(String? path) {
    if (path == null) {
      return null;
    }
    return AppRoute.values.where((r) => r.path == path).firstOrNull;
  }
}
