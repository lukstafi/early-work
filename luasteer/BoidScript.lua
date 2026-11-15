-- Boids
-- mailbox and broadcast messaging, no external variables

function reset ()
   -- Randomize initial position
   return Vec3 (math.random () - 0.5, math.random () - 0.5,
		math.random () - 0.5) * 20
end

broadcast = "wanderer"
mailbox = {}

function update ()
   separationRadius =  5.0
   separationAngle  = -0.707
   neighborhoodRadius = 9.0

   -- find all flockmates within maxRadius using proximity database
   neighbors = findNeighbors (my.pos, neighborhoodRadius)

   distance = nil
   if broadcast == "wanderer" or broadcast == "leader" then
      if broadcast == "wanderer" then
	 -- print ("wanderer looks for leader...")
	 steering = steerForWander (2.0)
      elseif broadcast == "leader" then
	 -- print ("leader looks for another leader...")
	 steering = steerForWander (1.0)
	 -- print ("  counting followers: ")
	 count = 0
	 for i, message in ipairs (mailbox) do
	    -- io.stdout:write (message .. "+")
	    count = count + tonumber(message)
	 end
	 mailbox = {}
	 -- io.stdout:write (tostring (followers) .. " = ")
	 followers = followers + count
	 -- io.stdout:write (tostring (followers))
      end
      leader = nil
      foreach_vehicle (neighbors,
		       function (boid)
			  other = receive_broadcast (boid.body)
			  if (other == "leader" or other == "follower")
			     and boid.pos ~= my.pos
			  then
			     new_distance = boid.pos .. my.pos
			     if distance == nil or new_distance < distance then
				leader = boid
				leader_status = other
				distance = new_distance
			     end
			  end
		       end)
      -- case leader == me is excluded by position comparison
      if leader ~= nil
	 and (broadcast == "wanderer" or leader_status == "leader")
      then
	 send_message (leader.body, "1")
	 -- print ("  found leader, following")
	 steering = steerForPursuit (leader.body)
	 if broadcast == "leader" then
	    -- print ("    passing followers to new leader")
	    send_message (leader.body, tostring (followers))
	 elseif broadcast == "wanderer" then
	    -- reset the number of followers
	    followers = 0
	 end
	 broadcast = "follower"
      elseif broadcast == "leader" then
	 if followers > 15 then
	    broadcast = "evader"
	    -- print ("    resigning from leadership")
	    steering = steerForSeparation (separationRadius,
					   separationAngle, neighbors)
	 end
      else
	 broadcast = "leader"
	 followers = 0
	 -- print ("no leader, becoming a leader")
      end
      mailbox = {}
   elseif broadcast == "follower" then
      -- print ("follower performs duties...")
      leader_state = receive_broadcast (leader.body)
      if leader_state == "leader" or leader_state == "follower" then
	 steering = steerForPursuit (leader.body)
	 -- print ("  counting followers: ")
	 count = 0
	 for i, message in ipairs (mailbox) do
	    -- io.stdout:write (message .. "+")
	    count = count + tonumber(message)
	 end
	 mailbox = {}
	 -- io.stdout:write (tostring (followers) .. " = ")
	 followers = followers + count
	 -- io.stdout:write (tostring (followers))
	 -- print ("    passing", count, "followers to leader")
	 send_message (leader.body, tostring (count))
      else
	 -- print ("  no leader, becoming a wanderer")
	 broadcast = "wanderer"
	 steering = steerForWander (2.0)
      end	 
      mailbox = {}
   elseif broadcast == "evader" then
      -- print ("evader looks around...")
      steering = steerForSeparation (separationRadius,
				     separationAngle, neighbors)
      leader = nil
      foreach_vehicle (neighbors,
		       function (boid)
			  other = receive_broadcast (boid.body)
			  if other == "leader" or other == "follower" then
			     leader = boid
			  end
		       end)
      if leader == nil then
	 -- print ("  no leadership in neighborhood, becoming a wanderer")
	 broadcast = "wanderer"
	 steering = steerForWander (2.0)
      end
   end
	  
   if broadcast == "leader"
   then
      social = 
	 steerForCohesion (separationRadius, separationAngle, neighbors)
   else
      social =
	4 * steerForSeparation (separationRadius, separationAngle, neighbors)
   end
   return steering + social
end
