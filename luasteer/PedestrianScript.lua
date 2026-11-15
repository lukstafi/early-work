function reset ()
   -- pick a random direction for path following (upstream or downstream)
   if math.mod (math.random (10), 2) == 0
   then pathDirection = "upstream"
   else pathDirection = "downstream" end

   -- set initial position
   -- (random point on path + random horizontal offset)
   d = path.length * math.random()
   r = path.radiusAtDistance(d)
   randomOffset = randomVectorOnUnitRadiusXZDisk () * r
   return path.mapPathDistanceToPoint (d) + randomOffset
end

function update (wanderSwitch, elapsedTime)
   -- move forward
   steeringForce = my.forward

   -- probability that a lower priority behavior will be given a
   -- chance to "drive" even if a higher priority behavior might
   -- otherwise be triggered.
   leakThrough = 0.1

   -- determine if obstacle avoidance is required
   obstacleAvoidance = nil
   if leakThrough < math.random() then
      oTime = 6			-- minTimeToCollision = 6 seconds
      obstacleAvoidance = steerToAvoidObstacles (oTime, obstacles)
   end

   -- if obstacle avoidance is needed, do it
   if obstacleAvoidance ~= nil and obstacleAvoidance ~= Vec3(0,0,0) then
      steeringForce = steeringForce + obstacleAvoidance
   else
      -- otherwise consider avoiding collisions with others
      collisionAvoidance = nil
      caLeadTime = 3

      -- find all neighbors within maxRadius using proximity database
      -- (radius is largest distance between vehicles traveling head-on
      -- where a collision is possible within caLeadTime seconds.)
      maxRadius = caLeadTime * my.maxSpeed * 2
      neighbors = findNeighbors (my.pos, maxRadius)

      if leakThrough < math.random() then
	 collisionAvoidance =
	    steerToAvoidNeighbors (caLeadTime, neighbors) * 10
      end

      -- if collision avoidance is needed, do it
      if collisionAvoidance ~= nil and collisionAvoidance ~= Vec3(0,0,0) then
	 steeringForce = steeringForce + collisionAvoidance
      else
	 -- add in wander component (according to user switch)
	 if wanderSwitch then
	    steeringForce = steeringForce + steerForWander (elapsedTime)
	 end
	 -- do (interactively) selected type of path following
	 pfLeadTime = 3
	 if directedPathFollowing then
	    pathFollow = path.steerToFollowPath (pathDirection, pfLeadTime)
	 else
	    pathFollow = path.steerToStayOnPath (pfLeadTime)
	 end
	 -- add in to steeringForce
	 steeringForce = steeringForce + pathFollow * 0.5
      end
   end
   return steeringForce
end   