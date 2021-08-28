// To parse this JSON data, do
//
//     final manifest = manifestFromJson(jsonString);

import 'dart:convert';

Manifest manifestFromJson(String str) => Manifest.fromJson(json.decode(str));

String manifestToJson(Manifest data) => json.encode(data.toJson());

class Manifest {
  Manifest({
    required this.currentVersion,
    required this.ressources,
  });

  final int currentVersion;
  final Map<String, Ressource> ressources;

  factory Manifest.fromJson(Map<String, dynamic> json) => Manifest(
        currentVersion: json['currentVersion'],
        ressources: Map.from(json['ressources']).map(
            (k, v) => MapEntry<String, Ressource>(k, Ressource.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        'currentVersion': currentVersion,
        'ressources': Map.from(ressources)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class Ressource {
  Ressource({
    required this.mods,
    required this.shader,
    required this.textures,
  });

  final List<File> mods;
  final List<File> shader;
  final List<File> textures;

  factory Ressource.fromJson(Map<String, dynamic> json) => Ressource(
        mods: List<File>.from(json['mods'].map((x) => File.fromJson(x))),
        shader: List<File>.from(json['shader'].map((x) => File.fromJson(x))),
        textures:
            List<File>.from(json['textures'].map((x) => File.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'mods': List<dynamic>.from(mods.map((x) => x.toJson())),
        'shader': List<dynamic>.from(shader.map((x) => x.toJson())),
        'textures': List<dynamic>.from(textures.map((x) => x.toJson())),
      };
}

class File {
  File({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  factory File.fromJson(Map<String, dynamic> json) => File(
        name: json['name'],
        url: json['url'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };
}
