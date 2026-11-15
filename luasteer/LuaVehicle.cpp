// ----------------------------------------------------------------------------
//
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//
// ----------------------------------------------------------------------------
//
// OpenSteer bindings for Lua, hand-crafted, far from complete
// Copyright 2007 by Lukasz Stafiniak
//
// ----------------------------------------------------------------------------

#include <lua.hpp>
#include "OpenSteer/LuaVehicle.h"
#include "OpenSteer/AbstractVehicle.h"
#include "OpenSteer/Proximity.h"
#include "OpenSteer/Utilities.h"
#include "OpenSteer/Annotation.h"
#include <assert.h>
#include <string.h>
#include <sys/stat.h>
#include <cmath>

#include <iostream>

// #include <iomanip>
// #include <sstream>
// #include <iostream>

using namespace OpenSteer;


///Embedding of Lua

bool OpenSteer::lua_isVec3 (lua_State *L, int index) {
  if (!lua_isuserdata (L, index)) return false;
  if (!lua_getmetatable (L, index)) return false;
  lua_pushstring (L, "OpenSteer_type");
  lua_rawget (L, -2);
  if (!lua_isstring (L, -1)) {
    lua_pop (L, 2);
    return false;
  }
  const char *typname = lua_tostring (L, -1);
  if (strcmp (typname, "Vec3") != 0) {
    lua_pop (L, 2);
    return false;
  }
  lua_pop (L, 2);
  Vec3 vec = *(Vec3 *) lua_touserdata (L, index);
  if (!(finite(vec.x) &&
	finite(vec.y) &&
	finite(vec.z)))
      return false;
  return true;
}
  
bool OpenSteer::lua_isColor (lua_State *L, int index) {
  if (!lua_isuserdata (L, index)) return false;
  if (!lua_getmetatable (L, index)) return false;
  lua_pushstring (L, "OpenSteer_type");
  lua_rawget (L, -2);
  if (!lua_isstring (L, -1)) {
    lua_pop (L, 2);
    return false;
  }
  const char *typname = lua_tostring (L, -1);
  if (strcmp (typname, "Color") != 0) {
    lua_pop (L, 2);
    return false;
  }
  lua_pop (L, 2);
  Color vec = *(Color *) lua_touserdata (L, index);
  if (!(finite(vec.r ()) &&
	finite(vec.g ()) &&
	finite(vec.b ()) &&
	finite(vec.a ())))
      return false;
  return true;
}
  
bool OpenSteer::lua_isVehicle (lua_State *L, int index) {
  if (!lua_isuserdata (L, index)) return false;
  if (!lua_getmetatable (L, index)) return false;
  lua_pushstring (L, "OpenSteer_type");
  lua_rawget (L, -2);
  if (!lua_isstring (L, -1)) {
    lua_pop (L, 2);
    return false;
  }
  const char *typname = lua_tostring (L, -1);
  if (strcmp (typname, "Vehicle") != 0
      && strcmp (typname, "LuaVehicle") != 0) {
    lua_pop (L, 2);
    return false;
  }
  lua_pop (L, 2);
  return true;
}
  
bool OpenSteer::lua_isLuaVehicle (lua_State *L, int index) {
  if (!lua_isuserdata (L, index)) return false;
  if (!lua_getmetatable (L, index)) return false;
  lua_pushstring (L, "OpenSteer_type");
  lua_rawget (L, -2);
  if (!lua_isstring (L, -1)) {
    lua_pop (L, 2);
    return false;
  }
  const char *typname = lua_tostring (L, -1);
  if (strcmp (typname, "LuaVehicle") != 0) {
    lua_pop (L, 2);
    return false;
  }
  lua_pop (L, 2);
  return true;
}

bool OpenSteer::lua_isBool (lua_State *L, int index) {
    return lua_isboolean (L, index);
}

bool OpenSteer::lua_isAVGroup (lua_State *L, int index) {
  if (!lua_isuserdata (L, index)) return false;
  if (!lua_getmetatable (L, index)) return false;
  lua_pushstring (L, "OpenSteer_type");
  lua_rawget (L, -2);
  if (!lua_isstring (L, -1)) {
    lua_pop (L, 2);
    return false;
  }
  const char *typname = lua_tostring (L, -1);
  if (strcmp (typname, "AVGroup") != 0) {
    lua_pop (L, 2);
    return false;
  }
  lua_pop (L, 2);
  return true;
}

bool OpenSteer::lua_isObstacles (lua_State *L, int index) {
  if (!lua_isuserdata (L, index)) return false;
  if (!lua_getmetatable (L, index)) return false;
  lua_pushstring (L, "OpenSteer_type");
  lua_rawget (L, -2);
  if (!lua_isstring (L, -1)) {
    lua_pop (L, 2);
    return false;
  }
  const char *typname = lua_tostring (L, -1);
  if (strcmp (typname, "Obstacles") != 0) {
    lua_pop (L, 2);
    return false;
  }
  lua_pop (L, 2);
  return true;
}

bool OpenSteer::lua_isPathway (lua_State *L, int index) {
  if (!lua_isuserdata (L, index)) return false;
  if (!lua_getmetatable (L, index)) return false;
  lua_pushstring (L, "OpenSteer_type");
  lua_rawget (L, -2);
  if (!lua_isstring (L, -1)) {
    lua_pop (L, 2);
    return false;
  }
  const char *typname = lua_tostring (L, -1);
  if (strcmp (typname, "Pathway") != 0) {
    lua_pop (L, 2);
    return false;
  }
  lua_pop (L, 2);
  return true;
}
  
const char *OpenSteer::lua_getArgType (lua_State *L, int index) {
  int n = lua_gettop (L);
  if (lua_isnil (L, index)) return "nil";
  if (lua_isboolean (L, index)) return "boolean";
  if (lua_isnumber (L, index)) return "number";
  if (lua_isstring (L, index)) return "string";
  if (lua_istable (L, index)) {
    lua_pushstring (L, "OpenSteer_type");
    lua_rawget (L, index);
    if (!lua_isstring (L, -1)) {
      lua_pop (L, 1);
      return "table";
    }
    const char *typname = lua_tostring (L, -1);
    if (!typname) {
      lua_pop (L, 1);
      return "userdata OpenSteer internal error";
    }
    lua_pop (L, 1);
    assert (n == lua_gettop (L));
    return typname;
  }
  if (lua_isfunction (L, index)) return "function";
  if (lua_iscfunction (L, index)) return "C function";
  if (lua_isuserdata (L, index)) {
    if (!lua_getmetatable (L, index))
      return "userdata (no metatable)";
    lua_pushstring (L, "OpenSteer_type");
    lua_rawget (L, -2);
    if (!lua_isstring (L, -1)) {
      lua_pop (L, 2);
      return "userdata (not OpenSteer)";
    }
    const char *typname = lua_tostring (L, -1);
    if (!typname) {
      lua_pop (L, 2);
      return "userdata OpenSteer internal error";
    }
    lua_pop (L, 2);
    assert (n == lua_gettop (L));
    if (strcmp (typname, "Vec3") == 0) {
	Vec3 vec = *(Vec3 *) lua_touserdata (L, index);
	if (!(finite(vec.x) &&
	      finite(vec.y) &&
	      finite(vec.z)))
	    return "bad Vec3 (NaN or inf)";
    }
    if (strcmp (typname, "Color") == 0) {
	Color col = *(Color *) lua_touserdata (L, index);
	if (!(finite(col.r ()) &&
	      finite(col.g ()) &&
	      finite(col.b ()) &&
	      finite(col.a ())))
	    return "bad Color (NaN or inf)";
    }
    return typname;
  }
  return "unknown type";
}

static int lua_printType (lua_State *L) {
  fprintf (stderr, "Type of %s: %s\n", lua_tostring (L, 1),
	   lua_getArgType (L, 2));
  lua_pop (L, 2);
  assert (lua_gettop (L) == 0);
  return 0;
}

void OpenSteer::lua_checkargs (lua_State *L, int numargs,
			  const lua_istype *checktype,
			  const char **tyname,
			  const char *fname) {
  int n = lua_gettop (L);
  if (n != numargs) {
    lua_Debug ar;
    if (!lua_getstack (L, 1, &ar) || !lua_getinfo (L, "Sl", &ar)) {
	lua_pushfstring (L, "error: debug info failed (at numargs of %s)", fname);
      lua_error(L);
    }
    lua_pushfstring
	(L, "%s:%d: error: incorrect number of arguments to function ‘%s’ (expected %d, got %d)",
	 (ar.source + 1), ar.currentline, fname, numargs, n);
    lua_error(L);
  }
  for (int i = 1; i <= numargs; i++) {
      if (!(checktype[i-1]) (L,i)) {
	  lua_Debug ar;
	  if (!lua_getstack (L, 1, &ar) || !lua_getinfo (L, "Sl", &ar)) {
	      lua_pushfstring (L, "error: debug info failed (at checktype #%d of %s)", i, fname);
	      lua_error(L);
	  }
	  const char *ty = lua_getArgType (L, i);
	  lua_pushfstring
	      (L, "%s:%d: error: incorrect argument #%d to function ‘%s’ (expected %s, got %s)",
	       (ar.source + 1), ar.currentline, i, fname, tyname[i-1], ty);
	  lua_error(L);
      }
  }
}

