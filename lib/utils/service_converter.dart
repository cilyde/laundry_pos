import '../models/cloth_item.dart';
import '../view_models/pos_view_model.dart';

/// Returns a localized label for the laundry service type.
String serviceLabel(ServiceType type, String currentLanguage) {
  switch (type) {
    case ServiceType.wash:
      return tr('wash', currentLanguage);
    case ServiceType.iron:
      return tr('iron', currentLanguage);
    case ServiceType.both:
      return tr('both', currentLanguage);
  }
}