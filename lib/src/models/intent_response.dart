class IntentResponse {
  final String status;
  final String clientSecret;

  bool get isSucceded => status == 'succeeded';

  IntentResponse({this.status, this.clientSecret});

  factory IntentResponse.fromJson(Map<String, dynamic> json) {
    return IntentResponse(
      status: json['status'] != null ? json['status'] as String : null,
      clientSecret: json['client_secret'] != null
          ? json['client_secret'] as String
          : null,
    );
  }
}