void OpenSteer::lua_pushVec3 (lua_State *L, Vec3 vec) {
  lua_newuserdata (L, sizeof(Vec3));
  Vec3 * p = (Vec3*) lua_touserdata (L, -1);
  (*p) = vec;
  lua_getglobal (L, "Vec3_metatable");
  if (!lua_istable (L, -1)) {
    fprintf (stderr, "Error in `lua_pushVec3': no metatable\n");
    exit (-1);
  }
  if (!lua_setmetatable (L, -2)) {
    fprintf (stderr, "Error in `lua_pushVec3'");
    exit (1);
  }
}

void OpenSteer::lua_pushColor (lua_State *L, Color col) {
  lua_newuserdata (L, sizeof(Color));
  Color * p = (Color*) lua_touserdata (L, -1);
  (*p) = col;
  lua_getglobal (L, "Color_metatable");
  if (!lua_istable (L, -1)) {
    fprintf (stderr, "Error in `lua_pushColor': no metatable\n");
    exit (-1);
  }
  if (!lua_setmetatable (L, -2)) {
    fprintf (stderr, "Error in `lua_pushColor'");
    exit (1);
  }
}


Vec3 OpenSteer::lua_toVec3 (lua_State *L, int index)
{
  if (!lua_isVec3 (L, index)) {
    fprintf (stderr, "Error in `lua_toVec3': wrong type\n");
    exit (1);
  }
  return *((Vec3*) lua_touserdata (L, index));
}

Color OpenSteer::lua_toColor (lua_State *L, int index)
{
  if (!lua_isColor (L, index)) {
    fprintf (stderr, "Error in `lua_toColor': wrong type\n");
    exit (1);
  }
  return *((Color*) lua_touserdata (L, index));
}
    

static int addVec (lua_State *L)
{
    lua_istype checktype[2] = {lua_isVec3, lua_isVec3};
    const char *tyname[2] = {"Vec3", "Vec3"};
    lua_checkargs (L, 2, checktype, tyname, "addVec");

   Vec3 *vec1 = (Vec3*) lua_touserdata (L, 1);
   Vec3 *vec2 = (Vec3*) lua_touserdata (L, 2);
   Vec3 res = (*vec1) + (*vec2);
   lua_pop (L, 2);
   lua_pushVec3 (L, res);

   assert (lua_gettop (L) == 1);
   return 1;
}

static int subVec (lua_State *L)
{
    lua_istype checktype[2] = {lua_isVec3, lua_isVec3};
    const char *tyname[2] = {"Vec3", "Vec3"};
    lua_checkargs (L, 2, checktype, tyname, "addVec");

   Vec3 *vec1 = (Vec3*) lua_touserdata (L, 1);
   Vec3 *vec2 = (Vec3*) lua_touserdata (L, 2);
   Vec3 res = (*vec1) - (*vec2);
   lua_pop (L, 2);
   lua_pushVec3 (L, res);

   assert (lua_gettop (L) == 1);
   return 1;
}

static int mulVec (lua_State *L)
{
    lua_istype checktype[2] = {(lua_istype) lua_isnumber, lua_isVec3};
    const char *tyname[2] = {"number", "Vec3"};
    lua_checkargs (L, 2, checktype, tyname, "mulVec");

   lua_Number mul = lua_tonumber (L, 1);
   Vec3 *vec = (Vec3*) lua_touserdata (L, 2);
   Vec3 res = mul * (*vec);
   lua_pop (L, 2);
   lua_pushVec3 (L, res);

   assert (lua_gettop (L) == 1);
   return 1;
}

