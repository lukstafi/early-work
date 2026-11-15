    open Ode

  type t

    (** Set the mass parameters to the given values. themass is the mass
	of the body. (cgx,cgy,cgz) is the center of gravity position in the
	body frame. The ixx values are the elements of the inertia matrix:
	[ i11 i12 i13 ]
	[ i12 i22 i23 ]
	[ i13 i23 i33 ] *)
  external create : themass:float -> cgx:float -> cgy:float
    -> cgz:float -> i11:float -> i22:float -> i33:float
    -> i12:float -> i13:float -> i23:float -> unit
    = "ml_dCreateMass_bc" "ml_dCreateMass"
  external set_parameters : t -> themass:float -> cgx:float -> cgy:float
    -> cgz:float -> i11:float -> i22:float -> i33:float
    -> i12:float -> i13:float -> i23:float -> unit
    = "ml_dMassSetParameters_bc" "ml_dMassSetParameters"

  (** Set all the mass parameters to zero. *)
  external set_zero : t -> unit
    = "ml_dMassSetZero"

(** Set the mass parameters to represent a sphere of the given radius
    and density, with the center of mass at (0,0,0) relative to the
    body. The first function accepts the density of the sphere, the
    second accepts the total mass of the sphere. *)
  external sphere : density:float -> radius:float -> t
    = "ml_create_dMassSetSphere"
  external set_sphere : t -> density:float -> radius:float -> unit
    = "ml_dMassSetSphere"
  external sphere_total : mass:float -> radius:float -> t
    = "ml_create_dMassSetSphereTotal"
  external set_sphere_total : t -> mass:float -> radius:float -> unit
    = "ml_dMassSetSphereTotal"

  type direction = X | Y | Z
      
  (** Set the mass parameters to represent a capped cylinder of the
      given parameters and density, with the center of mass at (0,0,0)
      relative to the body. The radius of the cylinder (and the spherical
      cap) is radius. The length of the cylinder (not counting the
      spherical cap) is length. The cylinder's long axis is oriented
      along the body's x, y or z axis according to the value of direction.
      The first function accepts the density of the
      object, the second accepts its total mass. *)
  external capped_cylinder : density:float -> direction
    -> radius:float -> length:float -> t
    = "ml_create_dMassSetCappedCylinder"
  external set_capped_cylinder : t -> density:float -> direction
    -> radius:float -> length:float -> unit
    = "ml_dMassSetCappedCylinder"
  external capped_cylinder_total : mass:float -> direction
    -> radius:float -> length:float -> t
    = "ml_create_dMassSetCappedCylinderTotal"
  external set_capped_cylinder_total : t -> mass:float -> direction
    -> radius:float -> length:float -> unit
    = "ml_dMassSetCappedCylinderTotal"

  (** Set the mass parameters to represent a flat-ended cylinder of
      the given parameters and density, with the center of mass at
      (0,0,0) relative to the body. The radius of the cylinder is
      radius. The length of the cylinder is length. The cylinder's long
      axis is oriented along the body's x, y or z axis according to the
      value of direction (1=x, 2=y, 3=z). The first function accepts the
      density of the object, the second accepts its total mass. *)
  external cylinder : density:float -> direction
    -> radius:float -> length:float -> t
    = "ml_create_dMassSetCylinder"
  external set_cylinder : t -> density:float -> direction
    -> radius:float -> length:float -> unit
    = "ml_dMassSetCylinder"
  external cylinder_total : mass:float -> direction
    -> radius:float -> length:float -> t
    = "ml_create_dMassSetCylinderTotal"
  external set_cylinder_total : t -> mass:float -> direction
    -> radius:float -> length:float -> unit
    = "ml_dMassSetCylinderTotal"

  (** Set the mass parameters to represent a box of the given dimensions
      and density, with the center of mass at (0,0,0) relative to the
      body. The side lengths of the box along the x, y and z axes are
      lx, ly and lz. The first function accepts the density of the
      object, the second accepts its total mass. *)
  external box : density:float -> lx:float -> ly:float -> lz:float
    -> t = "ml_create_dMassSetBox"
  external set_box : t-> density:float -> lx:float -> ly:float -> lz:float
    -> unit = "ml_dMassSetBox"
  external box_total : mass:float -> lx:float -> ly:float -> lz:float
    -> t = "ml_create_dMassSetBoxTotal"
  external set_box_total : t-> mass:float -> lx:float -> ly:float
    -> lz:float -> unit = "ml_dMassSetBoxTotal"

  (** Given mass parameters for some object, adjust them so the total
      mass is now newmass. *)
  external adjust : t -> newmass:float -> unit
    = "ml_dMassAdjust"

  (** Given mass parameters for some object, adjust them to represent
      the object displaced by (x,y,z) relative to the body frame. *)
  external translate : t -> x:float -> y:float -> z:float -> unit
    = "ml_dMassTranslate"
  (** Given mass parameters for some object, adjust them to represent
      the object rotated by matrix3 relative to the body frame. *)
  external rotate : t -> matrix3 -> unit
    = "ml_dMassRotate"
  (** Add the second mass to the first mass. *)
  external add : t -> t -> unit
    = "ml_dMassAdd"
  external set : Body.t -> t -> unit
    = "ml_dBodySetMass"
  external of_body : Body.t -> t
    = "ml_dBodyGetMass"

  (** total mass of the rigid body *)
  external mass : t -> float
    = "ml_dMass_mass"

  (** enter of gravity position in body frame (x,y,z) *)
  external cog : t -> vector3
    = "ml_dMass_cog"

  (** 3x3 inertia tensor in body frame, about POR *)
  external inertia : t -> matrix3
    = "ml_dMass_I"
