-- Blue Team
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
      if playerID > 3 then
	 if ball.pos .. myGoal > (opGoal .. myGoal) / 3
	 then return steerForSeek (ball.pos)
	 else return steerForSeek (myGoal)
	 end
      else
	 if ball.pos .. myGoal < (opGoal .. myGoal) / 2
	 then return steerForSeek (ball.pos)
	 else return steerForSeek (myGoal)
	 end
      end
   else return steerForSeek (ball.pos + ball.side) + steerForSeek (myGoal)
   end
end
