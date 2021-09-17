# The Caves N Cliffs Installer CLI

## Documentation

The Installer fetches the manifest.json from the Repository root and parses it to an Manifest Object. If the User decides to install Fabric it will download it from the URL in the Manifest and then proceed to install it in a Sub (Child) Process. If the Installer exits with a Code of `0` the Installer will look up the ressources of the current Version, which is either specified via the `--version:x` argument or via the currentVersion tag in the manifest. There will be a backup Folder created inside the `.minecraft/` Directory in which all three folders (`shaderpacks/`, `mods/` and `ressourcepacks/`) will be backed up. Once that's done the Installer will download the ressources in parallel and save them in the correct directories.

![CavesNCliffs Installer Architecture](https://user-images.githubusercontent.com/59741989/131248076-cee6270b-7046-4615-97d4-75921a26a6b4.png)
