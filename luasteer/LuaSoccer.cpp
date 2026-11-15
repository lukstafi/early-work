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
// Soccer game with players controlled by Lua scripts
// Copyright 2007 by Lukasz Stafiniak
//
// Soccer engine based on (see file Soccer.cpp):
// Simple soccer game by Michael Holm, IO Interactive A/S
// (contributed on July 9, 2003)
//
// ----------------------------------------------------------------------------


#include <iomanip>
#include <sstream>
#include "OpenSteer/SimpleVehicle.h"
#include "OpenSteer/OpenSteerDemo.h"
#include "OpenSteer/Draw.h"
#include "OpenSteer/Color.h"
#include "OpenSteer/UnusedParameter.h"
#include "OpenSteer/LuaVehicle.h"
#include "OpenSteer/Vec3.h"

namespace {

    using namespace OpenSteer;


    // ----------------------------------------------------------------------------

    // a box object for the field and the goals.
    class AABBox{
    public:
        AABBox(Vec3 min, Vec3 max): m_min(min), m_max(max){}
        bool	InsideX(const Vec3 p){if(p.x < m_min.x || p.x > m_max.x)	return false;return true;}
        bool	InsideZ(const Vec3 p){if(p.z < m_min.z || p.z > m_max.z)	return false;return true;}
        void	draw(){
            Vec3 b,c;
            b = Vec3(m_min.x, 0, m_max.z);
            c = Vec3(m_max.x, 0, m_min.z);
            Color color(1.0f,1.0f,0.0f);
            drawLineAlpha(m_min, b, color, 1.0f);
            drawLineAlpha(b, m_max, color, 1.0f);
            drawLineAlpha(m_max, c, color, 1.0f);
            drawLineAlpha(c,m_min, color, 1.0f);
        }
	Vec3 clip (Vec3 pos) {
	    pos.x = (pos.x < m_min.x ? m_min.x :
		     (pos.x > m_max.x ? m_max.x : pos.x));
	    pos.z = (pos.z < m_min.z ? m_min.z :
		     (pos.z > m_max.z ? m_max.z : pos.z));
	    return pos;
	}
	    
    private:
        Vec3 m_min;
        Vec3 m_max;
    };

    // The ball object
    class Ball : public SimpleVehicle{
    public:
        Ball(AABBox *bbox) : m_bbox(bbox), held (false) {reset();}

        // reset state
        void reset (void)
        {
            SimpleVehicle::reset (); // reset the vehicle 
            setSpeed (0.0f);         // speed along Forward direction.
            setMaxForce (9.0f);      // steering force is clipped to this magnitude
            setMaxSpeed (10);         // velocity is clipped to this magnitude

            setPosition(0,0,0);
            clearTrailHistory ();    // prevent long streaks due to teleportation 
            setTrailParameters (100, 6000);
        }

        // per frame simulation update
        void update (const float currentTime, const float elapsedTime)
        {
            applyBrakingForce(1.5f, elapsedTime);
	    if (held)
		applySteeringForce(steerForSeek (foot_position)*50,
				   elapsedTime);
	    else
		applySteeringForce(velocity(), elapsedTime);
            // are we now outside the field?
            if(!m_bbox->InsideX(position()))
            {
		setPosition (m_bbox->clip (position ()));
                Vec3 d = velocity();
                regenerateOrthonormalBasis(Vec3(-d.x, d.y, d.z));
                applySteeringForce(velocity(), elapsedTime);
            }
            if(!m_bbox->InsideZ(position()))
            {
		setPosition (m_bbox->clip (position ()));
                Vec3 d = velocity();
                regenerateOrthonormalBasis(Vec3(d.x, d.y, -d.z));
                applySteeringForce(velocity(), elapsedTime);
            }
        recordTrailVertex (currentTime, position());
        }

        void kick(Vec3 dir, const float elapsedTime){
            OPENSTEER_UNUSED_PARAMETER(elapsedTime);

	    held = false;
            setSpeed(dir.length());
            regenerateOrthonormalBasis(dir);
        }
        void holdAt(Vec3 pos, float n_speed){
            held = true;
	    foot_position = pos;
	    setSpeed (n_speed);
            //regenerateOrthonormalBasis(dir);
        }

