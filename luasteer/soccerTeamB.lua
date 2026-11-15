-- Blue Team
-- external variables: agentID myGoal opGoal myTop myBottom opTop opBottom
--                     allPlayers myTeam opTeam

state = "keep ball"
if playerID > 3 then
   broadcast = "attacker"
else
   broadcast = "back"
end

function reset ()
   if math.mod (playerID, 2) == 0
   then
      return (playerID / 20) * (myTop - opBottom)
   else return (playerID / 20) * (myBottom - opTop)
   end
end

function fill_dir_table (team, ball)
   local free_shot = true
   local ball_dist = nil
   local ball_closer = nil
   local dirs_right = {}
   local dirs_left = {}
   function fill_in_player (player)
      if player.pos ~= my.pos then
	 if ball_dist == nil or player.pos .. ball.pos < ball_dist then
	    ball_dist = player.pos .. ball.pos
	    ball_closer = player
	 end
	 dir = normalize (player.pos - my.pos)
	 dir_index = math.floor (dir * my.forward * 10)
	 if dir * my.side > 0 then
	    if dirs_right [dir_index] == nil or
	       dirs_right [dir_index].pos .. my.pos >
	       player.pos .. my.pos
	    then dirs_right [dir_index] = player
	    end
	 else
	    if dirs_left [dir_index] == nil or
	       dirs_left [dir_index].pos .. my.pos >
	       player.pos .. my.pos
	    then dirs_left [dir_index] = player
	    end
	 end
	 if dir * normalize (opGoal - my.pos) > 0.8
	 then free_shot = false
	 end
      end
   end
   foreach_vehicle (opTeam, fill_in_player)
   return dirs_right, dirs_left, ball_closer, free_shot
end

function steerForKick (have_ball, goal)
   action = "steerForKick"
   state = "keep ball"
   if goal == nil then goal = steerTarget
   else steerTarget = goal end

   if normalize (my.pos - goal) * my.forward < 0.8 then
      -- makes state = "keep ball"
      if goal * my.side > 0 then return my.side - 0.5 * my.forward
      else
	 return (-1) * my.side - (0.5 * my.forward)
      end
   elseif have_ball then
      state = "kick"
      action = nil
      return steerForSeek (goal)
   else
      state = "keep ball"
      action = nil
      return -0.5 * my.forward
   end
end

function steerForFreeKick (dirs, side)
   for i = 10, 0, 1 do
      if dirs[i] == nil then
	 return steerForKick (true, side*((10-i)/10))
      end
   end
   return steerForKick (true, opGoal)
end

function update (ball)
   collision = steerToAvoidNeighbors (1, allPlayers)
   if collision ~= Vec3 (0,0,0) then return collision
   elseif action == nil then
      op_dirs = {}
      my_dirs = {}
      op_dirs[1], op_dirs[2], op_at_ball, free_shot =
	 fill_dir_table (opTeam, ball)
      my_dirs[1], my_dirs[2], our_at_ball =
	 fill_dir_table (myTeam, ball)
      have_ball = my.pos .. ball.pos < my.radius + ball.radius
      if have_ball and free_shot then
	    return steerForKick (have_ball, opGoal)
      elseif not have_ball and free_shot
	 and op_at_ball.pos .. ball.pos > our_at_ball.pos .. ball.pos
      then
	 -- prepare to receive ball
	 broadcast = "free shot"
	 return steerForKick (have_ball, opGoal)
      elseif have_ball and not free_shot then
	 -- find someone to pass the ball
	 broadcast = "passing ball"
	 for s = 1, 2 do
	    for i = -10, 10 do
	       if my_dirs[s][i] ~= nil and
		  (op_dirs[s][i] == nil or
		   my_dirs[s][i].pos .. my.pos
		      < op_dirs[s][i].pos .. my.pos) and
		  receive_broadcast (my_dirs[s][i].body) == "free shot"
	       then
		  return steerForKick (have_ball, my_dirs[s][i].pos)
	       end
	    end
	 end
	 -- no one, find a free slot ahead
	 goal_vec = normalize (opGoal - my.pos)
	 if goal_vec * my.side > 0 then goal_s = 1 else goal_s = 2 end
	 return steerForFreeKick (op_dirs[goal_s],
				  (1-2*(goal_s-1))*my.side)
      else
	 state = "keep ball"
	 if free_shot then broadcast = "free shot"
	 else broadcast = "going for ball" end
	 if (ball.pos - my.pos) * (myGoal - my.pos) < 0
	 then return steerForPursuit (ball.body)
	 else
	    if my.pos .. ball.pos < 2*(my.radius+ball.radius) then
	       delta = (-0.1)*steerForPursuit (ball.body)
	    else
	       delta = (ball.pos - myGoal) / 2
	    end
	    return steerForSeek (myGoal + delta)
	    
	 end
      end
   elseif action == "steerForKick" then
      have_ball = my.pos .. ball.pos < my.radius + ball.radius
      return steerForKick (have_ball)
   end
end
