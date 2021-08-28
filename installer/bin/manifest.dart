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
  final Map<String, Files> ressources;

  factory Manifest.fromJson(Map<String, dynamic> json) => Manifest(
        currentVersion: json['currentVersion'],
        ressources: Map.from(json['ressources'])
            .map((k, v) => MapEntry<String, Files>(k, Files.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        'currentVersion': currentVersion,
        'ressources': Map.from(ressources)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class Files {
  Files({
    required this.mods,
    required this.shader,
    required this.textures,
  });

  final List<Ressource> mods;
  final List<Ressource> shader;
  final List<Ressource> textures;

  factory Files.fromJson(Map<String, dynamic> json) => Files(
        mods: List<Ressource>.from(
            json['mods'].map((x) => Ressource.fromJson(x))),
        shader: List<Ressource>.from(
            json['shader'].map((x) => Ressource.fromJson(x))),
        textures: List<Ressource>.from(
            json['textures'].map((x) => Ressource.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'mods': List<dynamic>.from(mods.map((x) => x.toJson())),
        'shader': List<dynamic>.from(shader.map((x) => x.toJson())),
        'textures': List<dynamic>.from(textures.map((x) => x.toJson())),
      };
}

class Ressource {
  Ressource({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  factory Ressource.fromJson(Map<String, dynamic> json) => Ressource(
        name: json['name'],
        url: json['url'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };
}