        // draw this character/vehicle into the scene
        void draw (void)
        {
            drawBasic2dCircularVehicle (*this, Color(0.0f,1.0f,0.0f));
            drawTrail ();
        }

        AABBox *m_bbox;
	bool held;
	Vec3 foot_position;
    };

    // Make a field
    static Vec3 LuaSoccer_BottomA = Vec3(-20,0,-10);
    static Vec3 LuaSoccer_TopB = Vec3(20,0,10);
    static Vec3 LuaSoccer_TopA = Vec3(-20,0,10);
    static Vec3 LuaSoccer_BottomB = Vec3(20,0,-10);
    // Red goal
    static Vec3 LuaSoccer_AGoal = Vec3(-20,0,0);
    // Blue Goal
    static Vec3 LuaSoccer_BGoal = Vec3(20,0,0);

    class LuaPlayer : public LuaVehicle
    {
    public:

        // constructor
        LuaPlayer (std::vector<LuaPlayer*> others, std::vector<LuaPlayer*> opponents, std::vector<LuaPlayer*> allplayers, Ball* ball, bool isTeamA, int id) : m_others(others), m_opponents (opponents), m_AllPlayers(allplayers), m_Ball(ball), b_ImTeamA(isTeamA), m_MyID(id)
	{
	    // initialize Lua state, with broadcast messaging
	    open (NULL, false, true);
	    // reset all boid state and load Lua script
	    reset ();
	}

	// register the field geometry and player number
	void registerGlobals ()
	{
	    lua_pushnumber(L, m_MyID);
	    lua_setglobal(L, "playerID");
	    lua_pushVec3 (L, (b_ImTeamA ? LuaSoccer_AGoal
			       : LuaSoccer_BGoal));
	    lua_setglobal(L, "myGoal");
	    lua_pushVec3 (L, (b_ImTeamA ? LuaSoccer_BGoal
			       : LuaSoccer_AGoal));
	    lua_setglobal(L, "opGoal");
	    lua_pushVec3 (L, (b_ImTeamA ? LuaSoccer_TopA
			      : LuaSoccer_TopB));
	    lua_setglobal(L, "myTop");
	    lua_pushVec3 (L, (b_ImTeamA ? LuaSoccer_BottomA
			      : LuaSoccer_BottomB));
	    lua_setglobal(L, "myBottom");
	    lua_pushVec3 (L, (b_ImTeamA ? LuaSoccer_TopB
			      : LuaSoccer_TopA));
	    lua_setglobal(L, "opTop");
	    lua_pushVec3 (L, (b_ImTeamA ? LuaSoccer_BottomB
			      : LuaSoccer_BottomA));
	    lua_setglobal(L, "opBottom");
	    lua_pushAVGroup (L, (AVGroup*) &m_AllPlayers);
	    lua_setglobal(L, "allPlayers");
	    lua_pushAVGroup (L, (AVGroup*) &m_others);
	    lua_setglobal(L, "myTeam");
	    lua_pushAVGroup (L, (AVGroup*) &m_opponents);
	    lua_setglobal(L, "opTeam");
	}

	const char *scriptFileName ()
	{
	    return (b_ImTeamA ? "../plugins/soccerTeamA.lua"
		    :  "../plugins/soccerTeamB.lua");
	}
	
	// No args to "reset"
	int registerResetArgs ()
	{
	    return 0;
	}
        // reset state
        void reset (void)
        {
	    // reset the vehicle
	    LuaVehicle::reset ();

            setSpeed (0.0f);         // speed along Forward direction.
            setMaxForce (10);      // steering force is clipped to this magnitude
            setMaxSpeed (8);         // velocity is clipped to this magnitude

            clearTrailHistory ();    // prevent long streaks due to teleportation 
            setTrailParameters (10, 60);
        }

