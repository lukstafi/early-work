function reset ()
   return Vec3 (0,0,0)
end

function combinedLookAheadTime (minTime, minDistance)
   if (my.speed == 0) then return 0
   else return math.max (minTime, minDistance / my.speed)
   end
end

-- approximate value for the Polaris Ranger 6x6: 16 feet, 5 meters
minimumTurningRadius = 5.0

function detectImminentCollision ()
   -- QQQ  this should be integrated into steerToAvoidObstaclesOnMap
   -- QQQ  since it shares so much infrastructure
   -- QQQ  less so after changes on 3-16-04
   returnFlag = false
   maxSide = halfWidth + minSpacing / 2
   minDistance = 2.0 -- meters
   predictTime = .75 -- seconds
   minTimeToCol =
      combinedLookAheadTime (predictTime, minDistance)
   
   function map_obstacle (side, dist, pos)
      returnFlag = true
   end
   forObstaclesOnMap (minTimeToCol, maxSide, map_obstacle, map_obstacle)
   return returnFlag
end

pathFollowDirection = "upstream"

function interpolate (alpha, x0, x1)
   return x0 + ((x1 - x0) * alpha)
end

function wingSlope ()
   return interpolate (relativeSpeed (), 0.3, 0.06)
end

lastNearestObstacle = Vec3 (0,0,0)

mw = 0.2

function hintForObstacleAvoidance ()
   -- are we heading roughly parallel to the current path segment?
   pathHeading = mapPointAndDirectionToTangent(path.body, my.pos,
					       pathFollowDirection == "downstream")
   if pathHeading * my.forward < 0.8 then
      -- if not, the "hint" is to turn to align with path heading
      p = my.pos
      s = my.side * halfWidth
      f = halfLength * 2
      annotationLine (p + s, p + s + (my.forward * f), Black)
      annotationLine (p - s, p - s + (my.forward * f), Black)
      annotationLine (p, p + (pathHeading * 5), Magenta)
      return pathHeading
   else
      -- when there is a valid nearest obstacle position
      obstacle = lastNearestObstacle
      o = obstacle + (my.up * 0.1)
      if obstacle ~= Vec3 (0,0,0) then
	 -- get offset, distance from obstacle to its image on path
	 onPath, outside = mapPointToPointOnCenterLineAndOutside(path, obstacle)
	 offset = onPath - obstacle
	 offsetDistance = lenVec (offset)

	 -- when the obstacle is inside the path tube
	 if outside < 0 then
	    -- when near the outer edge of a sufficiently wide tube
	    segmentRadius = mapPointToRadius (path, onPath)
	    w = halfWidth * 6
	    nearEdge = offsetDistance > w
	    wideEnough = segmentRadius > (w * 2)
	    if nearEdge and wideEnough then
	       obstacleDistance = lenVec (obstacle - p)
	       range = speed () * lookAheadTimeOA ()
	       farThreshold = range * 0.8
	       usableHint = obstacleDistance > farThreshold
	       if usableHint then
		  q = p + (normalize (offset) * 5)
		  annotationLine (p, q, Magenta)
		  annotationCircleOrDisk (0.4, my.up, o, White,
					  12, false, false)
		  return offset
	       end
	    end
	 end
 	 annotationCircleOrDisk (0.4, my.up, o, Black, 12,false,false)
      end
   end
   -- otherwise, no hint
   return Vec3 (0,0,0)
end

stuck = false
stuckOffPathCount = 0

hintGivenCount = 0

