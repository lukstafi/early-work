#!/bin/sh
cp ./src/LuaVehicle.cpp ../../luasteer/
cp ./plugins/Lua* ../../luasteer/
cp ./plugins/*.lua ../../luasteer/
cp ./include/OpenSteer/LuaVehicle.h ../../luasteer/
cp ./lua-release.sh ../../luasteer/
tar -cvzf ../luasteer.tar.gz ../../luasteer