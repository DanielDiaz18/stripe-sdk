class PaymentMethod {
  final String id;
  final String last4;
  final String brand;

  PaymentMethod({this.id, this.last4, this.brand});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      last4: json['card']['last4'] as String,
      brand: json['card']['brand'] as String,
    );
  }
}
