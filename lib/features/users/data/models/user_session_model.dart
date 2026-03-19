import '../../domain/entities/user_session.dart';

/// UserSessionModel for data transfer between database and domain layer
class UserSessionModel {
  final int? id;
  final int userId;
  final int loginTime;
  final int? logoutTime;
  final double openingCash;
  final double? closingCash;

  UserSessionModel({
    this.id,
    required this.userId,
    required this.loginTime,
    this.logoutTime,
    this.openingCash = 0,
    this.closingCash,
  });

  /// Create UserSessionModel from database map
  factory UserSessionModel.fromMap(Map<String, dynamic> map) {
    return UserSessionModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      loginTime: map['login_time'] as int,
      logoutTime: map['logout_time'] as int?,
      openingCash: (map['opening_cash'] as num?)?.toDouble() ?? 0,
      closingCash: (map['closing_cash'] as num?)?.toDouble(),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'login_time': loginTime,
      'logout_time': logoutTime,
      'opening_cash': openingCash,
      'closing_cash': closingCash,
    };
  }

  /// Convert to domain entity
  UserSession toEntity() {
    return UserSession(
      id: id,
      userId: userId,
      loginTime: DateTime.fromMillisecondsSinceEpoch(loginTime * 1000),
      logoutTime: logoutTime != null
          ? DateTime.fromMillisecondsSinceEpoch(logoutTime! * 1000)
          : null,
      openingCash: openingCash,
      closingCash: closingCash,
    );
  }

  /// Create UserSessionModel from domain entity
  static UserSessionModel fromEntity(UserSession session) {
    return UserSessionModel(
      id: session.id,
      userId: session.userId,
      loginTime: session.loginTime.millisecondsSinceEpoch ~/ 1000,
      logoutTime: session.logoutTime != null
          ? session.logoutTime!.millisecondsSinceEpoch ~/ 1000
          : null,
      openingCash: session.openingCash,
      closingCash: session.closingCash,
    );
  }
}
