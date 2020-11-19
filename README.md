![](https://github.com/Technohacker/godot_piskel_importer/raw/master/icon.png "Logo")

# Godot Piskel Importer

Imports `.piskel` files from [Piskel](https://piskelapp.com/) to [Godot](https://godotengine.org/) without requiring an export for quicker changes in Godot

## Status

All layers are overlaid into one image (layer opacity not supported yet) as a `1xN` StreamTexture PNG with the 2D Pixel Texture preset

## Usage

Download the repository, extract to the root of your project and enable the plugin. Drag and drop `.piskel` files to any parameter that takes a `Texure`
