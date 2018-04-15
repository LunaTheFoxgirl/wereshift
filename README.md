# wereshift
Submission for Linux Game Jam 2018 (Work in progress)

You are a werewolf, awooo!
Survive as many nights as you can in this semi-stealth game about being a werewolf, lusting for blood.

# Building
To build wereshift you will need DLang 2. Fetch it from the DLang website if you haven't already.

Clone the repo, and run `dub`.

dub will automatically fetch depedencies for the project.

If you want to specify a custom build of SDL, create a folder called libs, inside libs make a folder with the id of your architecture (amd64, i386, arm64 and arm are supported ids), inside that put your .so/.dylib/etc.

Please note, if you are using free/openbsd, you will have to name the file libSDL2-free(or open)bsd.so.

On windows it's called SDL2.dll, on linux libSDL2.dll and on macOs libSDL2.dylib

# Troubleshooting
If you get this error:
```
Failed to load one or more shared libraries:
    libs/amd64/libSDL2.so - libsndio.so.6.1: cannot open shared object file: No such file or directory
```
try either: installing the libsdl2 dependencies
OR: remove the libs folder (if you are running arch linux or the like)

If the game still doesn't work, please create an git issue. I (clipsey) will look in to it asap.

# Controls
L/R Arrow = Move
Down Arrow = Crouch
Down Arrow (at bush) = Hide in bush
Hold Down Arrow = Transform
Spacebar = jump
Spacebar + Arrow = Jump/attack

Survive as many nights as you can, archers will damage 10 damage extra every night. So in later nights stealth is a must.

# Forms
## Wolf
The wolf runs fast, and is very maneuvrable, but its speed during jumping is not optimal for crowd control
## Werewolf
Can dash through enemies.
## Human
Stealth form, villagers (unless they've seen you transform) will not bother you while human.

# Credits
## Programming
 * Clipsey

## Art
 * Sean "Shramper" Browning

## Sound
 * There's no sound :c


### For more indepth description of folder structure, check README_DESCR.md