	// pass ball to "update"
	int registerUpdateArgs ()
	{
	    lua_vehicleSnapshot (L, m_Ball);
	    return 1;
	}
        // per frame simulation update
        // (parameter names commented out to prevent compiler warning from "-W")
        void update (const float /*currentTime*/, const float elapsedTime)
        {
            // if I hit the ball, kick it or hold it.

            const float distToBall = Vec3::distance (position(), m_Ball->position());
            const float sumOfRadii = radius() + m_Ball->radius();
	    const char *state = readVariable ("state");
	    assert (state != NULL);
            if (distToBall < sumOfRadii) {
		if (speed () > 5.0 || strcmp (state, "kick") == 0)
		    m_Ball->kick((m_Ball->position()-position())*50,
				 elapsedTime);
		else if (strcmp (state, "keep ball") == 0)
		    m_Ball->holdAt (position()+forward ()*radius (),
				    speed ());
	    }

	    Vec3 steering;
	    float braking;
	    getSteeringAndBraking (steering, braking);
            // play the game
	    applySteeringForce (steering, elapsedTime);
	    if (braking != 0.0) applyBrakingForce (braking, elapsedTime);
// 	    Vec3 pos = position ();
// 	    pos.y = 0;
// 	    setPosition (pos);
        }

        // draw this character/vehicle into the scene
        void draw (void)
        {
            drawBasic2dCircularVehicle (*this, b_ImTeamA ? Color(1.0f,0.0f,0.0f):Color(0.0f,0.0f,1.0f));
            drawTrail ();
        }
        // per-instance reference to its group
        const std::vector<LuaPlayer*>	m_others;
        const std::vector<LuaPlayer*>	m_opponents;
        const std::vector<LuaPlayer*>	m_AllPlayers;
        Ball*	m_Ball;
        bool	b_ImTeamA;
        int		m_MyID;
    };



    // ----------------------------------------------------------------------------
    // PlugIn for OpenSteerDemo
    class LuaSoccerPlugIn : public PlugIn
    {
    public:
        
	//bool requestInitialSelection () {return true;}

        const char* name (void) {return "Lua Soccer";}

        // float selectionOrderSortKey (void) {return 0.06f;}

        // bool requestInitialSelection() { return true;}

        // be more "nice" to avoid a compiler warning
        virtual ~LuaSoccerPlugIn() {}

        void open (void)
        {
	    // Make a field
	    m_bbox = new AABBox(LuaSoccer_BottomA, LuaSoccer_TopB);
	    // Red goal
	    m_TeamAGoal = new AABBox(LuaSoccer_AGoal - Vec3 (1, 0, 7),
				     LuaSoccer_AGoal + Vec3 (1, 0, 7));
	    // Blue Goal
	    m_TeamBGoal = new AABBox(LuaSoccer_BGoal - Vec3 (1, 0, 7),
				     LuaSoccer_BGoal + Vec3 (1, 0, 7));
            // Make a ball
            m_Ball = new Ball(m_bbox);
            // Build team A
            m_PlayerCountA = 8;
            for(unsigned int i=0; i < m_PlayerCountA ; i++)
            {
                LuaPlayer *pMicTest = new LuaPlayer(TeamA, TeamB, m_AllPlayers, m_Ball, true, i);
                OpenSteerDemo::selectedVehicle = pMicTest;
                TeamA.push_back (pMicTest);
                m_AllPlayers.push_back(pMicTest);
            }
            // Build Team B
            m_PlayerCountB = 8;
            for(unsigned int i=0; i < m_PlayerCountB ; i++)
            {
                LuaPlayer *pMicTest = new LuaPlayer(TeamB, TeamA, m_AllPlayers, m_Ball, false, i);
                OpenSteerDemo::selectedVehicle = pMicTest;
                TeamB.push_back (pMicTest);
                m_AllPlayers.push_back(pMicTest);
            }
            // initialize camera
            OpenSteerDemo::init2dCamera (*m_Ball);
            OpenSteerDemo::camera.setPosition (10, OpenSteerDemo::camera2dElevation, 10);
            OpenSteerDemo::camera.fixedPosition.set (40, 40, 40);
            OpenSteerDemo::camera.mode = Camera::cmFixed;
            m_redScore = 0;
            m_blueScore = 0;
        }

