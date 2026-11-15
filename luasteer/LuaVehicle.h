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

// ----------------------------------------------------------------------
// BUGS:
// * Unary minus on Vec3 gets spurious arguments,
//   I don't know where they're from.
//   WORKAROUND: don't use unary minus (multiply by -1 instead)

#ifndef OPENSTEER_LUASTEER_H
#define OPENSTEER_LUASTEER_H

#include "OpenSteer/SimpleVehicle.h"
#include "OpenSteer/Proximity.h"
#include "OpenSteer/SegmentedPathway.h"
#include "OpenSteer/Vec3.h"

#include <lua.hpp>

#define LUABASE(x) ((x)+1)    

namespace OpenSteer {

    // ----------------------------------------------------------------------------


  typedef OpenSteer::AbstractProximityDatabase<OpenSteer::AbstractVehicle*> ProximityDatabase;
  typedef OpenSteer::AbstractTokenForProximityDatabase<OpenSteer::AbstractVehicle*> ProximityToken;

  typedef bool (*lua_istype) (lua_State*, int);

  void lua_checkargs (lua_State *L, int numargs,
			  const lua_istype *checktype,
			  const char **tyname,
			   const char *fname);

 bool lua_isLuaFunction (lua_State *L, int index);

// Check if a userdata was constructed by lua_pushVec3
bool lua_isVec3 (lua_State *L, int index);

bool lua_isColor (lua_State *L, int index);

// Check if a userdata is a SimpleVehicle (from lua_pushVehicle)
bool lua_isVehicle (lua_State *L, int index);

// Check if a userdata is a LuaVehicle (from LuaSteerMixin::pushLuaVehicle)
bool lua_isLuaVehicle (lua_State *L, int index);

// Check if a userdata is a group
bool lua_isAVGroup (lua_State *L, int index);

bool lua_isBool (lua_State *L, int index);

// Check if a userdata is an obstcle group
bool lua_isObstacles (lua_State *L, int index);

// Check if a userdata is a pathway
bool lua_isPathway (lua_State *L, int index);

// Push Vec3 with a metatable on stack
void lua_pushVec3 (lua_State *L, Vec3 vec);

void lua_pushColor (lua_State *L, Color col);

// Push AVGroup with a metatable on stack,
// keep it alive while using from Lua!
void lua_pushAVGroup (lua_State *L, AVGroup* avgroup);

// Push ObstacleGroup with a metatable on stack,
// keep it alive while using from Lua!
void lua_pushObstacles (lua_State *L, ObstacleGroup* obstacles);

// Push SegmentedPathway with a metatable on stack,
// keep it alive while using from Lua!
void lua_pushPathway (lua_State *L, SegmentedPathway* pathway);


// Push Vehicle with a metatable on stack,
// keep it alive while using from Lua!
void lua_pushVehicle (lua_State *L, AbstractVehicle* vehicle);

 Vec3 lua_toVec3 (lua_State *L, int index);

 Color lua_toColor (lua_State *L, int index);

SegmentedPathway* lua_toPathway (lua_State *L, int index);

const char *lua_getArgType (lua_State *L, int index);

// Push a table on the stack with vehicle information
void lua_vehicleSnapshot (lua_State *L,
			  AbstractVehicle *thisVehicle);

    class LuaVehicle : public SimpleVehicle
    {
    public:
	// Register specific vehicle functionality and environment
	virtual void registerGlobals () = 0;
	virtual const char *scriptFileName () = 0;
	// Build arguments to reset/update function, return number of arguments
	virtual int registerResetArgs () = 0;
	virtual int registerUpdateArgs () = 0;
	// Register general vehicle functionality
	void registerLuaVehicle (ProximityToken* proxy,
				 bool mailbox_messaging, bool broadcast_messaging);
	LuaVehicle () : L(NULL), scriptModifTime(0) {}
	// create Lua state, register libraries and OpenSteer functionality
	void open (ProximityToken* proxy,
		   bool mailbox_messaging, bool broadcast_messaging);
	// Close Lua state
	void close (void);
	// Reset vehicle, load vehicle script if needed
	// calls "reset" from script which returns initial position
        void reset (void);
	// Compute both steering and perhaps braking force by "update"
	// from script "update" must return one or two values
	void getSteeringAndBraking (Vec3 &steering, float &braking);
		    
	// Push Vehicle with a metatable on stack,
	// keep it alive while using from Lua! (it is a light-user-data)
	void lua_push ();
	// Push a table on the stack with vehicle information
	void lua_snapshot ();
	// Push a table on the stack with pathway information and methods
	void lua_pathwayObject (SegmentedPathway *pathway);

	// Read a global variable with string contents (NULL if type mismatch)
	const char *readVariable (const char *name);
	// receive mail (mailbox messaging)
	void receiveMail (const char *message);
    protected:

	lua_State *L;
	__time_t scriptModifTime;

    };

 void lua_LuaVehicleSnapshot (lua_State *L, LuaVehicle *thisVehicle);

 LuaVehicle *lua_toLuaVehicle (lua_State *L, int index);

}

#endif
