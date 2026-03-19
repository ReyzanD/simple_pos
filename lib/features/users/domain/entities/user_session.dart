/// UserSession entity representing a user login session
class UserSession {
  final int? id;
  final int userId;
  final DateTime loginTime;
  final DateTime? logoutTime;
  final double openingCash;
  final double? closingCash;

  const UserSession({
    this.id,
    required this.userId,
    required this.loginTime,
    this.logoutTime,
    this.openingCash = 0,
    this.closingCash,
  });

  /// Check if session is currently active
  bool get isActive => logoutTime == null;

  /// Calculate session duration
  Duration? get duration {
    if (logoutTime == null) return null;
    return logoutTime!.difference(loginTime);
  }

  /// Calculate cash difference
  double? get cashDifference {
    if (closingCash == null) return null;
    return closingCash! - openingCash;
  }

  /// Create a copy with some fields replaced
  UserSession copyWith({
    int? id,
    int? userId,
    DateTime? loginTime,
    DateTime? logoutTime,
    double? openingCash,
    double? closingCash,
  }) {
    return UserSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loginTime: loginTime ?? this.loginTime,
      logoutTime: logoutTime ?? this.logoutTime,
      openingCash: openingCash ?? this.openingCash,
      closingCash: closingCash ?? this.closingCash,
    );
  }

  @override
  String toString() {
    return 'UserSession(id: $id, userId: $userId, loginTime: $loginTime, logoutTime: $logoutTime, openingCash: $openingCash, closingCash: $closingCash)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSession &&
        other.id == id &&
        other.userId == userId &&
        other.loginTime == loginTime &&
        other.logoutTime == logoutTime &&
        other.openingCash == openingCash &&
        other.closingCash == closingCash;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        loginTime.hashCode ^
        logoutTime.hashCode ^
        openingCash.hashCode ^
        closingCash.hashCode;
  }
}