-- given a map of obstacles (currently a global, binary map) steer so as
-- to avoid collisions within the next minTimeToCollision seconds.
--
function steerToAvoidObstaclesOnMap (minTimeToCollision, steerHint)
   spacing = minSpacing / 2
   maxSide = my.radius
   
   infinity = 2 -- distances are relative to probing distance (in range 0..1)
   nearestL = infinity
   nearestR = infinity
   nearestWL = infinity
   nearestWR = infinity
   wingDrawFlagL = false
   wingDrawFlagR = false

   hintGiven = steerHint ~= Vec3 (0,0,0)
   if hintGiven and not dtZero then hintGivenCount = hintGivenCount + 1 end
   if hintGiven then
      annotationCircleOrDisk (halfWidth * 0.9, my.up,
			      my.pos + (my.up * 0.2),
			      White, 12, false, false)
   end

   -- QQQ temporary global QQQoaJustScraping
   justScraping = true

   function left_obstacle (dist, rel_dist, pos)
      if rel_dist > 0 and rel_dist < nearestL then
	 nearestL = rel_dist
	 if rel_dist < nearestR then nearestO = pos end
      end
      if dist < maxSide then justScraping = false end
   end
   function right_obstacle (dist, rel_dist, pos)
      if rel_dist > 0 and rel_dist < nearestR then
	 nearestR = rel_dist
	 if rel_dist < nearestL then nearestO = pos end
      end
      if dist < maxSide then justScraping = false end
   end
   -- scan corridor straight ahead of vehicle,
   -- keep track of nearest obstacle on left and right sides
   forObstaclesOnMap (minTimeToCol, maxSide, left_obstacle, right_obstacle)

   lastNearestObstacle = nearestO

   -- scan "wings"
   forObstaclesOnMapWings (minTimeToCol, 4, wingSlope (),
			   function (dist, rel_dist, pos)
			      if rel_dist < nearestWL
			      then nearestWL = rel_dist end
			   end,
			   function (side, dist, pos)
			      if rel_dist < nearestWR
			      then nearestWR = rel_dist end
			   end)

   wingDrawFlagL = nearestWL ~= infinity
   wingDrawFlagR = nearestWR ~= infinity

   -- for annotation
   savedNearestWR = nearestWR
   savedNearestR  = nearestR
   savedNearestL  = nearestL
   savedNearestWL = nearestWL

   -- flags for compound conditions, used below
   obstacleFreeC  = nearestL==infinity and nearestR==infinity
   obstacleFreeL  = nearestL==infinity and nearestWL==infinity
   obstacleFreeR  = nearestR==infinity and nearestWR==infinity
   obstacleFreeWL = nearestWL==infinity
   obstacleFreeWR = nearestWR==infinity
   obstacleFreeW  = obstacleFreeWL and obstacleFreeWR

   -- when doing curved steering and we have already detected "just
   -- scarping" but neither wing is free, recind the "just scarping"
   -- QQQ temporary global QQQoaJustScraping
   JS = QQQoaJustScraping
   cancelJS = not obstacleFreeWL and not obstacleFreeWR
   if JS and cancelJS then QQQoaJustScraping = false end


   -- ----------------------------------------------------------
   -- now we have measured everything, decide which way to steer
   -- ----------------------------------------------------------


   -- no obstacles found on path, return zero steering
   if obstacleFreeC then
      lastNearestObstacle = Vec3 (0,0,0)
      annotationNoteOAClauseName ("obstacleFreeC")

      -- qqq  this may be in the wrong place (what would be the right
      -- qqq  place?!) but I'm trying to say "even if the path is
      -- qqq  clear, don't go too fast when driving between obstacles
      if obstacleFreeWL or obstacleFreeWR or relativeSpeed () < 0.7 then
	 return Vec3 (0,0,0)
      else
	 return (-1)*my.forward
      end
   end

   -- if the nearest obstacle is way out there, take hint if any
   if hintGiven and (math.min (nearestL, nearestR) > 0.8) then
      annotationNoteOAClauseName ("nearest obstacle is way out there")
      annotationHintWasTaken ()
      if steerHint * my.side > 0 then return my.side
      else return (-1)*my.side end
   end

   -- QQQ experiment 3-9-04
   --
   -- since there are obstacles ahead, if we are already near
   -- maximum curvature, we MUST turn in opposite direction
   --
   -- are we turning more sharply than the minimum turning radius?
   -- (code from adjustSteeringForMinimumTurningRadius)
   maxCurvature = 1 / (minimumTurningRadius * 1.2)
   if math.abs (curvature (my.body)) > maxCurvature then
      annotationNoteOAClauseName ("min turn radius")
      annotationCircleOrDisk (minimumTurningRadius * 1.2, my.up,
			      center, Blue * 0.8, 40, false, false)
      return my.side * sign
   end
   -- if either side is obstacle-free, turn in that direction
   if obstacleFreeL or obstacleFreeR then
      annotationNoteOAClauseName ("obstacle-free side") end

   if obstacleFreeL then return my.side end
   if obstacleFreeR then return (-1)*my.side end

   -- if wings are clear, turn away from nearest obstacle straight ahead
   if obstacleFreeW then
      annotationNoteOAClauseName ("obstacleFreeW")
      -- distance to obs on L and R side of corridor roughtly the same
      same = math.abs (nearestL - nearestR) < 5  -- within 5
      -- if they are about the same and a hint is given, use hint
      if same and hintGiven then
	 annotationHintWasTaken ()
	 if steerHint * my.side > 0 then return my.side
	 else return (-1)*my.side end
      else
	 -- otherwise steer toward the less cluttered side
	 if nearestL > nearestR then return my.side
	 else return (-1)*my.side end
      end
   end

   -- if the two wings are about equally clear and a steering hint is
   -- provided, use it
   equallyClear = math.abs (nearestWL-nearestWR) < 2  -- within 2
   if equallyClear and hintGiven then
      annotationNoteOAClauseName ("equallyClear")
      annotationHintWasTaken ()
      if steerHint * my.side > 0 then return my.side
      else return (-1)*my.side
      end
   end
   
   -- turn towards the side whose "wing" region is less cluttered
   -- (the wing whose nearest obstacle is furthest away)
   annotationNoteOAClauseName ("wing less cluttered")
   if nearestWL > nearestWR then return my.side
   else return (-1)*my.side end
