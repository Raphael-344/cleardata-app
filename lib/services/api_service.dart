import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://cleardata-site.vercel.app';

class ApiService {
  static Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(Uri.parse('$baseUrl/api/stats'));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getCarte({String sigle = 'CO2', String? date}) async {
    final d = date != null ? '&date=$date' : '';
    final res = await http.get(Uri.parse('$baseUrl/api/carte?sigle=$sigle$d'));
    final data = jsonDecode(res.body);
    return data['rows'] ?? [];
  }

  static Future<Map<String, dynamic>> getRequete(String id, {String? param}) async {
    final p = param != null ? '&param=${Uri.encodeComponent(param)}' : '';
    final res = await http.get(Uri.parse('$baseUrl/api/requetes?id=$id$p'));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getGraphique({
    String type = 'evolution',
    String sigle = 'CO2',
    String region = 'Île-de-France',
  }) async {
    final res = await http.get(Uri.parse(
      '$baseUrl/api/graphiques?type=$type&sigle=$sigle&region=${Uri.encodeComponent(region)}',
    ));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> search(String q, {String? sigle}) async {
    if (q.length < 2) return [];
    final s = sigle != null ? '&sigle=$sigle' : '';
    final res = await http.get(Uri.parse('$baseUrl/api/search?q=${Uri.encodeComponent(q)}$s'));
    return jsonDecode(res.body);
  }
}
