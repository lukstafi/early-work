#!/bin/sh
mv LuaVehicle.cpp ../$1/src/
mv LuaVehicle.h ../$1/include/OpenSteer/
mv lua-release.sh ../$1/
mv *.lua ../$1/plugins/
mv Lua* ../$1/plugins/
