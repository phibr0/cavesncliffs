import { Manifest } from './types';
import fetch from "node-fetch";

export default class CavesNCliffsInstaller {
    public async main(): Promise<void> {
        const manifest = await this.getManifest();
        console.log(manifest);
    }

    async getManifest(): Promise<Manifest> {
        const response = await fetch("https://raw.githubusercontent.com/phibr0/cavesncliffs/main/manifest.json?token=AOHZOJOFLDD6TJPVKVADV4DBFIG26");
        return await response.json() as Manifest;
    }
}
