import 'package:provider/single_child_widget.dart';
import 'core_providers.dart';

// Note: As we create more feature files, we will import them here.
// import '../../features/inventory/domain/providers/inventory_providers.dart';

List<SingleChildWidget> getAllProviders() {
  return [
    ...createCoreProviders(),
    // ...createInventoryProviders(), // We will uncomment these one by one
    // ...createPOSProviders(),
  ];
}