        void update (const float currentTime, const float elapsedTime)
        {
	    // release ball
	    m_Ball->held = false;
            // update simulation of test vehicle
            for(unsigned int i=0; i < m_PlayerCountA ; i++)
                TeamA[i]->update (currentTime, elapsedTime);
            for(unsigned int i=0; i < m_PlayerCountB ; i++)
                TeamB[i]->update (currentTime, elapsedTime);
            m_Ball->update(currentTime, elapsedTime);

            if(m_TeamAGoal->InsideX(m_Ball->position()) && m_TeamAGoal->InsideZ(m_Ball->position()))
            {
                m_Ball->reset();	// Ball in red teams goal, blue scores
                m_blueScore++;
            }
            if(m_TeamBGoal->InsideX(m_Ball->position()) && m_TeamBGoal->InsideZ(m_Ball->position()))
            {
                m_Ball->reset();	// Ball in blue teams goal, red scores
                    m_redScore++;
            }

        }

        void redraw (const float currentTime, const float elapsedTime)
        {
            // draw test vehicle
            for(unsigned int i=0; i < m_PlayerCountA ; i++)
                TeamA[i]->draw ();
            for(unsigned int i=0; i < m_PlayerCountB ; i++)
                TeamB[i]->draw ();
            m_Ball->draw();
            m_bbox->draw();
            m_TeamAGoal->draw();
            m_TeamBGoal->draw();
            {
                std::ostringstream annote;
                annote << "Blue: "<< m_blueScore;
                draw2dTextAt3dLocation (annote, Vec3(23,0,0), Color(0.7f,0.7f,1.0f), drawGetWindowWidth(), drawGetWindowHeight());
            }
            {
                std::ostringstream annote;
                annote << "Red: "<< m_redScore;
                draw2dTextAt3dLocation (annote, Vec3(-23,0,0), Color(1.0f,0.7f,0.7f), drawGetWindowWidth(), drawGetWindowHeight());
            }

            // textual annotation (following the test vehicle's screen position)
    if(0)
        for(unsigned int i=0; i < m_PlayerCountA ; i++)
            {
                std::ostringstream annote;
                annote << std::setprecision (2) << std::setiosflags (std::ios::fixed);
                annote << "      speed: " << TeamA[i]->speed() << "ID:" << i << std::ends;
                draw2dTextAt3dLocation (annote, TeamA[i]->position(), gRed, drawGetWindowWidth(), drawGetWindowHeight());
                draw2dTextAt3dLocation (*"start", Vec3::zero, gGreen, drawGetWindowWidth(), drawGetWindowHeight());
            }
            // update camera, tracking test vehicle
            OpenSteerDemo::updateCamera (currentTime, elapsedTime, *OpenSteerDemo::selectedVehicle);

            // draw "ground plane"
            OpenSteerDemo::gridUtility (Vec3(0,-0.001,0));
        }

        void close (void)
        {
            for(unsigned int i=0; i < m_PlayerCountA ; i++)
                delete TeamA[i];
            TeamA.clear ();
            for(unsigned int i=0; i < m_PlayerCountB ; i++)
                delete TeamB[i];
            TeamB.clear ();
                    m_AllPlayers.clear();
        }

        void reset (void)
        {
            // reset vehicle
            for(unsigned int i=0; i < m_PlayerCountA ; i++)
                TeamA[i]->reset ();
            for(unsigned int i=0; i < m_PlayerCountB ; i++)
                TeamB[i]->reset ();
            m_Ball->reset();
        }

        const AVGroup& allVehicles (void) {return (const AVGroup&) TeamA;}

        unsigned int	m_PlayerCountA;
        unsigned int	m_PlayerCountB;
        std::vector<LuaPlayer*> TeamA;
        std::vector<LuaPlayer*> TeamB;
        std::vector<LuaPlayer*> m_AllPlayers;

        Ball	*m_Ball;
        AABBox	*m_bbox;
        AABBox	*m_TeamAGoal;
        AABBox	*m_TeamBGoal;
        int junk;
        int		m_redScore;
        int		m_blueScore;
    };


    LuaSoccerPlugIn pLuaSoccerPlugIn;




// ----------------------------------------------------------------------------

} // anonymous namespace
