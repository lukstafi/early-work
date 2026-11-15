-- Red Team
-- external variables: agentID myGoal opGoal myTop myBottom opTop opBottom
--                     allPlayers myTeam opTeam

state = "kick"

function reset ()
   if math.mod (playerID, 2) == 0
   then
      return (playerID / 20) * (myTop - opBottom)
   else return (playerID / 20) * (myBottom - opTop)
   end
end

function update (ball)
   collision = steerToAvoidNeighbors (1, allPlayers)

   if collision ~= Vec3 (0,0,0) then return collision
   elseif (ball.pos - my.pos) * (myGoal - my.pos) < 0
   then
      getball = ball.pos - (2 * normalize (myGoal - ball.pos))
      seek_ball = steerForPursuit (ball.body) + steerForSeek (getball)
      if playerID > 3 then
	 if ball.pos .. myGoal > (opGoal .. myGoal) / 3
	 then
	    if normalize (ball.pos - my.pos) *
	       normalize (opGoal - my.pos) > 0.5
	    then return 3 * steerForPursuit (ball.body)
	    else return seek_ball
	    end
	 else return steerForSeek (myGoal + 0.5 * (ball.pos - myGoal))
	 end
      else
	 if ball.pos .. myGoal < (opGoal .. myGoal) / 2
	 then return seek_ball
	 else
	    return steerForSeek (myGoal + 0.3 * (ball.pos - myGoal))
	       + steerForSeparation (9.0, -0.5, myTeam)
	 end
      end
   else
      delta = 3 * ball.side
      if ball.pos + delta .. my.pos < ball.pos - delta .. my.pos
      then ballside = ball.pos + delta
      else ballside = ball.pos - delta end
      return steerForSeek (ballside) + steerForSeek (myGoal)
   end
end
