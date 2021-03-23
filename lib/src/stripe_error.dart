import 'package:dio/dio.dart';

class StripeApiError {
  final String requestId;
  final String type;
  final String charge;
  final String code;
  final String declineCode;
  final String docUrl;
  final String message;
  final String param;

  StripeApiError({
    this.requestId,
    this.type,
    this.charge,
    this.code,
    this.declineCode,
    this.docUrl,
    this.message,
    this.param,
  });

  factory StripeApiError.fromJson(String requestId, Map<String, dynamic> json) {
    return StripeApiError(
      requestId: requestId,
      type: json['type'] == null ? null : json['type'] as String,
      charge: json['charge'] == null ? null : json['charge'] as String,
      code: json['code'] == null ? null : json['code'] as String,
      declineCode:
          json['decline_code'] == null ? null : json['decline_code'] as String,
      docUrl: json['doc_url'] == null ? null : json['doc_url'] as String,
      message: json['message'] == null ? null : json['message'] as String,
      param: json['param'] == null ? null : json['param'] as String,
    );
  }
}

class StripeApiException extends DioError {
  @override
  // ignore: overridden_fields
  final StripeApiError error;
  final String requestId;
  @override
  final String message;

  StripeApiException(this.error)
      : requestId = error.requestId,
        message = error.message;

  @override
  String toString() => message;
}
