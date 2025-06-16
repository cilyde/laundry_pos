enum ServiceType { wash, iron, both }

class ClothItem {
  final String name;
  final double washPrice;
  final double? ironPrice;
  bool isSelected;
  ServiceType? selectedService;
  int quantity;

  String img;

  ClothItem({
    required this.name,
    required this.washPrice,
    this.ironPrice,
    this.isSelected = false,
    this.selectedService, required this.img,
    this.quantity = 1,
  });

  double get totalPrice {
    switch (selectedService) {
      case ServiceType.wash:
        return washPrice * quantity;
      case ServiceType.iron:
        if(ironPrice!=null){
          return ironPrice! * quantity;
        }else {
          return 0.0;
        }
      case ServiceType.both:
        if(ironPrice!=null){
          return (washPrice + ironPrice!) * quantity;
        }
        else{
          return washPrice * quantity;
        }
      default:
        return 0;
    }
  }


}
