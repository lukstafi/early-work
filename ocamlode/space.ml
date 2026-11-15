  open Ode

  type 'a t = 'a Geom.space

  type simple = Geom.simple_space
  type hash = Geom.hash_space
  type quadtree = Geom.quadtree_space
  type some = Geom.some_space    
  type ('a,'b) callback = ('a,'b) Geom.callback

  let type_space (g : 'a t) =
    match Geom.get_space_class g with
	`Simple_space_c -> `Simple ((Obj.magic g) : simple)
      | `Hash_space_c -> `Hash ((Obj.magic g) : hash)
      | `QuadTree_space_c -> `QuadTree ((Obj.magic g) : quadtree)
      | `User_space_c n -> `User_space ((Obj.magic g) : some)

  let match_type (g : 'b t) ~(simple : simple -> 'a)
      ~(hash : hash -> 'a) ~(quadtree : quadtree -> 'a)
      ~(userspace : int -> some -> 'a) =
    match Geom.get_space_class g with
	`Simple_space_c -> simple (Obj.magic g)
      | `Hash_space_c -> hash (Obj.magic g)
      | `QuadTree_space_c -> quadtree (Obj.magic g)
      | `User_space_c n -> userspace n (Obj.magic g)

  (** If type information is no longer needed, there's no need to pack a
      concrete space into the universal geom type *)
  let some (g : 'a t) = ((Obj.magic g) : some)

  (** This determines which pairs of geoms in a space may potentially
      intersect, and calls the callback function with each candidate
      pair. The o1 and o2 arguments are the geoms that may be near
      each other.

      The callback function can call {!Geom.collide} on o1 and o2 to
      generate contact points between each pair. Then these contact
      points may be added to the simulation as contact joints. The
      user's callback function can of course chose not to call
      {!Geom.collide} for any pair, e.g. if the user decides that
      those pairs should not interact.

      Other spaces that are contained within the colliding space are
      not treated specially, i.e. they are not recursed into. The
      callback function may be passed these contained spaces as one or
      both geom arguments.

      {!Space.collide} is guaranteed to pass all intersecting
      geom pairs to the callback function, but it may also make
      mistakes and pass non-intersecting pairs. The number of mistaken
      calls depends on the internal algorithms used by the space. Thus
      you should not expect that {!Geom.collide} will return contacts
      for every pair passed to the callback. *)
  external collide : 'a t -> ('b,'c) callback -> unit
    = "ml_dSpaceCollide"

  (** This function is similar to {!Space.collide}, except that it is
      passed two geoms (or spaces) as arguments. It calls the callback for
      all potentially intersecting pairs that contain one geom from o1 and
      one geom from o2.

      The exact behavior depends on the types of o1 and o2: 

      If one argument is a non-space geom and the other is a space,
      the callback is called with all potential intersections between
      the geom and the objects in the space.

      If both o1 and o2 are spaces then this calls the callback for
      all potentially intersecting pairs that contain one geom from o1
      and one geom from o2. The algorithm that is used depends on what
      kinds of spaces are being collided. If no optimized algorithm
      can be selected then this function will resort to one of the
      following two strategies:

      All the geoms in o1 are tested one-by-one against o2. 

      All the geoms in o2 are tested one-by-one against o1. 

      The strategy used may depends on a number of rules, but in
      general the space with less objects has its geoms examined
      one-by-one.

      If both arguments are the same space, this is equivalent to
      calling {!Space.collide} on that space.

      If both arguments are non-space geoms, this simply calls the
      callback once with these arguments.

      If this function is given a space and an geom X in that same
      space, this case is not treated specially. In this case the
      callback will always be called with the pair (X,X), because an
      objects always intersects with itself. The user may either test
      for this case and ignore it, or just pass the pair (X,X) to
      {!Geom.collide} (which will be guaranteed to return an empty
      array). *)
  external collide2 : o1:('a Geom.t) -> o2:('b Geom.t) -> ('c,'d) callback ->
    unit = "ml_dSpaceCollide2"
      
  external simple_create : ?dst:'a t -> unit -> simple
    = "ml_dSimpleSpaceCreate"
  external hash_create : ?dst:'a t -> unit -> hash
    = "ml_dHashSpaceCreate"

(** Creates a quadtree space. center and extents define the size of
    the root block. depth sets the depth of the tree - the number of
    blocks that are created is 4^depth. *)
  external quadtree_create : ?dst: 'a t -> center:vector3 ->
    extents:vector3 -> depth:int -> unit -> quadtree
    = "ml_dQuadTreeSpaceCreate"

  (** This destroys a space. It functions exactly like dGeomDestroy
      except that it takes a ['a space t] argument. *)
  external destroy : 'a t -> unit
    = "ml_dSpaceDestroy"


  (** Sets and get some parameters for a multi-resolution hash table
      space. The smallest and largest cell sizes used in the hash table
      will be 2^minlevel and 2^maxlevel respectively. minlevel must be
      less than or equal to maxlevel. *)
  external hash_set_levels : hash -> min:int -> max:int -> unit
    = "ml_dHashSpaceSetLevels"

  (** The minimum and maximum levels are returned through pair
      [{fst=min; snd=max}]. *)
  external hash_get_levels : hash -> float * float
    = "ml_dHashSpaceGetLevels"

  (** Add a geom to a space. This does nothing if the geom is already
      in the space. This function can be called automatically if a space
      argument is given to a geom creation function. *)
  external add : 'a t -> 'b Geom.t -> unit
    = "ml_dSpaceAdd"

  (** Remove a geom from a space. This does nothing if the geom is not
      actually in the space. This function is called automatically by
      {!Geom.destroy} if the geom is in a space. *)
  external remove : 'a t -> 'b Geom.t -> unit
    = "ml_dSpaceRemove"

  (** Return [true] if the given geom is in the given space, or return
      [false] if it is not. *)
  external query : 'a t -> 'b Geom.t -> bool
    = "ml_dSpaceQuery"

  external num_geoms : 'a t -> int
    = "ml_dSpaceGetNumGeoms"

  (** Return the i'th geom contained within the space. i must range
      from 0 to {!Geom.space_num_geoms}-1.

      If any change is made to the space (including adding and
      deleting geoms) then no guarantee can be made about how the
      index number of any particular geom will change. Thus no space
      changes should be made while enumerating the geoms.

      This function is guaranteed to be fastest when the geoms are
      accessed in the order 0,1,2,etc. Other non-sequential orders may
      result in slower access, depending on the internal
      implementation. *)
  external nth_geom : 'a t -> int -> Geom.some
    = "ml_dSpaceGetGeom"
