import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'dart:io' as io;

import 'manifest.dart';

Future<void> main(List<String> arguments) async {
  if (!io.Platform.isWindows) {
    print('Dieser Installer funktioniert leider nur unter Windows.');
    return;
  }

  final manifest = await getManifest();
  var curVer = manifest.currentVersion;
  final tempDir = io.Directory.systemTemp;
  final mcDir = getMinecraftDirectory(tempDir);

  if (arguments.first.startsWith('--version:')) {
    curVer = int.tryParse(arguments.first.split(':').last) ?? curVer;
  }

  print('Die aktuelle Version ist v${manifest.currentVersion}.');

  if (!mcDir.existsSync()) {
    print('Minecraft Ordner konnte nicht gefunden werden.');
    return;
  }

  var futures = [
    install(manifest.ressources[curVer.toString()]!.mods, mcDir, 'mods'),
    install(
        manifest.ressources[curVer.toString()]!.shader, mcDir, 'shaderpacks'),
    install(manifest.ressources[curVer.toString()]!.textures, mcDir,
        'ressourcepacks')
  ];
  await Future.wait(futures);
}

Future<bool> install(
    List<File> ressource, io.Directory mcDir, String dir) async {
  for (var r in ressource) {
    final uri = Uri.parse(r.url);
    var result = await http.get(uri);
    if (result.statusCode == 200) {
      final location = io.Directory(p.join(mcDir.path, dir));
      await location.create();
      var file = io.File(p.join(location.path, r.name));
      await file.writeAsBytes(result.bodyBytes);
    } else {
      print('Installation von $r fehlgeschlagen');
    }
  }
  return true;
}

Future<Manifest> getManifest() async {
  final uri = Uri.parse(
      'https://raw.githubusercontent.com/phibr0/cavesncliffs/main/manifest.json?token=AOHZOJIYUOD4RMNWBHSI3CDBFJXSK');
  var response = await http.get(uri);
  return manifestFromJson(response.body);
}

io.Directory getMinecraftDirectory(io.Directory tempDir) {
  return io.Directory(
      p.join(tempDir.parent.parent.path, 'Roaming', '.minecraft'));
}
