export interface Manifest {
    currentVersion: string,
    ressources: {
        [resourceIndex: string]: Ressource,
    }
}

export interface Ressource {
    mods: string[],
    shaders: string[],
    textures: string[],
}