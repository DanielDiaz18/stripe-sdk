class StripeCard {
  String number;
  String cvc;
  int expMonth;
  int expYear;
  String last4;
  String postalCode;

  StripeCard({
    this.number,
    this.cvc,
    this.expMonth,
    this.expYear,
    this.last4,
  });

  /// Returns a stripe hash that represents this card.
  /// It only sets the type and card details. In order to add additional details such as name and address,
  /// you need to insert these keys into the hash before submitting it.
  Map<String, dynamic> toPaymentMethod() {
    return <String, dynamic>{
      'type': 'card',
      'card': {
        'number': number,
        'cvc': cvc,
        'exp_month': expMonth,
        'exp_year': expYear,
      }..removeWhere((_, value) => value == null),
      if (postalCode != null)
        'billing_details': {
          'address': {'postal_code': postalCode}
        }
    };
  }
}
