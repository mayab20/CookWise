import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';


class ApiService {
  final String baseUrl;
  String? _jwtToken;

  ApiService({required this.baseUrl});

  // JWT 
  void setToken(String token) {
    _jwtToken = token;
  }

  void clearToken() {
    _jwtToken = null;
  }

  String? getToken() => _jwtToken;

  Map<String, String> get headers {
    final headers = {'Content-Type': 'application/json'};
    if (_jwtToken != null) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }

  Map<String, String> get authHeaders {
    if (_jwtToken == null) {
      throw Exception("No JWT token set");
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_jwtToken',
    };
  }

  // AUTH
  Future<User> login(String email, String password) async {
    print('Attempting login for: $email');
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Login response status: ${response.statusCode}');
    print('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Login API response: $data');
      final token = data['token'];

      if (token == null) {
        throw Exception("No token returned from server");
      }

      setToken(token);
      final user = User.fromJson(data['user'], token: token);
      print('Created user from API: ID=${user.id}, name=${user.name}');
      return user;
    } else {
      throw Exception(response.body);
    }
  }

  Future<User> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toRegisterJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      if (token == null) {
        throw Exception("No token returned from server");
      }

      setToken(token);
      return User.fromJson(data['user'], token: token);
    } else {
      throw Exception(response.body);
    }
  }

  Future<User> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toUpdateJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Update failed');
    }
  }


}
