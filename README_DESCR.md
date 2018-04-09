# About the files in this directory.

## content/
	Content contains ppc files, the game uses as resources.

### What's ppc?
PPC is the content format of libpp and the polyplex engine.

This game is written in D using libpp.

ppc files contains a header descriping a bit about the creator and content, then content data.

check https://github.com/PolyplexEngine/libppc for more info, and a library to open these files.

## shaders/

Shaders that are compiled directly into the executable are placed here, loaded with the `import("(file)");` call.

## libs/

The libraries (SDL) the game depends on to run.

## source/

The source code of the game, have fun digging around, lol.
