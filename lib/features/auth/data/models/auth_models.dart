class TokenPair {
  final String accessToken;
  final String refreshToken;

  const TokenPair({required this.accessToken, required this.refreshToken});

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

class AuthUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: (json['first_name'] ?? '') as String,
      lastName: (json['last_name'] ?? '') as String,
    );
  }
}

class AuthResponse {
  final TokenPair token;
  final AuthUser user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponse(
      token: TokenPair.fromJson(data['token'] as Map<String, dynamic>),
      user: AuthUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}

class RegisterResponse {
  final AuthUser user;
  final TokenPair? token;

  const RegisterResponse({required this.user, this.token});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final userJson = data['user'] ?? data;
      if (userJson is Map<String, dynamic>) {
        return RegisterResponse(
          user: AuthUser.fromJson(userJson),
          token: _parseOptionalToken(data),
        );
      }
    }

    if (json['user'] is Map<String, dynamic>) {
      return RegisterResponse(
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        token: _parseOptionalToken(json),
      );
    }

    return RegisterResponse(
      user: AuthUser.fromJson(json),
      token: _parseOptionalToken(json),
    );
  }
}

TokenPair? _parseOptionalToken(Map<String, dynamic> json) {
  final token = json['token'];
  if (token is Map<String, dynamic>) {
    return TokenPair.fromJson(token);
  }
  final data = json['data'];
  if (data is Map<String, dynamic> && data['token'] is Map<String, dynamic>) {
    return TokenPair.fromJson(data['token'] as Map<String, dynamic>);
  }
  if (json['access_token'] != null && json['refresh_token'] != null) {
    return TokenPair(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
  return null;
}
