import 'dart:async';

import 'package:meta/meta.dart';

import 'stripe_api_handler.dart';

/// Function that takes a apiVersion and returns a Stripe ephemeral key response
typedef EphemeralKeyProvider = Future<EphemeralKey> Function(String apiVersion);

/// Represents a Stripe Ephemeral Key
@immutable
class EphemeralKey {
  final String id;
  final int created;
  final int expires;
  final bool liveMode;
  final String object;
  final String secret;
  final List<AssociatedObject> associatedObjects;
  final DateTime createdAt;
  final DateTime expiresAt;

  const EphemeralKey({
    this.id,
    this.created,
    this.expires,
    this.liveMode,
    this.object,
    this.secret,
    this.associatedObjects,
    this.createdAt,
    this.expiresAt,
  });

  factory EphemeralKey.fromJson(Map<String, dynamic> json) {
    return EphemeralKey(
      id: json['id'] == null ? null : json['id'] as String,
      created: json['created'] == null ? null : json['created'] as int,
      expires: json['expires'] == null ? null : json['expires'] as int,
      liveMode: json['livemode'] == null ? null : json['livemode'] as bool,
      object: json['object'] == null ? null : json['object'] as String,
      secret: json['secret'] == null ? null : json['secret'] as String,
      associatedObjects: json['associated_objects'] == null
          ? null
          : (json['associated_objects'] as List)
              .map((e) => e == null
                  ? null
                  : AssociatedObject.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt: json['created'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              (json['created'] as int) * 1000),
      expiresAt: json['expires'] == null
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(
              (json['expires'] as int) * 1000),
    );
  }

  String get customerId => associatedObjects[0]?.id;
}

@immutable
class AssociatedObject {
  final String type;
  final String id;

  const AssociatedObject({
    this.type,
    this.id,
  });

  factory AssociatedObject.fromJson(Map<String, dynamic> json) {
    return AssociatedObject(
      type: json['type'] != null ? json['type'] as String : null,
      id: json['id'] != null ? json['id'] as String : null,
    );
  }
}

class EphemeralKeyManager {
  EphemeralKey _ephemeralKey;
  final EphemeralKeyProvider ephemeralKeyProvider;
  final int timeBufferInSeconds;

  EphemeralKeyManager(this.ephemeralKeyProvider, this.timeBufferInSeconds);

  /// Retrieve a ephemeral key.
  /// Will fetch a new one using [EphemeralKeyProvider] if required.
  Future<EphemeralKey> retrieveEphemeralKey() async {
    if (_shouldRefreshKey()) {
      return _ephemeralKey = await ephemeralKeyProvider(kDefaultApiVersion);
    } else {
      return _ephemeralKey;
    }
  }

  bool _shouldRefreshKey() {
    if (_ephemeralKey == null) {
      return true;
    }
    final now = DateTime.now();
    final diff = _ephemeralKey.expiresAt.difference(now);
    return diff.inSeconds < timeBufferInSeconds;
  }
}
