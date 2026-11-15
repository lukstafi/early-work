# Luasteer (2007)

Lua bindings for [OpenSteer](https://opensteer.sourceforge.net/), Craig Reynolds's C++ library of steering behaviours. In the words of the file header: "OpenSteer bindings for Lua, hand-crafted, far from complete."

## Background

The bindings were written in March 2007 for a course on intelligent agents at the Institute of Computer Science, University of Wrocław, whose project proposals had students program formations of boids in OpenSteer. With the bindings, an agent's behaviour is a Lua script and needs no C++.

They were announced on the OpenSteer forum on 14 March 2007 and offered to the project: <https://sourceforge.net/p/opensteer/discussion/264792/thread/e9110c6f/>. Craig Reynolds replied there; the bindings were not taken into OpenSteer. The course's page with install instructions survives in the Wayback Machine: <http://web.archive.org/web/20090322210611/http://www.ii.uni.wroc.pl:80/~lukstafi/pmwiki/index.php?n=Agents.OpenSteer>.

## What is here

- `LuaVehicle.h`, `LuaVehicle.cpp`: the bindings. A vehicle's behaviour is a Lua script that returns a steering force each step; vectors, pursuit, seeking, separation and neighbour queries are exposed to Lua.
- `LuaSoccer.cpp` with `soccerTeam*.lua`: a soccer demo in which each team is a Lua script.
- `LuaBoids.cpp`, `LuaPedestrian.cpp`, `LuaMapDrive.cpp`: OpenSteer's plug-ins by Craig Reynolds, adapted to run their agents from Lua, with `BoidScript.lua`, `PedestrianScript.lua` and `MapDriveScript.lua`. `BoidScript.lua` adds mailbox and broadcast messaging between boids; `BoidScript-orig.lua` is the plain version.
- `lua-install.sh`, `lua-release.sh`: copy the files into an OpenSteer source tree.

A known bug, from the header of `LuaVehicle.h`: unary minus on a vector receives spurious arguments; multiply by -1 instead.

## Licences

Everything in this folder is under the MIT licence in `LICENSE`, the Lua scripts included. The C++ files also carry the notice in their headers, which is the one OpenSteer uses. The bindings and the soccer plug-in are copyright 2007 Lukasz Stafiniak. The adapted plug-ins are copyright Sony Computer Entertainment America, original author Craig Reynolds.