static int mul2Vec (lua_State *L)
{
    lua_istype checktype[2] = {lua_isVec3, (lua_istype) lua_isnumber};
    const char *tyname[2] = {"Vec3", "number"};
    lua_checkargs (L, 2, checktype, tyname, "mulVec");

   lua_Number mul = lua_tonumber (L, 2);
   Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
   Vec3 res = mul * (*vec);
   lua_pop (L, 2);
   lua_pushVec3 (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}


static int mulColor (lua_State *L)
{
    lua_istype checktype[2] = {(lua_istype) lua_isnumber, lua_isColor};
    const char *tyname[2] = {"number", "Color"};
    lua_checkargs (L, 2, checktype, tyname, "mulColor");

   lua_Number mul = lua_tonumber (L, 1);
   Color *vec = (Color*) lua_touserdata (L, 2);
   Color res = mul * (*vec);
   lua_pop (L, 2);
   lua_pushColor (L, res);

   assert (lua_gettop (L) == 1);
   return 1;
}

static int mul2Color (lua_State *L)
{
    lua_istype checktype[2] = {lua_isColor, (lua_istype) lua_isnumber};
    const char *tyname[2] = {"Color", "number"};
    lua_checkargs (L, 2, checktype, tyname, "mulColor");

   lua_Number mul = lua_tonumber (L, 2);
   Color *vec = (Color*) lua_touserdata (L, 1);
   Color res = mul * (*vec);
   lua_pop (L, 2);
   lua_pushColor (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static int divVec (lua_State *L)
{
    lua_istype checktype[2] = {lua_isVec3, (lua_istype) lua_isnumber};
    const char *tyname[2] = {"Vec3", "number"};
    lua_checkargs (L, 2, checktype, tyname, "mulVec");

   lua_Number mul = lua_tonumber (L, 2);
   Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
   Vec3 res = (*vec) / mul;
   lua_pop (L, 2);
   lua_pushVec3 (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static int unmVec (lua_State *L)
{
    lua_istype checktype[1] = {lua_isVec3};
    const char *tyname[1] = {"Vec3"};

    std::cerr << "unmVec: " << lua_getArgType (L, 1); //DEBUG
    if (lua_gettop (L) > 1) std::cerr << ", " << lua_getArgType (L, 2);
    std::cerr << std::endl;

    lua_checkargs (L, 1, checktype, tyname, "unmVec");

   Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
   Vec3 res = -(*vec);
   lua_pop (L, 2);
   lua_pushVec3 (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static int lua_randomVectorOnUnitRadiusXZDisk (lua_State *L)
{
    lua_checkargs (L, 0, NULL, NULL, "randomVectorOnUnitRadiusXZDisk");
    lua_pushVec3 (L, randomVectorOnUnitRadiusXZDisk ());

    assert (lua_gettop (L) == 1);
    return 1;
}

static int dotVec (lua_State *L)
{
    lua_istype checktype[2] = {lua_isVec3, lua_isVec3};
    const char *tyname[2] = {"Vec3", "Vec3"};
    lua_checkargs (L, 2, checktype, tyname, "dotVec");

   Vec3 *vec1 = (Vec3*) lua_touserdata (L, 1);
   Vec3 *vec2 = (Vec3*) lua_touserdata (L, 2);
   float res = vec1->dot (*vec2);
   lua_pop (L, 2);
   lua_pushnumber (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static int muldotVec (lua_State *L)
{
  if (lua_isnumber (L,1)) return mulVec (L);
  else if (lua_isnumber (L,2)) return mul2Vec (L);
  else return dotVec (L);
}

static int muldotColor (lua_State *L)
{
  if (lua_isnumber (L,1)) return mulColor (L);
  else return mul2Color (L);
}

static int distVec (lua_State *L)
{
    lua_istype checktype[2] = {lua_isVec3, lua_isVec3};
    const char *tyname[2] = {"Vec3", "Vec3"};
    lua_checkargs (L, 2, checktype, tyname, "distVec");

   Vec3 *vec1 = (Vec3*) lua_touserdata (L, 1);
   Vec3 *vec2 = (Vec3*) lua_touserdata (L, 2);
   float res = Vec3::distance (*vec1, *vec2);
   lua_pop (L, 2);
   lua_pushnumber (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static int crossVec (lua_State *L)
{
    lua_istype checktype[2] = {lua_isVec3, lua_isVec3};
    const char *tyname[2] = {"Vec3", "Vec3"};
    lua_checkargs (L, 2, checktype, tyname, "crossVec");

   Vec3 *vec1 = (Vec3*) lua_touserdata (L, 1);
   Vec3 *vec2 = (Vec3*) lua_touserdata (L, 2);
   Vec3 res;
   res.cross (*vec1, *vec2);
   lua_pop (L, 2);
   lua_pushVec3 (L, res);
   //`cross' is really self-assignment: A x= B.
   //XXX: when `cross' becomes a normal operator, modify this
  assert (lua_gettop (L) == 1);
   return 1;
}

static int lenVec (lua_State *L)
{
    lua_istype checktype[1] = {lua_isVec3};
    const char *tyname[1] = {"Vec3"};
    lua_checkargs (L, 1, checktype, tyname, "lenVec");

   Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
   float res = vec->length ();
   lua_pop (L, 1);
   lua_pushnumber (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static int xVec (lua_State *L)
{
    lua_istype checktype[1] = {lua_isVec3};
    const char *tyname[1] = {"Vec3"};
    lua_checkargs (L, 1, checktype, tyname, "xVec");

   Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
   float res = vec->x;
   lua_pop (L, 1);
   lua_pushnumber (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static int yVec (lua_State *L)
{
    lua_istype checktype[1] = {lua_isVec3};
    const char *tyname[1] = {"Vec3"};
    lua_checkargs (L, 1, checktype, tyname, "yVec");

   Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
   float res = vec->y;
   lua_pop (L, 1);
   lua_pushnumber (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static int zVec (lua_State *L)
{
    lua_istype checktype[1] = {lua_isVec3};
    const char *tyname[1] = {"Vec3"};
    lua_checkargs (L, 1, checktype, tyname, "zVec");

   Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
   float res = vec->z;
   lua_pop (L, 1);
   lua_pushnumber (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static int nonzeroVec (lua_State *L)
{
    lua_istype checktype[1] = {lua_isVec3};
    const char *tyname[1] = {"Vec3"};
    lua_checkargs (L, 1, checktype, tyname, "nonzeroVec");

   Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
   bool res = (*vec) != Vec3::zero;
   lua_pop (L, 1);

   lua_pushboolean (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static float eps = 0.00001;

static int eqVec (lua_State *L)
{
    lua_istype checktype[2] = {lua_isVec3, lua_isVec3};
    const char *tyname[2] = {"Vec3", "Vec3"};
    lua_checkargs (L, 2, checktype, tyname, "eqVec");
    Vec3 *vec1 = (Vec3*) lua_touserdata (L, 1);
    Vec3 *vec2 = (Vec3*) lua_touserdata (L, 2);
    bool res =
      fabs ((*vec1).x - (*vec2).x) < eps &&
      fabs ((*vec1).y - (*vec2).y) < eps &&
      fabs ((*vec1).z - (*vec2).z) < eps;
    lua_pop (L, 2);
    lua_pushboolean (L, res);
  assert (lua_gettop (L) == 1);
    return 1;
}

static int normVec (lua_State *L)
{
    lua_istype checktype[1] = {lua_isVec3};
    const char *tyname[1] = {"Vec3"};
    lua_checkargs (L, 1, checktype, tyname, "normalize");

   Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
   Vec3 res = vec->normalize ();
   lua_pop (L, 1);
   lua_pushVec3 (L, res);
  assert (lua_gettop (L) == 1);
   return 1;
}

static int consVec (lua_State *L)
{
    lua_istype checktype[3] = {(lua_istype) lua_isnumber,
			       (lua_istype) lua_isnumber,
			       (lua_istype) lua_isnumber};
    const char *tyname[3] = {"number", "number", "number"};
    lua_checkargs (L, 3, checktype, tyname, "Vec3");

   lua_Number x = lua_tonumber (L, 1);
   lua_Number y = lua_tonumber (L, 2);
   lua_Number z = lua_tonumber (L, 3);
   lua_pop (L, 3);
   Vec3 res(x, y, z);
   lua_pushVec3 (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static int consColor (lua_State *L)
{
    lua_istype checktype[3] = {(lua_istype) lua_isnumber,
			       (lua_istype) lua_isnumber,
			       (lua_istype) lua_isnumber};
    const char *tyname[3] = {"number", "number", "number"};
    lua_checkargs (L, 3, checktype, tyname, "Color");

   lua_Number x = lua_tonumber (L, 1);
   lua_Number y = lua_tonumber (L, 2);
   lua_Number z = lua_tonumber (L, 3);
   lua_pop (L, 3);
   Color res(x, y, z);
   lua_pushColor (L, res);

  assert (lua_gettop (L) == 1);
   return 1;
}

static AVGroup *lua_toAVGroup (lua_State *L, int index) {
  if (!lua_isAVGroup (L, index)) {
    fprintf (stderr, "Error in `lua_toAVGroup': wrong type\n");
    exit (1);
  }
  AVGroup **ref = (AVGroup **)
    lua_touserdata (L, index);
  return *ref;
}

static ObstacleGroup *lua_toObstacles (lua_State *L, int index) {
  if (!lua_isObstacles (L, index)) {
    fprintf (stderr, "Error in `lua_toObstacles': wrong type\n");
    exit (1);
  }
  ObstacleGroup **ref = (ObstacleGroup **)
    lua_touserdata (L, index);
  return *ref;
}

SegmentedPathway *OpenSteer::lua_toPathway (lua_State *L, int index) {
  if (!lua_isPathway (L, index)) {
    fprintf (stderr, "Error in `lua_toPathway': wrong type\n");
    exit (1);
  }
  SegmentedPathway **ref = (SegmentedPathway **)
    lua_touserdata (L, index);
  return *ref;
}

static int lua_finalizeAVGroup (lua_State *L) {
  AVGroup *avg = lua_toAVGroup (L, 1);
  delete avg;
  lua_pop (L, 1);

  return 0;
}

static AbstractVehicle *lua_toVehicle (lua_State *L, int index) {
  AbstractVehicle **ref = (AbstractVehicle **)
    lua_touserdata (L, index);
  return *ref;
}

LuaVehicle *OpenSteer::lua_toLuaVehicle (lua_State *L, int index) {
  LuaVehicle **ref = (LuaVehicle **)
    lua_touserdata (L, index);
  return *ref;
}


static AVGroup *lua_newAVGroup (lua_State *L) {
  AVGroup **ref = (AVGroup **)
    lua_newuserdata (L, sizeof (AVGroup*));
  *ref = new AVGroup;
  lua_getglobal (L, "full_AVGroup_metatable");
  if (!lua_istable (L, -1)) {
    fprintf (stderr, "Error in `lua_newAVGroup': no metatable\n");
    exit (1);
  }
  if (!lua_setmetatable (L, -2)) {
    fprintf (stderr, "Error in `lua_newAVGroup'");
    exit (1);
  }
  return *ref;
}

static int lua_new_AVGroup (lua_State *L) {
  lua_newAVGroup (L);
  assert (lua_gettop (L) == LUABASE(1));
  return 1;
}

bool OpenSteer::lua_isLuaFunction (lua_State *L, int index) {
    return lua_type (L, index) == LUA_TFUNCTION;
}

static int lua_foreachVehicle (lua_State *L) {
    lua_istype checktype[2] = {lua_isAVGroup, (lua_istype) lua_isLuaFunction};
    const char *tyname[2] = {"AVGroup", "function"};
    lua_checkargs (L, 2, checktype, tyname, "foreach_vehicle");

    AVGroup *others = lua_toAVGroup (L, 1);

    for (AVIterator i = others->begin(); i != others->end(); i++)
    {
	lua_pushvalue (L, 2);
	// FIXME: type control NEEDED here
        lua_LuaVehicleSnapshot (L, (LuaVehicle*) *i);
	lua_call (L, 1, 0);
    }
    lua_pop (L, 2);
    return 0;
}

static int lua_findNeighbors (lua_State *L) {
    lua_istype checktype[2] = {lua_isVec3, (lua_istype) lua_isnumber};
    const char *tyname[2] = {"Vec3", "number"};
    lua_checkargs (L, 2, checktype, tyname, "findNeighbors");

  Vec3 vec = *((Vec3*) lua_touserdata (L, 1));
  lua_Number radius = lua_tonumber (L, 2);
  ProximityToken *proxy = ((ProximityToken*)
			 lua_touserdata (L, lua_upvalueindex (1)));
  lua_pop (L, 2);

  AVGroup *neighbors = lua_newAVGroup (L);
  
  proxy->findNeighbors (vec, radius, *neighbors);

  assert (lua_gettop (L) == 1);
  return 1;
}  

void OpenSteer::lua_pushAVGroup (lua_State *L, AVGroup *avgroup) {
  AVGroup **ref = (AVGroup **)
    lua_newuserdata (L, sizeof (AVGroup*));
  *ref = avgroup;
  lua_getglobal (L, "light_AVGroup_metatable");
  if (!lua_istable (L, -1)) {
    fprintf (stderr, "Error in `lua_pushAVGroup': no metatable\n");
    exit (1);
  }
  if (!lua_setmetatable (L, -2)) {
    fprintf (stderr, "Error in `lua_pushAVGroup'");
    exit (1);
  }
}

void OpenSteer::lua_pushObstacles (lua_State *L, ObstacleGroup *obstacles) {
  ObstacleGroup **ref = (ObstacleGroup **)
    lua_newuserdata (L, sizeof (ObstacleGroup*));
  *ref = obstacles;
  lua_getglobal (L, "Obstacles_metatable");
  if (!lua_istable (L, -1)) {
    fprintf (stderr, "Error in `lua_pushObstacles': no metatable\n");
    exit (1);
  }
  if (!lua_setmetatable (L, -2)) {
    fprintf (stderr, "Error in `lua_pushObstacles'");
    exit (1);
  }
}

void OpenSteer::lua_pushPathway (lua_State *L, SegmentedPathway *pathway) {
  SegmentedPathway **ref = (SegmentedPathway **)
    lua_newuserdata (L, sizeof (SegmentedPathway*));
  *ref = pathway;
  lua_getglobal (L, "light_Pathway_metatable");
  if (!lua_istable (L, -1)) {
    fprintf (stderr, "Error in `lua_pushPathway': no metatable\n");
    exit (1);
  }
  if (!lua_setmetatable (L, -2)) {
    fprintf (stderr, "Error in `lua_pushPathway'");
    exit (1);
  }
}

void OpenSteer::lua_pushVehicle (lua_State *L, AbstractVehicle *vehicle) {
  AbstractVehicle **ref = (AbstractVehicle **)
    lua_newuserdata (L, sizeof (AbstractVehicle*));
  *ref = vehicle;
  lua_getglobal (L, "Vehicle_metatable");
  if (!lua_istable (L, -1)) {
    fprintf (stderr, "Error in `lua_pushVehicle': no metatable\n");
    exit (1);
  }
  if (!lua_setmetatable (L, -2)) {
    fprintf (stderr, "Error in `lua_pushVehicle'");
    exit (1);
  }
}

void lua_pushLuaVehicle (lua_State *L, LuaVehicle *vehicle) {
  LuaVehicle **ref = (LuaVehicle **)
    lua_newuserdata (L, sizeof (LuaVehicle*));
  *ref = vehicle;
  lua_getglobal (L, "LuaVehicle_metatable");
  if (!lua_istable (L, -1)) {
    fprintf (stderr, "Error in `LuaVehicle::lua_push': no metatable\n");
    exit (1);
  }
  if (!lua_setmetatable (L, -2)) {
    fprintf (stderr, "Error in `LuaVehicle::lua_push'");
    exit (1);
  }
}

void LuaVehicle::lua_push () {
  LuaVehicle **ref = (LuaVehicle **)
    lua_newuserdata (L, sizeof (LuaVehicle*));
  *ref = this;
  lua_getglobal (L, "LuaVehicle_metatable");
  if (!lua_istable (L, -1)) {
    fprintf (stderr, "Error in `LuaVehicle::lua_push': no metatable\n");
    exit (1);
  }
  if (!lua_setmetatable (L, -2)) {
    fprintf (stderr, "Error in `LuaVehicle::lua_push'");
    exit (1);
  }
}

static int lua_findNeighborsImp (lua_State *L) {
    lua_istype checktype[3] = {lua_isVec3, (lua_istype) lua_isnumber, lua_isAVGroup};
    const char *tyname[3] = {"Vec3", "number", "AVGroup"};
    lua_checkargs (L, 3, checktype, tyname, "findNeighborsImp");
  Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
  lua_Number radius = lua_tonumber (L, 2);
  AVGroup *neighbors = lua_toAVGroup (L, 3);
  neighbors->clear();
  ProximityToken *proxy = ((ProximityToken*)
			 lua_touserdata (L, lua_upvalueindex (1)));
  lua_pop (L, 3);
  proxy->findNeighbors (*vec, radius, *neighbors);
 
  assert (lua_gettop (L) == 0);
  return 0;
}  


static int lua_steerToAvoidNeighbors (lua_State *L) {
    lua_istype checktype[2] = {(lua_istype) lua_isnumber, lua_isAVGroup};
    const char *tyname[2] = {"number", "AVGroup"};
    lua_checkargs (L, 2, checktype, tyname, "steerToAvoidNeighbors");
  
  lua_Number minTimeToCollision = lua_tonumber (L, 1);
  AVGroup *others = lua_toAVGroup (L, 2);
  LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
  lua_pop (L, 2);
  lua_pushVec3 (L, thisVehicle->steerToAvoidNeighbors
		(minTimeToCollision, *others));

  assert (lua_gettop (L) == 1);
   return 1;
}

static int lua_steerToAvoidObstacles (lua_State *L) {
    lua_istype checktype[2] = {(lua_istype) lua_isnumber, lua_isObstacles};
    const char *tyname[2] = {"number", "Obstacles"};
    lua_checkargs (L, 2, checktype, tyname, "steerToAvoidNeighbors");
  
  lua_Number minTimeToCollision = lua_tonumber (L, 1);
  ObstacleGroup *obstacles = lua_toObstacles (L, 2);
  LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
  lua_pop (L, 2);
  lua_pushVec3 (L, thisVehicle->steerToAvoidObstacles
		(minTimeToCollision, *obstacles));

  assert (lua_gettop (L) == 1);
   return 1;
}

static int lua_steerForSeparation (lua_State *L) {
    lua_istype checktype[3] = {(lua_istype) lua_isnumber, (lua_istype) lua_isnumber, lua_isAVGroup};
    const char *tyname[3] = {"number", "number", "AVGroup"};
    lua_checkargs (L, 3, checktype, tyname, "steerForSeparation");
  
  lua_Number maxDistance = lua_tonumber (L, 1);
  lua_Number cosMaxAngle = lua_tonumber (L, 2);
  AVGroup *others = lua_toAVGroup (L, 3);
  LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
  lua_pop (L, 3);
  lua_pushVec3 (L, thisVehicle->steerForSeparation (maxDistance, cosMaxAngle,
						    *others));

  assert (lua_gettop (L) == 1);
   return 1;
}

static int lua_steerForAlignment (lua_State *L) {
    lua_istype checktype[3] = {(lua_istype) lua_isnumber, (lua_istype) lua_isnumber, lua_isAVGroup};
    const char *tyname[3] = {"number", "number", "AVGroup"};
    lua_checkargs (L, 3, checktype, tyname, "steerForAlignment");
  
  lua_Number maxDistance = lua_tonumber (L, 1);
  lua_Number cosMaxAngle = lua_tonumber (L, 2);
  AVGroup *others = lua_toAVGroup (L, 3);
  LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
  lua_pop (L, 3);
  lua_pushVec3 (L, thisVehicle->steerForAlignment (maxDistance, cosMaxAngle,
						   *others));

  assert (lua_gettop (L) == 1);
   return 1;
}


static int lua_steerForCohesion (lua_State *L) {
    lua_istype checktype[3] = {(lua_istype) lua_isnumber, (lua_istype) lua_isnumber, lua_isAVGroup};
    const char *tyname[3] = {"number", "number", "AVGroup"};
    lua_checkargs (L, 3, checktype, tyname, "steerForCohesion");
  
  lua_Number maxDistance = lua_tonumber (L, 1);
  lua_Number cosMaxAngle = lua_tonumber (L, 2);
  AVGroup *others = lua_toAVGroup (L, 3);
  LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
  lua_pop (L, 3);
  lua_pushVec3 (L, thisVehicle->steerForCohesion (maxDistance, cosMaxAngle,
						  *others));

  assert (lua_gettop (L) == 1);
   return 1;
}

static int lua_steerForSeek (lua_State *L) {
    lua_istype checktype[1] = {lua_isVec3};
    const char *tyname[1] = {"Vec3"};
    lua_checkargs (L, 1, checktype, tyname, "steerForSeek");
  
  Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
  LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
  Vec3 arg = *vec;
  lua_pop (L, 1);
  lua_pushVec3 (L, thisVehicle->xxxsteerForSeek (arg));

  assert (lua_gettop (L) == 1);
   return 1;
}

static int lua_steerForFlee (lua_State *L) {
    lua_istype checktype[1] = {lua_isVec3};
    const char *tyname[1] = {"Vec3"};
    lua_checkargs (L, 1, checktype, tyname, "steerForFlee");
  
  Vec3 *vec = (Vec3*) lua_touserdata (L, 1);
  LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
  Vec3 arg = *vec;
  lua_pop (L, 1);
  lua_pushVec3 (L, thisVehicle->xxxsteerForFlee (arg));

  assert (lua_gettop (L) == 1);
   return 1;
}

static int lua_steerForWander (lua_State *L) {
    lua_istype checktype[1] = {(lua_istype) lua_isnumber};
    const char *tyname[1] = {"number"};
    lua_checkargs (L, 1, checktype, tyname, "steerForWander");
  
  lua_Number dt = lua_tonumber (L, 1);
  LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
  lua_pop (L, 1);
  lua_pushVec3 (L, thisVehicle->steerForWander (dt));

  assert (lua_gettop (L) == 1);
   return 1;
}

static int lua_steerForTargetSpeed (lua_State *L) {
    lua_istype checktype[1] = {(lua_istype) lua_isnumber};
    const char *tyname[1] = {"number"};
    lua_checkargs (L, 1, checktype, tyname, "steerForTargetSpeed");
  
  lua_Number sp = lua_tonumber (L, 1);
  LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
  lua_pop (L, 1);
  lua_pushVec3 (L, thisVehicle->steerForTargetSpeed (sp));

  assert (lua_gettop (L) == 1);
   return 1;
}

static int lua_steerForPursuit (lua_State *L) {
    lua_istype checktype[1] = {lua_isVehicle};
    const char *tyname[1] = {"Vehicle"};
    lua_checkargs (L, 1, checktype, tyname, "steerForPursuit");
  
  AbstractVehicle *quarry = lua_toVehicle (L, 1);
  LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
  lua_pop (L, 1);
  lua_pushVec3 (L, thisVehicle->steerForPursuit (*quarry));

  assert (lua_gettop (L) == 1);
   return 1;
}

// static int lua_steerForEvasion (lua_State *L) {
//     lua_istype checktype[1] = {lua_isVehicle};
//     const char *tyname[1] = {"Vehicle"};
//     lua_checkargs (L, 1, checktype, tyname, "steerForEvasion");
  
//   AbstractVehicle *quarry = lua_toVehicle (L, 1);
//   LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
//   lua_pop (L, 1);
//   lua_pushVec3 (L, thisVehicle->steerForEvasion (*quarry, FLT_MAX));

//   assert (lua_gettop (L) == 1);
//    return 1;
// }


static int lua_annotationLine (lua_State *L)
{
    lua_istype checktype[3] = {lua_isVec3, lua_isVec3, lua_isColor};
    const char *tyname[3] = {"Vec3", "Vec3", "Color"};
    lua_checkargs (L, 3, checktype, tyname, "annotationLine");
    LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));

   Vec3 startPoint =  lua_toVec3 (L, 1);
   Vec3 endPoint = lua_toVec3 (L, 2);
   Color col = lua_toColor (L, 3);

   thisVehicle->annotationLine (startPoint, endPoint, col);
   lua_pop (L, 3);

  assert (lua_gettop (L) == 0);
   return 0;
}

static int lua_annotationCircleOrDisk (lua_State *L)
{
    lua_istype checktype[7] = {(lua_istype) lua_isnumber,
			       lua_isVec3, lua_isVec3, lua_isColor,
			       (lua_istype) lua_isnumber,
			       lua_isBool,
			       lua_isBool};
    const char *tyname[7] = {"number", "Vec3", "Vec3", "Color",
			     "number", "boolean", "boolean"};
    lua_checkargs (L, 7, checktype, tyname, "annotationCircleOrDisk");

    LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (1));
    float radius = lua_tonumber (L, 1);
   Vec3 axis =  lua_toVec3 (L, 2);
   Vec3 center = lua_toVec3 (L, 3);
   Color col = lua_toColor (L, 4);
   int segments = (int) lua_tonumber (L, 5);
   bool filled = lua_toboolean (L, 6);
   bool in3d = lua_toboolean (L, 7);

   thisVehicle->annotationCircleOrDisk (radius, axis, center, col,
			   segments, filled, in3d);
   lua_pop (L, 7);

  assert (lua_gettop (L) == 0);
   return 0;
}


static int lua_smoothedPosition (lua_State *L) {
    lua_istype checktype[1] = {lua_isLuaVehicle};
    const char *tyname[1] = {"LuaVehicle"};
    lua_checkargs (L, 1, checktype, tyname, "smoothedPosition");

    LuaVehicle *veh = lua_toLuaVehicle (L, 1);
    lua_pop (L, 1);
    Vec3 pos = veh->smoothedPosition ();
    lua_pushVec3 (L, pos);
    assert (lua_gettop (L) == 1);
    return 1;
}

static int lua_curvature (lua_State *L) {
    lua_istype checktype[1] = {lua_isLuaVehicle};
    const char *tyname[1] = {"LuaVehicle"};
    lua_checkargs (L, 1, checktype, tyname, "curvature");

    LuaVehicle *veh = lua_toLuaVehicle (L, 1);
    lua_pop (L, 1);
    float cur = veh->curvature ();
    lua_pushnumber (L, cur);
    assert (lua_gettop (L) == 1);
    return 1;
}

static int lua_resetSmoothedPosition (lua_State *L) {
    lua_istype checktype[2] = {lua_isLuaVehicle, lua_isVec3};
    const char *tyname[2] = {"LuaVehicle", "Vec3"};
    lua_checkargs (L, 2, checktype, tyname, "resetSmoothedPosition");

    LuaVehicle *veh = lua_toLuaVehicle (L, 1);
    Vec3 pos = lua_toVec3 (L, 2);
    lua_pop (L, 2);
    veh->resetSmoothedPosition (pos);
    assert (lua_gettop (L) == 0);    
    return 0;
}

static int lua_resetSmoothedAcceleration (lua_State *L) {
    lua_istype checktype[2] = {lua_isLuaVehicle, lua_isVec3};
    const char *tyname[2] = {"LuaVehicle", "Vec3"};
    lua_checkargs (L, 2, checktype, tyname, "resetSmoothedAcceleration");

    LuaVehicle *veh = lua_toLuaVehicle (L, 1);
    Vec3 pos = lua_toVec3 (L, 2);
    lua_pop (L, 2);
    veh->resetSmoothedAcceleration (pos);
    assert (lua_gettop (L) == 0);    
    return 0;
}


void LuaVehicle::receiveMail (const char *message)
{
    lua_getglobal (L, "table");
    lua_pushstring (L, "insert");
    lua_gettable (L, -2);
    lua_getglobal (L, "mailbox");
    lua_pushstring (L, message);
    lua_call (L, 2, 0);
    lua_pop (L, 1); // pop "table" module
}    

const char *LuaVehicle::readVariable (const char *vname)
{
    lua_getglobal (L, vname);
    if (!lua_isstring (L, -1)) return NULL;
    const char *ret = lua_tostring (L, -1);
    lua_pop (L, 1);
    return ret;
}
    

static int lua_sendMessage (lua_State *L) {
    lua_istype checktype[2] = {lua_isLuaVehicle, (lua_istype) lua_isstring};
    const char *tyname[2] = {"LuaVehicle", "string"};
    lua_checkargs (L, 2, checktype, tyname, "send_message");

    LuaVehicle *receiver = lua_toLuaVehicle (L, 1);
    const char *message = lua_tostring (L, 2);
    lua_pop (L, 2);
    receiver->receiveMail (message);
    
    return 0;
}

static int lua_receiveBroadcast (lua_State *L) {
    lua_istype checktype[1] = {lua_isLuaVehicle};
    const char *tyname[1] = {"LuaVehicle"};
    lua_checkargs (L, 1, checktype, tyname, "receive_broadcast");

    LuaVehicle *receiver = lua_toLuaVehicle (L, 1);
    lua_pop (L, 1);
    const char *message = receiver->readVariable ("broadcast");
    if (!message) lua_pushnil (L);
    else lua_pushstring (L, message);
    return 1;
}

static int lua_equality (lua_State *L)
{
    lua_istype checktype[2] = {(lua_istype) lua_isuserdata,
			       (lua_istype) lua_isuserdata};
    const char *tyname[2] = {"userdata", "userdata"};
    lua_checkargs (L, 2, checktype, tyname, "OpenSteer_equality");
    void *obj1 = lua_touserdata (L, 1);
    void *obj2 = lua_touserdata (L, 2);
    bool res = (obj1 == obj2);
    lua_pop (L, 2);
    lua_pushboolean (L, res);
    assert (lua_gettop (L) == 1);
    return 1;
}


void OpenSteer::lua_vehicleSnapshot (lua_State *L,
			  AbstractVehicle *thisVehicle) {
  int debug_n = lua_gettop (L);
  lua_newtable (L);
  lua_pushstring (L, "pos");
  lua_pushVec3 (L, thisVehicle->position ());
  lua_rawset (L, -3);
  lua_pushstring (L, "vel");
  lua_pushVec3 (L, thisVehicle->velocity ());
  lua_rawset (L, -3);
  lua_pushstring (L, "forward");
  lua_pushVec3 (L, thisVehicle->forward ());
  lua_rawset (L, -3);
  lua_pushstring (L, "side");
  lua_pushVec3 (L, thisVehicle->side ());
  lua_rawset (L, -3);
  lua_pushstring (L, "up");
  lua_pushVec3 (L, thisVehicle->up ());
  lua_rawset (L, -3);
  lua_pushstring (L, "body");
  lua_pushVehicle(L, thisVehicle);
  lua_rawset (L, -3);
  lua_pushstring (L, "speed");
  lua_pushnumber(L, thisVehicle->speed ());
  lua_rawset (L, -3);
  lua_pushstring (L, "maxSpeed");
  lua_pushnumber(L, thisVehicle->maxSpeed ());
  lua_rawset (L, -3);
  lua_pushstring (L, "maxForce");
  lua_pushnumber(L, thisVehicle->maxForce ());
  lua_rawset (L, -3);
  lua_pushstring (L, "radius");
  lua_pushnumber(L, thisVehicle->radius ());
  lua_rawset (L, -3);
  lua_pushstring (L, "OpenSteer_type");
  lua_pushstring (L, "VehicleSnapshot");
  lua_rawset (L, -3);
  assert (lua_gettop (L) == debug_n+1);
}

static void lua_mapPathDistanceToSegmentDistance (SegmentedPathway *pathway,
						  float distance,
						  //output variables
						  OpenSteer::size_t &segment,
						  float &segment_distance) {
    segment = 0;
    float segment_length = 1.0;
    OpenSteer::size_t seg_count = pathway->segmentCount ();
    segment_distance = distance;
    while (segment < seg_count &&
	   segment_distance >=
	   (segment_length = pathway->segmentLength (segment++)))
	segment_distance -= segment_length;
    if (segment_distance < segment_length)
	segment--;
    assert (segment_distance < segment_length && segment < seg_count);
}

static int lua_radiusAtDistance (lua_State *L) {
    lua_istype checktype[1] = {(lua_istype) lua_isnumber};
    const char *tyname[1] = {"number"};
    lua_checkargs (L, 1, checktype, tyname, "radiusAtDistance");

    lua_Number pd = lua_tonumber (L, 1);
    SegmentedPathway *pathway  = lua_toPathway (L, lua_upvalueindex (1));
    lua_pop (L, 1);

    OpenSteer::size_t segment;
    float sd;
    lua_mapPathDistanceToSegmentDistance (pathway, pd, segment, sd);
    float r = pathway->mapSegmentDistanceToRadius (segment, sd);
    lua_pushnumber (L, r);
    assert (lua_gettop (L) == 1);
    return 1;
}

static int lua_tangentAtDistance (lua_State *L) {
    lua_istype checktype[1] = {(lua_istype) lua_isnumber};
    const char *tyname[1] = {"number"};
    lua_checkargs (L, 1, checktype, tyname, "tangentAtDistance");

    lua_Number pd = lua_tonumber (L, 1);
    SegmentedPathway *pathway  = lua_toPathway (L, lua_upvalueindex (1));
    lua_pop (L, 1);

    OpenSteer::size_t segment;
    float sd;
    lua_mapPathDistanceToSegmentDistance (pathway, pd, segment, sd);
    Vec3 vec = pathway->mapSegmentDistanceToTangent (segment, sd);
    lua_pushVec3 (L, vec);
    assert (lua_gettop (L) == 1);
    return 1;
}

static int lua_mapPathDistanceToPoint (lua_State *L) {
    lua_istype checktype[1] = {(lua_istype) lua_isnumber};
    const char *tyname[1] = {"number"};
    lua_checkargs (L, 1, checktype, tyname, "radiusAtDistance");

    lua_Number pd = lua_tonumber (L, 1);
    SegmentedPathway *pathway  = lua_toPathway (L, lua_upvalueindex (1));
    lua_pop (L, 1);

    OpenSteer::size_t segment;
    float sd;
    lua_mapPathDistanceToSegmentDistance (pathway, pd, segment, sd);
    Vec3 p = pathway->mapSegmentDistanceToPoint (segment, sd);
    lua_pushVec3 (L, p);
    assert (lua_gettop (L) == 1);
    return 1;
}


static int lua_steerToFollowPath (lua_State *L) {
    lua_istype checktype[2] = {(lua_istype) lua_isstring,
			       (lua_istype) lua_isnumber};
    const char *tyname[2] = {"string", "number"};
    lua_checkargs (L, 2, checktype, tyname, "steerToFollowPath");
    SegmentedPathway *pathway  = lua_toPathway (L, lua_upvalueindex (1));
    LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (2));
    const char *pathdir = lua_tostring (L, 1);
    lua_Number pf_leadTime = lua_tonumber (L, 2);
    lua_pop (L, 2);

    int pathDirection = (strcmp (pathdir, "upstream") == 0 ? 1 : -1);
    Vec3 steer = thisVehicle->steerToFollowPath (pathDirection, pf_leadTime,
						 *pathway);
    lua_pushVec3 (L, steer);
    assert (lua_gettop (L) == 1);    
    return 1;
}

static int lua_steerToStayOnPath (lua_State *L) {
    lua_istype checktype[1] = {(lua_istype) lua_isnumber};
    const char *tyname[1] = {"number"};
    lua_checkargs (L, 1, checktype, tyname, "steerToStayOnPath");
    SegmentedPathway *pathway  = lua_toPathway (L, lua_upvalueindex (1));
    LuaVehicle *thisVehicle = lua_toLuaVehicle (L, lua_upvalueindex (2));

    lua_Number pf_leadTime = lua_tonumber (L, 1);
    lua_pop (L, 1);

    Vec3 steer = thisVehicle->steerToStayOnPath (pf_leadTime, *pathway);
    lua_pushVec3 (L, steer);
    assert (lua_gettop (L) == 1);    
    return 1;
}

static float calculatePathwayLength (SegmentedPathway *pathway) {
    float length = 0;
    assert (pathway != NULL);
    OpenSteer::size_t seg_count = pathway->segmentCount ();
    for (OpenSteer::size_t segment = 0; segment < seg_count;  segment++) {
	length += pathway->segmentLength (segment);
    }
    return length;
}

void LuaVehicle::lua_pathwayObject (SegmentedPathway *pathway) {
  int debug_n = lua_gettop (L);
  lua_newtable (L);
  lua_pushstring (L, "radiusAtDistance");
  lua_pushPathway (L, pathway);
  lua_pushcclosure (L, lua_radiusAtDistance, 1);
  lua_rawset (L, -3);
  lua_pushstring (L, "tangentAtDistance");
  lua_pushPathway (L, pathway);
  lua_pushcclosure (L, lua_tangentAtDistance, 1);
  lua_rawset (L, -3);
  lua_pushstring (L, "mapPathDistanceToPoint");
  lua_pushPathway (L, pathway);
  lua_pushcclosure (L, lua_mapPathDistanceToPoint, 1);
  lua_rawset (L, -3);
  lua_pushstring (L, "steerToFollowPath");
  lua_pushPathway (L, pathway);
  lua_push ();
  lua_pushcclosure (L, lua_steerToFollowPath, 2);
  lua_rawset (L, -3);
  lua_pushstring (L, "steerToStayOnPath");
  lua_pushPathway (L, pathway);
  lua_push ();
  lua_pushcclosure (L, lua_steerToStayOnPath, 2);
  lua_rawset (L, -3);
  lua_pushstring (L, "length");
  lua_pushnumber(L, calculatePathwayLength (pathway));
  lua_rawset (L, -3);
  lua_pushstring (L, "body");
  lua_pushPathway(L, pathway);
  lua_rawset (L, -3);
  lua_pushstring (L, "OpenSteer_type");
  lua_pushstring (L, "PathwayObject");
  lua_rawset (L, -3);
  assert (lua_gettop (L) == debug_n+1);
}

void OpenSteer::lua_LuaVehicleSnapshot (lua_State *L,
			  LuaVehicle *thisVehicle) {
  int debug_n = lua_gettop (L);
  lua_newtable (L);
  lua_pushstring (L, "pos");
  lua_pushVec3 (L, thisVehicle->position ());
  lua_rawset (L, -3);
  lua_pushstring (L, "vel");
  lua_pushVec3 (L, thisVehicle->velocity ());
  lua_rawset (L, -3);
  lua_pushstring (L, "forward");
  lua_pushVec3 (L, thisVehicle->forward ());
  lua_rawset (L, -3);
  lua_pushstring (L, "side");
  lua_pushVec3 (L, thisVehicle->side ());
  lua_rawset (L, -3);
  lua_pushstring (L, "up");
  lua_pushVec3 (L, thisVehicle->up ());
  lua_rawset (L, -3);
  lua_pushstring (L, "body");
  lua_pushLuaVehicle(L, thisVehicle);
  lua_rawset (L, -3);
  lua_pushstring (L, "speed");
  lua_pushnumber(L, thisVehicle->speed ());
  lua_rawset (L, -3);
  lua_pushstring (L, "maxSpeed");
  lua_pushnumber(L, thisVehicle->maxSpeed ());
  lua_rawset (L, -3);
  lua_pushstring (L, "maxForce");
  lua_pushnumber(L, thisVehicle->maxForce ());
  lua_rawset (L, -3);
  lua_pushstring (L, "radius");
  lua_pushnumber(L, thisVehicle->radius ());
  lua_rawset (L, -3);
  lua_pushstring (L, "OpenSteer_type");
  lua_pushstring (L, "LuaVehicleSnapshot");
  lua_rawset (L, -3);
  assert (lua_gettop (L) == debug_n+1);
}

void LuaVehicle::lua_snapshot () {
  int debug_n = lua_gettop (L);
  lua_newtable (L);
  lua_pushstring (L, "pos");
  lua_pushVec3 (L, position ());
  lua_rawset (L, -3);
  lua_pushstring (L, "vel");
  lua_pushVec3 (L, velocity ());
  lua_rawset (L, -3);
  lua_pushstring (L, "forward");
  lua_pushVec3 (L, forward ());
  lua_rawset (L, -3);
  lua_pushstring (L, "side");
  lua_pushVec3 (L, side ());
  lua_rawset (L, -3);
  lua_pushstring (L, "up");
  lua_pushVec3 (L, up ());
  lua_rawset (L, -3);
  lua_pushstring (L, "body");
  lua_push();
  lua_rawset (L, -3);
  lua_pushstring (L, "speed");
  lua_pushnumber(L, speed ());
  lua_rawset (L, -3);
  lua_pushstring (L, "maxSpeed");
  lua_pushnumber(L, maxSpeed ());
  lua_rawset (L, -3);
  lua_pushstring (L, "maxForce");
  lua_pushnumber(L, maxForce ());
  lua_rawset (L, -3);
  lua_pushstring (L, "radius");
  lua_pushnumber(L, radius ());
  lua_rawset (L, -3);
  lua_pushstring (L, "OpenSteer_type");
  lua_pushstring (L, "LuaVehicleSnapshot");
  lua_rawset (L, -3);
  assert (lua_gettop (L) == debug_n+1);
}

void LuaVehicle::registerLuaVehicle (ProximityToken* proxy,
				     bool mailbox_messaging,
				     bool broadcast_messaging)
{
    lua_register (L, "addVec", addVec);
    lua_register (L, "subVec", subVec);
    lua_register (L, "mulVec", mulVec);
    lua_register (L, "dotVec", dotVec);
    lua_register (L, "distVec", distVec);
    lua_register (L, "crossVec", crossVec);
    lua_register (L, "lenVec", lenVec);
    lua_register (L, "normalize", normVec);
    lua_register (L, "randomVectorOnUnitRadiusXZDisk",
		  lua_randomVectorOnUnitRadiusXZDisk);
    lua_register (L, "nonzeroVec", nonzeroVec);
    lua_register (L, "Vec3", consVec);
    lua_register (L, "xVec", xVec);
    lua_register (L, "yVec", yVec);
    lua_register (L, "zVec", zVec);
    lua_register (L, "new_AVGroup", lua_new_AVGroup);
    lua_register (L, "foreach_vehicle", lua_foreachVehicle);
    lua_register (L, "printType", lua_printType);
    lua_register (L, "smoothedPosition", lua_smoothedPosition);
    lua_register (L, "curvature", lua_curvature);
    lua_register (L, "resetSmoothedPosition", lua_resetSmoothedPosition);
    lua_register (L, "resetSmoothedAcceleration",
		  lua_resetSmoothedAcceleration);
    assert (lua_gettop (L) == LUABASE(0));

    lua_newtable (L);
    lua_pushstring (L, "__add");
    lua_pushcfunction (L, addVec);
    lua_settable (L, -3);
    assert (lua_gettop (L) == LUABASE(1));
    lua_pushstring (L, "__sub");
    lua_pushcfunction (L, subVec);
    lua_settable (L, -3);
    lua_pushstring (L, "__mul");
    lua_pushcfunction (L, muldotVec);
    lua_settable (L, -3);
    lua_pushstring (L, "__div");
    lua_pushcfunction (L, divVec);
    lua_settable (L, -3);
    lua_pushstring (L, "__pow");
    lua_pushcfunction (L, crossVec);
    lua_settable (L, -3);
    lua_pushstring (L, "__unm");
    lua_pushcfunction (L, unmVec);
    lua_settable (L, -3);
    lua_pushstring (L, "__concat");
    lua_pushcfunction (L, distVec);
    lua_settable (L, -3);
    lua_pushstring (L, "__eq");
    lua_pushcfunction (L, eqVec);
    lua_settable (L, -3);
    lua_pushstring (L, "OpenSteer_type");
    lua_pushstring (L, "Vec3");
    lua_settable (L, -3);
    assert (lua_gettop (L) == LUABASE(1));
    lua_setglobal (L, "Vec3_metatable");
    assert (lua_gettop (L) == LUABASE(0));

    lua_newtable (L);
    lua_pushstring (L, "OpenSteer_type");
    lua_pushstring (L, "Color");
    lua_settable (L, -3);
    lua_pushstring (L, "__mul");
    lua_pushcfunction (L, muldotColor);
    lua_settable (L, -3);
    lua_pushstring (L, "__eq");
    lua_pushcfunction (L, lua_equality);
    lua_settable (L, -3);
    assert (lua_gettop (L) == LUABASE(1));
    lua_setglobal (L, "Color_metatable");
    assert (lua_gettop (L) == LUABASE(0));

    lua_newtable (L);
    lua_pushstring (L, "OpenSteer_type");
    lua_pushstring (L, "Vehicle");
    lua_settable (L, -3);
    lua_pushstring (L, "__eq");
    lua_pushcfunction (L, lua_equality);
    lua_settable (L, -3);
    assert (lua_gettop (L) == LUABASE(1));
    lua_setglobal (L, "Vehicle_metatable");
    assert (lua_gettop (L) == LUABASE(0));

    lua_newtable (L);
    lua_pushstring (L, "OpenSteer_type");
    lua_pushstring (L, "LuaVehicle");
    lua_settable (L, -3);
    lua_pushstring (L, "__eq");
    lua_pushcfunction (L, lua_equality);
    lua_settable (L, -3);
    assert (lua_gettop (L) == LUABASE(1));
    lua_setglobal (L, "LuaVehicle_metatable");
    assert (lua_gettop (L) == LUABASE(0));
    
    lua_newtable (L);
    lua_pushstring (L, "OpenSteer_type");
    lua_pushstring (L, "AVGroup");
    lua_settable (L, -3);
    lua_pushstring (L, "__eq");
    lua_pushcfunction (L, lua_equality);
    lua_settable (L, -3);
    assert (lua_gettop (L) == LUABASE(1));
    lua_setglobal (L, "light_AVGroup_metatable");
    assert (lua_gettop (L) == LUABASE(0));
    
    lua_newtable (L);
    lua_pushstring (L, "OpenSteer_type");
    lua_pushstring (L, "Obstacles");
    lua_settable (L, -3);
    lua_pushstring (L, "__eq");
    lua_pushcfunction (L, lua_equality);
    lua_settable (L, -3);
    assert (lua_gettop (L) == LUABASE(1));
    lua_setglobal (L, "Obstacles_metatable");
    assert (lua_gettop (L) == LUABASE(0));
    
    lua_newtable (L);
  lua_pushstring (L, "OpenSteer_type");
  lua_pushstring (L, "AVGroup");
  lua_settable (L, -3);
  lua_pushstring (L, "__gc");
  lua_pushcfunction (L, lua_finalizeAVGroup);
  lua_settable (L, -3);
    lua_pushstring (L, "__eq");
    lua_pushcfunction (L, lua_equality);
    lua_settable (L, -3);
  assert (lua_gettop (L) == LUABASE(1));
  lua_setglobal (L, "full_AVGroup_metatable");
  assert (lua_gettop (L) == LUABASE(0));
    
    lua_newtable (L);
    lua_pushstring (L, "OpenSteer_type");
    lua_pushstring (L, "Pathway");
    lua_settable (L, -3);
    lua_pushstring (L, "__eq");
    lua_pushcfunction (L, lua_equality);
    lua_settable (L, -3);
    assert (lua_gettop (L) == LUABASE(1));
    lua_setglobal (L, "light_Pathway_metatable");
    assert (lua_gettop (L) == LUABASE(0));

    lua_push ();
    lua_pushcclosure (L, lua_annotationLine, 1);
    lua_setglobal (L, "annotationLine");
    lua_push ();
    lua_pushcclosure (L, lua_annotationCircleOrDisk, 1);
    lua_setglobal (L, "annotationCircleOrDisk");
  lua_push ();
  lua_pushcclosure (L, lua_steerToAvoidNeighbors, 1);
  lua_setglobal (L, "steerToAvoidNeighbors");
  lua_push ();
  lua_pushcclosure (L, lua_steerToAvoidObstacles, 1);
  lua_setglobal (L, "steerToAvoidObstacles");
  lua_push ();
  lua_pushcclosure (L, lua_steerForSeparation, 1);
  lua_setglobal (L, "steerForSeparation");
  lua_push ();
  lua_pushcclosure (L, lua_steerForAlignment, 1);
  lua_setglobal (L, "steerForAlignment");
  lua_push ();
  lua_pushcclosure (L, lua_steerForCohesion, 1);
  lua_setglobal (L, "steerForCohesion");
  lua_push ();
  lua_pushcclosure (L, lua_steerForSeek, 1);
  lua_setglobal (L, "steerForSeek");
  lua_push ();
  lua_pushcclosure (L, lua_steerForFlee, 1);
  lua_setglobal (L, "steerForFlee");
  lua_push ();
  lua_pushcclosure (L, lua_steerForWander, 1);
  lua_setglobal (L, "steerForWander");
  lua_push ();
  lua_pushcclosure (L, lua_steerForTargetSpeed, 1);
  lua_setglobal (L, "steerForTargetSpeed");
  lua_push ();
  lua_pushcclosure (L, lua_steerForPursuit, 1);
  lua_setglobal (L, "steerForPursuit");
//   lua_push ();
//   lua_pushcclosure (L, lua_steerForEvasion, 1);
//   lua_setglobal (L, "steerForEvasion");
  if (proxy) {
    lua_pushlightuserdata (L, proxy);
    lua_pushcclosure (L, lua_findNeighbors, 1);
    lua_setglobal (L, "findNeighbors");
    lua_pushlightuserdata (L, proxy);
    lua_pushcclosure (L, lua_findNeighborsImp, 1);
    lua_setglobal (L, "findNeighborsImp");
  }


    lua_register (L, "Color", consColor);
    lua_pushColor (L, gWhite);
    lua_setglobal (L, "White");
    lua_pushColor (L, gBlack);
    lua_setglobal (L, "Black");
    lua_pushColor (L, gYellow);
    lua_setglobal (L, "Yellow");
    lua_pushColor (L, gOrange);
    lua_setglobal (L, "Orange");
    lua_pushColor (L, gRed);
    lua_setglobal (L, "Red");
    lua_pushColor (L, gBlue);
    lua_setglobal (L, "Blue");
    lua_pushColor (L, gMagenta);
    lua_setglobal (L, "Magenta");
    lua_pushColor (L, gCyan);
    lua_setglobal (L, "Cyan");

  if (mailbox_messaging)
      lua_register (L, "send_message", lua_sendMessage);
  if (broadcast_messaging)
      lua_register (L, "receive_broadcast", lua_receiveBroadcast);
  assert (lua_gettop (L) == LUABASE(0));
}

// bool OpenSteer::lua_DEBUG = true;

// static void lua_debug_advance ()

static int lua_debug_backtrace (lua_State *L) {
    int depth = 0;
    const char *lastframe;
    lua_Debug ar;
    while (lua_getstack (L, depth, &ar)) {
	lastframe = lua_tostring (L, -1);
	lua_pop (L, 1);
	if (!lua_getinfo (L, "Sl", &ar)) {
	    lua_pushfstring (L, "%s; backtrace error: debug info failed",
			     lastframe);
	    lua_error(L);
	}
	lua_pushfstring
	    (L, "%s -- called by:\n%s:%d: (backtrace)", lastframe,
	     (ar.source + 1), ar.currentline);
	depth++;
    }
    return 1;
}

void LuaVehicle::open (ProximityToken *proxy,
		       bool mailbox_messaging,
		       bool broadcast_messaging)
{
    L = lua_open();
    luaL_openlibs(L);
    lua_pushcfunction (L, lua_debug_backtrace);
    registerLuaVehicle (proxy, mailbox_messaging, broadcast_messaging);
    registerGlobals ();
    lua_snapshot ();
    lua_setglobal (L, "my");
    assert (lua_gettop (L) == LUABASE (0));
//     if (lua_DEBUG)
// 	lua_sethook (L, lua_debug_advance, LUA_MASKLINE, 1);
    reset ();
}

void LuaVehicle::close ()
{
    lua_close (L);
}

void LuaVehicle::reset (void)
        {
	    SimpleVehicle::reset ();

	    struct stat attrib;
	    const char *scriptFile = scriptFileName ();
	    stat(scriptFile, &attrib);
	    __time_t mtime = attrib.st_mtime;
	    if (scriptModifTime < mtime) {
		//std::cerr << "before initializing" << std::endl; //DEBUG
		
		//lua_pushcfunction (L, lua_debug_backtrace);
		int status = luaL_loadfile (L, scriptFile);
		//XXX: error handling protocol?
		if (status) {
		    const char *err = lua_tostring (L, -1);
		    (void)fprintf(stderr, "%s -- bad script file \"%s\"\n",
				  err, scriptFile);
		    exit(1);
		};
		int result = lua_pcall(L, 0, LUA_MULTRET, 1);
		//std::cerr << "after initializing" << std::endl; //DEBUG
		//XXX: error handling protocol?
		if (result) {
		    const char *err = lua_tostring (L, -1);
		    fprintf(stdout, "%s -- bad script initialisation \"%s\"\n",
			    err, scriptFile);
		    exit(1);
		}
		//lua_pushcfunction (L, lua_debug_backtrace);
	    }

	    //call user reset
	    lua_pushstring (L, "reset");
	    lua_gettable (L, LUA_GLOBALSINDEX);
	    int argsnum = registerResetArgs ();
	    //std::cerr << "before reset" << std::endl; //DEBUG
	    int result = lua_pcall (L, argsnum, 1, 1);
	    //std::cerr << "after reset" << std::endl; //DEBUG
	    //XXX: error handling protocol?
	    if (result) {
		const char *err = lua_tostring (L, -1);
		fprintf(stdout, "%s -- bad `reset' function in script \"%s\"\n",
			err, scriptFile);
		exit(1);
	    }
	    int n = lua_gettop (L);
	    if (n != LUABASE(1)) {
		fprintf (stdout,
			 "incorrect number of values returned from `reset'\
 function in script \"%s\"\n", scriptFile);
		exit (1);
	    }
	    if (!lua_isVec3 (L, LUABASE(1))) {
		fprintf (stdout,
			 "incorrect type of value returned from `reset'\
 function in script \"%s\"\n -- got %s\n", scriptFile, lua_getArgType (L, 1));
		exit (1);
	    }
	    Vec3 *vec = (Vec3*) lua_touserdata (L, -1);
	    setPosition (*vec);
	    lua_pop (L, 1);
	    assert (lua_gettop (L) == LUABASE(0));
	    //std::cerr << "leaving reset" << std::endl; //DEBUG    
	}

void LuaVehicle::getSteeringAndBraking (Vec3 &steering, float &braking)
{
	    const char *scriptFile = scriptFileName ();

	    lua_getglobal (L, "update");
	    if (lua_type (L, -1) != LUA_TFUNCTION) {
		fprintf(stdout,
			"In script \"%s\" `update' not defined as function\
 (got %s)", scriptFile, lua_typename (L, lua_type (L, -1)));
		exit(1);
	    }
	    int argsnum = registerUpdateArgs ();
	    //XXX: error handling protocol?
	    if (argsnum != (lua_gettop (L) - LUABASE(1))) {
		fprintf(stdout,
			"Wrong number of arguments for `update' function\
 in script \"%s\"\n -- declared %d, got %d\n", scriptFile, argsnum,
			lua_gettop (L) - LUABASE(1));
		exit(1);
	    }

	    lua_snapshot ();
	    lua_setglobal (L, "my");
	    
	    int result = lua_pcall(L, argsnum, LUA_MULTRET, 1);
	    //XXX: error handling protocol?
	    if (result) {
		const char *err = lua_tostring (L, -1);
		fprintf(stdout,
			"%s -- bad `update' function in script \"%s\"\n",
			err, scriptFile);
		exit(1);
	    }
	    int nret = lua_gettop (L) - LUABASE (0);
	    if (nret < 1 || nret > 2) {
		fprintf (stdout,
			 "incorrect number of values returned from `update'\
 function in script \"%s\"\n -- expected 1 or 2, got %d\n", scriptFileName (),
			 nret);
		exit (1);
	    }

	    if (!lua_isVec3 (L, LUABASE(1))) {
		fprintf (stdout,
			 "incorrect type of first value (steering) returned from `update'\
 function in script \"%s\"\n -- expected Vec3, got %s\n", scriptFileName (),
			 lua_getArgType (L, LUABASE(1)));
		exit (1);
	    }
	    if (nret == 2 && !lua_isnumber (L, LUABASE(2))) {
		fprintf (stdout,
			 "incorrect type of second value (braking) returned from `update'\
 function in script \"%s\"\n -- expected number, got %s\n", scriptFileName (),
			 lua_getArgType (L, LUABASE(2)));
		exit (1);
	    }
	    braking = 0.0;
	    steering = *((Vec3 *) lua_touserdata (L, LUABASE(1)));
	    if (nret == 2)
	      braking  =  lua_tonumber (L, LUABASE(2));
	    lua_pop (L, nret);
	    assert (lua_gettop (L) == LUABASE(0));

	}
