import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'dart:io' as io;

import 'manifest.dart';

Future<void> main(List<String> arguments) async {
  var watch = Stopwatch();
  watch.start();
  if (!io.Platform.isWindows) {
    printError('Dieser Installer funktioniert leider nur unter Windows.');
    return;
  }

  final manifest = await getManifest();
  if (manifest == null) {
    return;
  }

  var curVer = manifest.currentVersion;
  final tempDir = io.Directory.systemTemp;

  if (arguments.isNotEmpty && arguments.first.startsWith('--version:')) {
    curVer = int.tryParse(arguments.first.split(':').last) ?? curVer;
  }

  print('Die aktuelle Version ist v${manifest.currentVersion}.\n');

  final mcDir = getMinecraftDirectory(tempDir);
  if (!await mcDir.exists()) {
    printError('Minecraft Ordner konnte nicht gefunden werden.');
    return;
  }
  print('Minecraft Ordner: ${mcDir.path}\n');

  print('Möchtest du Fabric installieren? (Nur einmal erforderlich) [ja/nein]');
  var input = io.stdin.readLineSync();
  print('');
  if (input != null && !input.toLowerCase().startsWith('n')) {
    await installFabric(tempDir, manifest.fabricInstaller);
  }

  await backupDir(mcDir, ['resourcepacks', 'mods', 'shaderpacks']);

  var futures = [
    installFiles(manifest.ressources[curVer.toString()]!.mods, mcDir, 'mods'),
    installFiles(
        manifest.ressources[curVer.toString()]!.shader, mcDir, 'shaderpacks'),
    installFiles(manifest.ressources[curVer.toString()]!.textures, mcDir,
        'resourcepacks')
  ];
  await Future.wait(futures);
  watch.stop();
  print(
      '\nInstallation hat ${watch.elapsed.inSeconds < 1 ? "${watch.elapsed.inMilliseconds} ms" : "${watch.elapsed.inSeconds} sekunden"} gedauert.\nDu kannst dieses Fenster jetzt schließen.');
  io.stdin.readLineSync();
}

Future<void> installFabric(io.Directory tempDir, String fabricUrl) async {
  final uri = Uri.parse(fabricUrl);
  var result = await http.get(uri);
  if (result.statusCode == 200) {
    var file = io.File(p.join(tempDir.path, 'fabric.jar'));
    await file.writeAsBytes(result.bodyBytes);
    var process = await io.Process.run('java', ['-jar', 'fabric.jar', 'client'],
        workingDirectory: tempDir.path);
    print(process.stdout);
    if (process.exitCode != 0) {
      printError(process.stderr);
    }
  } else {
    printError('Installation von Fabric fehlgeschlagen');
  }
  return;
}

Future<void> backupDir(io.Directory mcDir, List<String> directories) async {
  final backupFolderName =
      'Backup ${DateTime.now().toIso8601String().replaceAll(':', '-')}';
  final backupDir =
      await io.Directory(p.join(mcDir.path, backupFolderName)).create();
  for (var dirName in directories) {
    final workingDir = io.Directory(p.join(mcDir.path, dirName));
    final backupSubDir =
        await io.Directory(p.join(backupDir.path, dirName)).create();
    await copyDirectory(workingDir, backupSubDir);
    workingDir.listSync().forEach((element) => element.delete(recursive: true));
  }
  printWarning(
      'Backup alter Mods, Shader und Resourcepacks erstellt in: ${backupDir.path}\n');
}

Future<void> copyDirectory(
    io.Directory source, io.Directory destination) async {
  await for (var entity in source.list(recursive: false)) {
    if (entity is io.Directory) {
      var newDirectory = io.Directory(
          p.join(destination.absolute.path, p.basename(entity.path)));
      await newDirectory.create();
      await copyDirectory(entity.absolute, newDirectory);
    } else if (entity is io.File) {
      await entity.copy(p.join(destination.path, p.basename(entity.path)));
    }
  }
}

Future<bool> installFiles(
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
      printWarning('Installation von ${r.name} fehlgeschlagen');
    }
  }
  print('Alle $dir installiert!');
  return true;
}

Future<Manifest?> getManifest() async {
  try {
    final uri = Uri.parse(
        'https://cdn.discordapp.com/attachments/504000747478974477/881475635422310411/manifest.json');
    var response = await http.get(uri);
    return manifestFromJson(response.body);
  } catch (e) {
    printError(e.toString());
  }
}

io.Directory getMinecraftDirectory(io.Directory tempDir) {
  return io.Directory(
      p.join(tempDir.parent.parent.path, 'Roaming', '.minecraft'));
}

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}
