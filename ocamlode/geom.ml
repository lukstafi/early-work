    open Ode

  type 'a t

  external destroy : 'a t -> unit
    = "ml_dGeomDestroy"

  type 'a placeable_t
  type 'a space_t
  type 'a placeable = 'a placeable_t t
  type 'a space = 'a space_t t

  (** These functions set and get the body associated with a placeable
      geom. Setting a body on a geom automatically combines the position
      vector and rotation matrix of the body and geom, so that setting the
      position or orientation of one will set the value for both objects.

      Setting [None] gives the geom its own position and rotation,
      independent from any body. If the geom was previously connected
      to a body then its new independent position/rotation is set to
      the current position/rotation of the body. *)
  external set_body : 'a placeable -> Body.t option -> unit
    = "ml_dGeomSetBody"
  external get_body : 'a placeable -> Body.t option
    = "ml_dGeomGetBody"

  (** Set the position vector, rotation matrix or quaternion of a
      placeable geom. These functions are analogous to
      {!Body.set_position}, {!Body.set_rotation} and
      {!Body.set_quaternion}. If the geom is attached to a body, the
      body's position / rotation / quaternion will also be changed. *)
  external set_position : 'a placeable -> x:float -> y:float ->
    z:float -> unit
    = "ml_dGeomSetPosition"
  external set_rotation : 'a placeable -> matrix3 -> unit
    = "ml_dGeomSetRotation"
  external set_quaternion : 'a placeable -> quaternion -> unit
    = "ml_dGeomSetQuaternion"

  (** If the geom is attached to a body, the body's position /
      rotation / quaternion values will be returned, i.e. the result
      will be identical to calling {!Body.set_position},
      {!Body.set_rotation} and {!Body.set_quaternion}. *)
  external get_position : 'a placeable -> vector3
    = "ml_dGeomGetPosition"
  external get_rotation : 'a placeable -> matrix3
    = "ml_dGeomGetRotation"
  external get_quaternion : 'a placeable -> quaternion
    = "ml_dGeomGetQuaternion"

  (** Return in aabb an axis aligned bounding box that surrounds the
      given geom. If the geom is a space, a bounding box that surrounds all
      contained geoms is returned.

      This function may return a pre-computed cached bounding box, if it
      can determine that the geom has not moved since the last time the
      bounding box was computed. *)
  external get_AABB : 'a t -> aabb
    = "ml_dGeomGetAABB"

  (* keep in sync with "common.h" enumeration *)
  type classes =
      [ `Sphere_c
      | `Box_c
      | `CCylinder_c
      | `Cylinder_c
      | `Plane_c
      | `Ray_c
      | `Transform_c
      | `TriMesh_c
      | `Simple_space_c
      | `Hash_space_c
      | `QuadTree_space_c
      | `User_placeable_c of int
      | `User_space_c of int
      | `User_c of int]

  type placeable_classes =
      [ `Sphere_c
      | `Box_c
      | `CCylinder_c
      | `Cylinder_c
      | `Ray_c
      | `Transform_c
      | `TriMesh_c
      | `User_placeable_c of int]

  type space_classes =
      [ `Simple_space_c
      | `Hash_space_c
      | `QuadTree_space_c
      | `User_space_c of int]
	
  type sphere_t
  type box_t
  type ccylinder_t
  type cylinder_t
  type plane_t
  type ray_t
  type transform_t
  type trimesh_t
  type simple_space_t
  type hash_space_t
  type quadtree_space_t

  type unknown_t

  type sphere = sphere_t placeable
  type box = box_t placeable
      (** Capped cylinder *)
  type ccylinder = ccylinder_t placeable
      (** Regular flat-ended cylinder *)
  type cylinder = cylinder_t placeable
      (** Infinite plane *)
  type plane = plane_t t

  (** A ray is different from all the other geom classes in that it does
      not represent a solid object. It is an infinitely thin line that
      starts from the geom's position and extends in the direction of the
      geom's local Z-axis.

      Calling {!Geom.collide} between a ray and another geom will result in
      at most one contact point. Rays have their own conventions for
      the contact information in the dContactGeom structure (thus it
      is not useful to create contact joints from this information):

      pos - This is the point at which the ray intersects the surface
      of the other geom, regardless of whether the ray starts from
      inside or outside the geom.

      normal - This is the surface normal of the other geom at the
      contact point. if dCollide is passed the ray as its first geom
      then the normal will be oriented correctly for ray reflection
      from that surface (otherwise it will have the opposite sign).

      depth - This is the distance from the start of the ray to the
      contact point.

      Rays are useful for things like visibility testing, determining
      the path of projectiles or light rays, and for object placement. *)
  type ray = ray_t placeable

  (** A geometry transform `T' is a geom that encapsulates another
      geom `E', allowing E to be positioned and rotated arbitrarily with
      respect to its point of reference.

      Most placeable geoms (like the sphere and box) have their point
      of reference corresponding to their center of mass, allowing
      them to be easily connected to dynamics objects. Transform
      objects give you more flexibility - for example, you can offset
      the center of a sphere, or rotate a cylinder so that its axis is
      something other than the default.

      T mimics the object E that it encapsulates: T is inserted into a
      space and attached to a body as though it was E. E itself must
      not be inserted into a space or attached to a body. E's position
      and rotation are set to constant values that say how it is
      transformed relative to T. If E's position and rotation are left
      at their default values, T will behave exactly like E would have
      if you had used it directly. *)
  type transform = transform_t placeable
      (** Triangle mesh *)
  type trimesh = trimesh_t placeable

  (** Simple space. This does not do any collision culling - it simply
      checks every possible pair of geoms for intersection, and reports
      the pairs whose AABBs overlap. The time required to do intersection
      testing for n objects is O(n2). This should not be used for large
      numbers of objects, but it can be the preferred algorithm for a
      small number of objects. This is also useful for debugging potential
      problems with the collision system. *)
  type simple_space = simple_space_t space

  (** Multi-resolution hash table space. This uses an internal data
      structure that records how each geom overlaps cells in one of
      several three dimensional grids. Each grid has cubical cells of side
      lengths 2i, where i is an integer that ranges from a minimum to a
      maximum value. The time required to do intersection testing for n
      objects is O(n) (as long as those objects are not clustered together
      too closely), as each object can be quickly paired with the objects
      around it. *)
  type hash_space = hash_space_t space

  (** Quadtree space. This uses a pre-allocated hierarchical
      grid-based AABB tree to quickly cull collision checks. It's
      exceptionally quick for large amounts of objects in landscape-shaped
      worlds. The amount of memory used is 4^depth * 32 bytes. Currently
      {!Geom.space_nth_geom} is not implemented for the quadtree space. *)
  type quadtree_space = quadtree_space_t space

  type some = unknown_t t
  type some_placeable = unknown_t placeable
  type some_space = unknown_t space
      
  type geom =
    [ `Sphere of sphere
    | `Box of box
    | `CCylinder of ccylinder
    | `Cylinder of cylinder
    | `Plane of plane
    | `Ray of ray
    | `Transform of transform
    | `TriMesh of trimesh
    | `Simple of simple_space
    | `Hash of hash_space
    | `QuadTree of quadtree_space
    | `User_placeable of some_placeable
    | `User_space of some_space
    | `User_class of some]

  type placeable_geom =
    [ `Sphere of sphere
    | `Box of box
    | `CCylinder of ccylinder
    | `Cylinder of cylinder
    | `Ray of ray
    | `Transform of transform
    | `TriMesh of trimesh
    | `User_paceable of some_placeable]

  type space_geom =
    [ `Simple of simple_space
    | `Hash of hash_space
    | `QuadTree of quadtree_space
    | `User_space of some_space]

  exception Type_mismatch of string

  let unpack = function
      `Sphere sphere -> ((Obj.magic sphere) : some)
    | `Box box -> ((Obj.magic box) : some)
    | `CCylinder ccylinder -> ((Obj.magic ccylinder) : some)
    | `Cylinder cylinder -> ((Obj.magic cylinder) : some)
    | `Plane plane -> ((Obj.magic plane) : some)
    | `Ray ray -> ((Obj.magic ray) : some)
    | `Transform transform -> ((Obj.magic transform) : some)
    | `TriMesh trimesh -> ((Obj.magic trimesh) : some)
    | `Simple simple_space -> ((Obj.magic simple_space) : some)
    | `Hash hash_space -> ((Obj.magic hash_space) : some)
    | `QuadTree quadtree_space -> ((Obj.magic quadtree_space) : some)
    | `User_placeable some_placeable ->  ((Obj.magic some_placeable) : some)
    | `User_space some_space ->  ((Obj.magic some_space) : some)
    | `User_class some -> some

  let unpack_placeable = function
      `Sphere sphere -> ((Obj.magic sphere) : some_placeable)
    | `Box box -> ((Obj.magic box) : some_placeable)
    | `CCylinder ccylinder -> ((Obj.magic ccylinder) : some_placeable)
    | `Cylinder cylinder -> ((Obj.magic cylinder) : some_placeable)
    | `Ray ray -> ((Obj.magic ray) : some_placeable)
    | `Transform transform -> ((Obj.magic transform) : some_placeable)
    | `TriMesh trimesh -> ((Obj.magic trimesh) : some_placeable)
    | `User_placeable some -> some

  let unpack_space = function
    | `Simple simple_space -> ((Obj.magic simple_space) : some_space)
    | `Hash hash_space -> ((Obj.magic hash_space) : some_space)
    | `QuadTree quadtree_space ->
	((Obj.magic quadtree_space) : some_space)
    | `User_space some -> some

  (** comparison works on the whole class of geoms *)
  external eq : 'a t -> 'b t -> bool
    = "ml_dGeom_eq"
  external compare : 'a t -> 'b t -> int
    = "ml_dGeom_compare"

  (** If type information is no longer needed, there's no need to pack a
      concrete geom into the universal geom type *)
  let some (g : 'a t) = ((Obj.magic g) : some)
  let placeable (g : 'a placeable) =  ((Obj.magic g) : some_placeable)
  let space (g : 'a space) = ((Obj.magic g) : some_space)

  external is_space : 'a t -> bool
    = "ml_dGeomIsSpace"
  external get_space : 'a t -> some_space option
    = "ml_dGeomGetSpace"

  external internal_get_class : 'a t -> int 
    = "ml_dGeomGetClass"
    (* keep in sync with ode/include/collision.h *)
  let get_class g =
    match internal_get_class g with
	0 -> `Sphere_c
      | 1 -> `Box_c
      | 2 -> `CCylinder_c
      | 3 -> `Cylinder_c
      | 4 -> `Plane_c
      | 5 -> `Ray_c
      | 6 ->`Transform_c
      | 7 -> `TriMesh_c
      | 8 -> `Simple_space_c
      | 9 -> `Hash_space_c
      | 10 -> `QuadTree_space_c
      | n -> `User_c n
  let get_placeable_class (g : 'a placeable) =
    match internal_get_class g with
	0 -> `Sphere_c
      | 1 -> `Box_c
      | 2 -> `CCylinder_c
      | 3 -> `Cylinder_c
      | 5 -> `Ray_c
      | 6 ->`Transform_c
      | 7 -> `TriMesh_c
      | n -> `User_placeable_c n
  let get_space_class (g : 'a space) =
    match internal_get_class g with
      | 8 -> `Simple_space_c
      | 9 -> `Hash_space_c
      | 10 -> `QuadTree_space_c
      | n -> `User_space_c n

  let type_geom g =
    match get_class g with
	`Sphere_c -> `Sphere (Obj.magic g)
      | `Box_c -> `Box (Obj.magic g)
      | `CCylinder_c -> `CCylinder (Obj.magic g)
      | `Cylinder_c -> `Cylinder (Obj.magic g)
      | `Plane_c -> `Plane (Obj.magic g)
      | `Ray_c -> `Ray (Obj.magic g)
      | `Transform_c -> `Transform (Obj.magic g)
      | `TriMesh_c -> `TriMesh (Obj.magic g)
      | `Simple_space_c -> `Simple (Obj.magic g)
      | `Hash_space_c -> `Hash (Obj.magic g)
      | `QuadTree_space_c -> `QuadTree (Obj.magic g)
      | `User_c n -> `User_class (Obj.magic g)

  let nop s _ = raise (Type_mismatch s)

  let type_placeable (g : 'a placeable) =
    match get_placeable_class g with
	`Sphere_c -> `Sphere (Obj.magic g)
      | `Box_c -> `Box (Obj.magic g)
      | `CCylinder_c -> `CCylinder (Obj.magic g)
      | `Cylinder_c -> `Cylinder (Obj.magic g)
      | `Ray_c -> `Ray (Obj.magic g)
      | `Transform_c -> `Transform (Obj.magic g)
      | `TriMesh_c -> `TriMesh (Obj.magic g)
      | `User_placeable_c n -> `User_placeable (Obj.magic g)

  let match_type g ?(sphere : sphere -> 'a =(nop "sphere"))
      ?(box : box -> 'a =(nop "box"))
      ?(ccylinder : ccylinder -> 'a =(nop "ccylinder"))
      ?(cylinder : cylinder -> 'a =(nop "cylinder"))
      ?(plane : plane -> 'a =(nop "plane"))
      ?(ray : ray -> 'a =(nop "ray"))
      ?(transform : transform -> 'a =(nop "transform"))
      ?(trimesh : trimesh -> 'a =(nop "trimesh"))
      ?(simple : simple_space -> 'a =(nop "simple"))
      ?(hash : hash_space -> 'a =(nop "hash space"))
      ?(quadtree : quadtree_space -> 'a = (nop "quadtree space"))
      ?(userclass : int -> some -> 'a = (fun _ -> nop "user class"))() =
    match get_class g with
	`Sphere_c -> sphere (Obj.magic g)
      | `Box_c -> box (Obj.magic g)
      | `CCylinder_c -> ccylinder (Obj.magic g)
      | `Cylinder_c -> cylinder (Obj.magic g)
      | `Plane_c -> plane (Obj.magic g)
      | `Ray_c -> ray (Obj.magic g)
      | `Transform_c -> transform (Obj.magic g)
      | `TriMesh_c -> trimesh (Obj.magic g)
      | `Simple_space_c -> simple (Obj.magic g)
      | `Hash_space_c -> hash (Obj.magic g)
      | `QuadTree_space_c -> quadtree (Obj.magic g)
      | `User_c n -> userclass n (Obj.magic g)

  let match_kind g ?sphere
      ?box
      ?ccylinder
      ?cylinder
      ?plane
      ?ray
      ?transform
      ?trimesh
      ?placeable
      ?simple
      ?hash
      ?quadtree
      ?space
      ?default () =
    let nop s = match default with
	Some f -> f ((Obj.magic g) : some)
      | None -> nop s s in
    match get_class g with
	`Sphere_c -> (match sphere with
	    Some f -> f ((Obj.magic g) : sphere)
	  | None -> match placeable with
		Some f -> f ((Obj.magic g) : some_placeable)
	      | None -> nop "sphere")
      | `Box_c -> (match box with
	    Some f -> f ((Obj.magic g) : box)
	  | None -> match placeable with
		Some f -> f ((Obj.magic g) : some_placeable)
	      | None -> nop "box")
      | `CCylinder_c -> (match ccylinder with
	    Some f -> f ((Obj.magic g) : ccylinder)
	  | None -> match placeable with
		Some f -> f ((Obj.magic g) : some_placeable)
	      | None -> nop "ccylinder")
      | `Cylinder_c -> (match cylinder with
	    Some f -> f ((Obj.magic g) : cylinder)
	  | None -> match placeable with
		Some f -> f ((Obj.magic g) : some_placeable)
	      | None -> nop "cylinder")
      | `Plane_c -> (match plane with
	    Some f -> f ((Obj.magic g) : plane)
	  | None -> nop "plane")
      | `Ray_c -> (match ray with
	    Some f -> f ((Obj.magic g) : ray)
	  | None -> match placeable with
		Some f -> f ((Obj.magic g) : some_placeable)
	      | None -> nop "ray")
      | `Transform_c -> (match transform with
	    Some f -> f ((Obj.magic g) : transform)
	  | None -> match placeable with
		Some f -> f ((Obj.magic g) : some_placeable)
	      | None -> nop "transform")
      | `TriMesh_c -> (match trimesh with
	    Some f -> f ((Obj.magic g) : trimesh)
	  | None -> match placeable with
		Some f -> f ((Obj.magic g) : some_placeable)
	      | None -> nop "trimesh")
      | `Simple_space_c -> (match simple with
	    Some f -> f ((Obj.magic g) : simple_space)
	  | None -> match space with
		Some f -> f ((Obj.magic g) : some_space)
	      | None -> nop "simple space")
      | `Hash_space_c -> (match hash with
	    Some f -> f ((Obj.magic g) : hash_space)
	  | None -> match space with
		Some f -> f ((Obj.magic g) : some_space)
	      | None -> nop "hash space")
      | `QuadTree_space_c -> (match quadtree with
	    Some f -> f ((Obj.magic g) : quadtree_space)
	  | None -> match space with
		Some f -> f ((Obj.magic g) : some_space)
	      | None -> nop "quadtree space")
      | _ -> nop "user class"

  let match_placeable (g : 'b placeable) ~(sphere : sphere -> 'a)
      ~(box : box -> 'a) ~(ccylinder : ccylinder -> 'a)
      ~(cylinder : cylinder -> 'a)
      ~(ray : ray -> 'a) ~(transform : transform -> 'a)
      ~(trimesh : trimesh -> 'a)
      ~(userclass : int -> some_placeable -> 'a) =
    match get_placeable_class g with
	`Sphere_c -> sphere (Obj.magic g)
      | `Box_c -> box (Obj.magic g)
      | `CCylinder_c -> ccylinder (Obj.magic g)
      | `Cylinder_c -> cylinder (Obj.magic g)
      | `Ray_c -> ray (Obj.magic g)
      | `Transform_c -> transform (Obj.magic g)
      | `TriMesh_c -> trimesh (Obj.magic g)
      | `User_placeable_c n -> userclass n (Obj.magic g)
;;	  
  (* category and collide bitfields not supported yet *)

  (** Enable and disable a geom. Disabled geoms are completely ignored
      by {!Space.collide} and {!Space.collide2}, although
      they can still be members of a space. New geoms are created in
      the enabled state. *)
  external enable : 'a t -> unit
    = "ml_dGeomEnable"
  external disable : 'a t -> unit
    = "ml_dGeomDisable"
  external is_enabled : 'a t -> bool
    = "ml_dGeomIsEnabled"

  (** Given two geoms o1 and o2 that potentially intersect, generate
      contact information for them. Internally, this just calls the correct
      class-specific collision functions for o1 and o2.

      max is an integer that specifies the maximum number
      of contact points to generate. Note that if this number is zero, this
      function just pretends that it is one - in other words you can not ask
      for zero contacts.

      If the geoms intersect, this function returns a Contact.array of
      contact points generated (and updates the contact array),
      otherwise it returns an empty Contact.array.

      If a space is passed as o1 or o2 then this function will collide
      all objects contained in o1 with all objects contained in o2, and
      return the resulting contact points. This method for colliding
      spaces with geoms (or spaces with spaces) provides no user control
      over the individual collisions. To get that control, use
      {!Space.collide} or {!Space.collide2} instead.

      If o1 and o2 are the same geom then this function will do
      nothing and return an empty Contact.array. Technically speaking
      an object intersects with itself, but it is not useful to find
      contact points in this case.

      This function does not care if o1 and o2 are in the same space or
      not (or indeed if they are in any space at all). *)
  external collide : 'a t -> 'b t -> max:int -> Contact.array option
    = "ml_dCollide"

  (** Works like {!Geom.collide}, but creates new array with the
      result appended to the (copied) input array *)
  external collide_append : 'a t -> 'b t -> max:int -> Contact.array
    -> Contact.array
    = "ml_dCollide"

  type ('a, 'b) callback = o1:('a t) -> o2:('b t) -> unit

(** Set and get the ``category'' and ``collide'' bitfields for the
    given geom. These bitfields are used by spaces to govern which
    geoms will interact with each other. The bit fields are guaranteed
    to be at least 32 bits wide. The default category and collide
    values for newly created geoms have all bits set. *)
  external set_category_bits : 'a t -> nativeint -> unit
    = "ml_dGeomSetCategoryBits"
  external set_collide_bits : 'a t -> nativeint -> unit
    = "ml_dGeomSetCollideBits"
  external get_category_bits : 'a t -> nativeint
    = "ml_dGeomGetCategoryBits"
  external get_collide_bits : 'a t -> nativeint
    = "ml_dGeomGetCollideBits"
      
    
  (** Create a sphere geom of the given radius. If space is given,
      insert it into that space. The point of reference for a sphere
      is its center. *)
  external create_sphere : ?dst:'a space -> radius:float -> unit ->
    sphere = "ml_dCreateSphere"
  external sphere_set_radius : sphere -> radius:float -> unit
    = "ml_dGeomSphereSetRadius"
  external sphere_get_radius : sphere -> float
    = "ml_dGeomSphereGetRadius"

  (** Return the depth of the point (x,y,z) in the given
      sphere. Points inside the geom will have positive depth, points
      outside it will have negative depth, and points on the surface will
      have zero depth. *)
  external sphere_point_depth : sphere -> x:float -> y:float ->
    z:float -> float
    = "ml_dGeomSpherePointDepth"

  (** Create a box geom of the given x/y/z side lengths (lx,ly,lz). If
      space is given, insert it into that space. The point of
      reference for a box is its center. *)
  external create_box : ?dst: 'a space -> lx:float -> ly:float
    -> lz:float -> unit -> box
    = "ml_dCreateBox"
  external box_set_lengths : box -> lx:float -> ly:float
    -> lz:float -> unit
    = "ml_dGeomBoxSetLengths"
  external box_get_lengths : box -> vector3
    = "ml_dGeomBoxGetLengths"
  external box_point_depth : box -> x:float -> y:float -> z:float
    -> float = "ml_dGeomBoxPointDepth"

  (** Create a plane geom of the given parameters, and return its
      ID. If space is nonzero, insert it into that space. The plane
      equation is

      a*x+b*y+c*z = d

      The plane's normal vector is (a,b,c), and it must have length
      1. Planes are non-placeable geoms. This means that, unlike
      placeable geoms, planes do not have an assigned position and
      rotation. This means that the parameters (a,b,c,d) are always in
      global coordinates. In other words it is assumed that the plane is
      always part of the static environment and not tied to any movable
      object. *)
  external create_plane : ?dst: 'a space -> ?a:float -> ?b:float ->
    ?c:float -> ?d:float -> unit -> plane
    = "ml_dCreatePlane_bc" "ml_dCreatePlane"
  external plane_set_params : plane -> a:float -> b:float ->
    c:float -> d:float -> unit
    = "ml_dGeomPlaneSetParams"
  external plane_get_params : plane -> vector4
    = "ml_dGeomPlaneGetParams"
  external plane_point_depth : plane -> x:float -> y:float ->
    z:float -> float
    = "ml_dGeomPlanePointDepth"

  (** Create a capped cylinder geom of the given parameters. If space
      is given, insert it into that space.

      A capped cylinder is like a normal cylinder except it has
      half-sphere caps at its ends. This feature makes the internal
      collision detection code particularly fast and accurate. The
      cylinder's length, not counting the caps, is given by length. The
      cylinder is aligned along the geom's local Z axis. The radius of
      the caps, and of the cylinder itself, is given by radius. *)
  external create_ccylinder : ?dst: 'a space -> radius:float ->
    length:float -> unit -> ccylinder
    = "ml_dCreateCCylinder"
  external ccylinder_set_params : ccylinder -> radius:float ->
    length:float -> unit
    = "ml_dGeomCCylinderSetParams"   

  (** Return in [{fst = radius; snd = length}] the parameters of the
      given capped cylinder. *)
  external ccylinder_get_params : ccylinder -> float * float
    = "ml_dGeomCCylinderGetParams"
  external ccylinder_point_depth : ccylinder -> x:float -> y:float ->
    z:float -> float
    = "ml_dGeomCCylinderPointDepth"
  external create_ray : ?dst: 'a space -> length:float -> unit -> ray
    = "ml_dCreateRay"
  external ray_set_length : ray -> length:float -> unit
    = "ml_dGeomRaySetLength"
  external ray_get_length : ray -> float
    = "ml_dGeomRayGetLength"
(** Set the starting position (px,py,pz) and direction (dx,dy,dz) of
    the given ray. The ray's rotation matrix will be adjusted so that
    the local Z-axis is aligned with the direction. Note that this
    does not adjust the ray's length. *)
  external ray_set : ray -> px:float -> py:float -> pz:float ->
    dx:float -> dy:float -> dz:float -> unit
    = "ml_dGeomRaySet_bc" "ml_dGeomRaySet"

  (** Get the starting position (start) and direction (dir) of the ray
      as (start, dir). The returned direction will be a unit length
      vector. *)
  external ray_get : ray -> vector3 * vector3
    = "ml_dGeomRayGet"

(* triangle mesh is not ported yet *)

  (** Create a new geometry transform object. If
      space is given, insert it into that space. On creation the
      encapsulated geometry is set to [None]. *)
  external create_transform : ?dst:'a space -> unit -> transform
    = "ml_dCreateGeomTransform"

  (** Set the geom that the geometry transform encapsulates. The
      placeable geom must not be inserted into any space, and must not
      be associated with any body.

      If g has its clean-up mode turned on, and it already encapsulates
      an object, the old object will be destroyed before it is replaced
      with the new one. *)
  external transform_set_geom : transform -> 'a placeable -> unit
    = "ml_dGeomTransformSetGeom"
  external transform_get_geom : transform -> unknown_t placeable
    = "ml_dGeomTransformGetGeom"

  (** Set and get the "information" mode of geometry transform. The
      mode can be [false] or [true]. The default mode is [false].

      With mode [true], when a transform object is collided with
      another object (using {!Geom.collide} [transform] [other_geom]),
      the g1 field of the dContactGeom structure is set to the geom
      that is encapsulated by the transform object. This value of g1
      allows the caller to interrogate the type of the geom that is
      transformed, but it does not allow the caller to determine the
      position in global coordinates or the associated body, as both
      of these properties are used differently for encapsulated geoms.

      With mode [true], the g1 field of the dContactGeom structure is set to
      the transform object itself. This makes the object appear just
      like any other kind of geom, as {!Geom.get_body} will return the
      attached body, and {!Geom.get_position} will return the global
      position. To get the actual type of the encapsulated geom in this
      case, {!Geom.transform_get_geom} must be used. NOT PORTED YET. *)
  external transform_set_info : transform -> bool -> unit
    = "ml_dGeomTransformSetInfo"
  external transform_get_info : transform -> bool
    = "ml_dGeomTransformGetInfo"

(* user defined classes feature not implemented yet *)

  (** This function can be used as the AABB-getting function in a
      geometry class, if you don't want to compute tight bounds for the
      AABB. It returns +/- infinity in each direction. *)
  external infinite_aabb : 'a t -> aabb
    = "ml_dInfiniteAABB"
