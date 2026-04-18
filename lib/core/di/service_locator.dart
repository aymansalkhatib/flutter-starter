import 'package:get_it/get_it.dart';

import '../../features/authentication/di/authentication_dependencies.dart';
import '../../features/products/di/product_dependencies.dart';
import 'core_dependencies.dart';

final GetIt sl = GetIt.instance;

/// Initializes all application dependencies.
///
/// Registration order matters — core services must be registered first
/// since features depend on them (e.g. [ApiClient]).
void initializeDependencies() {
  registerCoreDependencies();
  registerAuthenticationDependencies();
  registerProductDependencies();
}
