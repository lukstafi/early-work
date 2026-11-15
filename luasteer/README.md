# Luasteer (2007)

Lua bindings for [OpenSteer](https://opensteer.sourceforge.net/), Craig Reynolds's C++ library of steering behaviours. In the words of the file header: "OpenSteer bindings for Lua, hand-crafted, far from complete."

## What is here

- `LuaVehicle.h`, `LuaVehicle.cpp`: the bindings. A vehicle's behaviour is a Lua script that returns a steering force each step; vectors, pursuit, seeking, separation and neighbour queries are exposed to Lua.
- `LuaSoccer.cpp` with `soccerTeam*.lua`: a soccer demo in which each team is a Lua script.
- `LuaBoids.cpp`, `LuaPedestrian.cpp`, `LuaMapDrive.cpp`: OpenSteer's plug-ins by Craig Reynolds, adapted to run their agents from Lua, with `BoidScript.lua`, `PedestrianScript.lua` and `MapDriveScript.lua`. `BoidScript.lua` adds mailbox and broadcast messaging between boids; `BoidScript-orig.lua` is the plain version.
- `lua-install.sh`, `lua-release.sh`: copy the files into an OpenSteer source tree.

A known bug, from the header of `LuaVehicle.h`: unary minus on a vector receives spurious arguments; multiply by -1 instead.

## Licences

All C++ files carry the MIT-style notice used by OpenSteer. The bindings and the soccer plug-in are copyright 2007 Lukasz Stafiniak. The adapted plug-ins are copyright Sony Computer Entertainment America, original author Craig Reynolds.
