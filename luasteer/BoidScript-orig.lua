-- Boids
-- no external variables

function reset ()
   -- Randomize initial position
   return Vec3 (math.random () - 0.5, math.random () - 0.5,
		math.random () - 0.5) * 20
end

function update ()
   separationRadius =  5.0
   separationAngle  = -0.707
   separationWeight =  12.0

   alignmentRadius = 7.5
   alignmentAngle  = 0.7
   alignmentWeight = 8.0

   cohesionRadius = 9.0
   cohesionAngle  = -0.15
   cohesionWeight = 8.0

   maxRadius = math.max (separationRadius,
			 math.max (alignmentRadius, cohesionRadius))

   -- find all flockmates within maxRadius using proximity database
   neighbors = findNeighbors (my.pos, maxRadius)
   -- determine each of the three component behaviors of flocking
   separation = steerForSeparation (separationRadius,
				    separationAngle, neighbors)
   alignment  = steerForAlignment  (alignmentRadius,
				    alignmentAngle, neighbors)
   cohesion   = steerForCohesion   (cohesionRadius,
				    cohesionAngle, neighbors)

   -- apply weights to components (save in variables for annotation)
   separationW = separation * separationWeight
   alignmentW = alignment * alignmentWeight
   cohesionW = cohesion * cohesionWeight

   return separationW + alignmentW + cohesionW
end