end

baseLookAheadTime = 3

function lookAheadTimeOA ()
   minTime = (baseLookAheadTime *
	      interpolate (relativeSpeed(), 0.4, 0.7))
   return combinedLookAheadTime (minTime, 3)
end
function lookAheadTimePF ()
   return combinedLookAheadTime (baseLookAheadTime, 3)
end

function relativeSpeed ()
   return my.speed / my.maxSpeed
end

function steerTowardHeading (desiredGlobalHeading)
   headingError = desiredGlobalHeading - my.forward
   return normalize(headingError) * my.maxForce
end

function resetStuckCycleDetection ()
   resetSmoothedPosition (my.pos + (my.forward * -80)) -- qqq
end

-- QQQ just a stop gap, not quite right
-- (say for example we were going around a circle with radius > 10)
function weAreGoingInCircles ()
   offset = smoothedPosition (my.body) - my.pos
   return lenVec (offset) < 10
end

function update (elapsedTime, offPath)
   -- determine combined steering
   steering = Vec3 (0,0,0)
   braking = 0
   if stuck or offPath or detectImminentCollision () then
      -- bring vehicle to a stop if we are stuck (newly or previously
      -- stuck, because off path or collision seemed imminent)
      -- (QQQ combine with stuckCycleCount code at end of this function?)
      if not stuck then print ("We are stuck! offPath = ", offPath, "braking force = ", 3) end
      braking = 3
      -- count "off path" events
      if offPath and not stuck then
	 stuckOffPathCount = stuckOffPathCount + 1
      end
      stuck = true

      -- QQQ trying to prevent "creep" during emergency stops
      resetSmoothedAcceleration (my.body, Vec3 (0,0,0))
      -- currentSteering = Vec3 (0,0,0)
   else
      -- determine steering for obstacle avoidance (save for annotation)
      avoid = steerToAvoidObstaclesOnMap (lookAheadTimeOA (),
					  hintForObstacleAvoidance ())
      annotateAvoid = avoid
                -- any obstacles to avoid?
      if avoid ~= Vec3 (0,0,0) then
	 print ("Avoiding obstacle! justScraping = ", justScraping)
	 -- slow down and turn to avoid the obstacles
	 if justScraping then
	    targetSpeed = maxSpeedForCurvature (0.2)
	 else
	    targetSpeed = maxSpeedForCurvature (0)
	 end
	 annoteMaxRelSpeed = targetSpeed / my.maxSpeed
	 avoidWeight = 3 + (3 * relativeSpeed ()) -- ad hoc
	 steering = avoid * avoidWeight
	 steering = steering + steerForTargetSpeed (targetSpeed)
      else
	 -- otherwise speed up and...
	 steering = steerForTargetSpeed (maxSpeedForCurvature (mw))

	 -- follow the path
	 pf = path.steerToFollowPath (pathFollowDirection,
				 lookAheadTimePF ())
	 if pf ~= Vec3 (0,0,0) then
	    print ("Following path! pf*my.forward = ", pf * my.forward)
	    -- steer to remain on path
	    if pf * my.forward < 0 then
	       steering = pf
	    else
	       steering = pf + steering
	    end
	 else
	    -- path aligment: when neither obstacle avoidance nor
	    -- path following is required, align with path segment
	    pathHeading = mapPointAndDirectionToTangent(path.body, my.pos, pathFollowDirection == "downstream")
	    b = (my.pos +
		 (my.up * 0.2) +
		    (my.forward * halfLength * 1.4))
	    l = 2
	    annotationLine (b, b + (my.forward  * l), Cyan)
	    annotationLine (b, b + (pathHeading * l), Cyan)
	    if isNearWaypoint(path.body, my.pos) then
	       headingWeight = 0.5 else headingWeight = 0.1 end
	    steering = steering +
	       steerTowardHeading(pathHeading) * headingWeight
	 end
      end
   end
   -- detect getting stuck in cycles -- we are moving but not
   -- making progress down the route (annotate smoothedPosition)
   circles = weAreGoingInCircles ()
   if circles and not stuck then
      print ("We are moving in circles!")
      stuckCycleCount = stuckCycleCount + 1 end
   if circles then stuck = true end
   annotationCircleOrDisk (0.5, my.up, smoothedPosition (my.body),
			   White, 12, circles, false)
   return steering, braking
end