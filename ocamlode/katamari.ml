(* Toy wireframe version of Katamari Damashii.
 * Copyright (C) 2005 Richard W.M. Jones <rich@annexia.org>
 * Adapted for new bindings by Lukasz Stafiniak
 * $Id: katamari.ml,v 1.2 2005/06/25 15:22:15 rich Exp $
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *)

open Printf

open ExtList

open Ode

open Ode

(* let () = Gc.set { (Gc.get ()) with Gc.verbose = 0x1 + 0x2 + 0x10 } *)

(* Get the command line parameters. *)
let width, height = ref 320, ref 240	(* Default screen size. *)
let seed = ref (-1)			(* Default random number seed. *)

let () =
  let argspec = [
    "-width", Arg.Set_int width, "Set screen or window width";
    "-height", Arg.Set_int height, "Set screen or window height";
    "-seed", Arg.Set_int seed, "Choose a specific random number seed";
  ] in
  let usage =
    Filename.basename Sys.executable_name ^ " [-options]\n" ^
    "Play a simple ocamlode-based game.\n" ^
    "Options:" in
  Arg.parse argspec (fun arg -> raise (Arg.Bad arg)) usage

let width = !width
let height = !height
let seed = !seed

let pi = 3.14159265358979323846

let stepsize = 0.01			(* Stepsize for physics (in secs). *)

let initial = 0., 0., 1.		(* Initial position for katamari. *)
let initial_radius = 0.2		(* Initial radius. *)
let initial_density = 5.		(* Density of katamari. *)

let camera = ref (3.*.pi/.2.)		(* Current camera angle, radians. *)
let camera_dist = 2.			(* Camera distance from katamari. *)

let pick_up_factor = 20.		(* Can pick up boxes up to 1/factor
					 * mass of total katamari. *)

let ignore_factor = 5.			(* Length of time before ignoring a
					 * box which has been picked up. *)

(* Current key state. *)
let key_forward = ref false
let key_backward = ref false
let key_left = ref false
let key_right = ref false

(* "Physics time", counts in seconds starting at 0. *)
let physics_time = ref 0.

let vecneg {|x; y; z; w|} =
  {| -.x; -.y; -.z; -.w |}

let vecnormalize {|x; y; z|} =
  let w = sqrt (x *. x +. y *. y +. z *. z) in
  {|x/.w; y/.w; z/.w|}

let vecsub {|x; y; z|} {|x'; y'; z'|} = {|x-.x'; y-.y'; z-.z'|}

let vecscalarmul m {|x; y; z|} = {|m *. x; m *. y; m *. z|}

let veccross {|b0; b1; b2|} {|c0; c1; c2|} =
  {| b1 *. c2 -. b2 *. c1;
  b2 *. c0 -. b0 *. c2;
  b0 *. c1 -. b1 *. c0  |}

(* Timing helper functions. *)
let timer_start, timer_stop =
  let timer = ref None in
  let timer_start label = timer := Some (Unix.gettimeofday (), label) in
  let timer_stop () =
    match !timer with
      | None -> failwith "timer_stop called without timer_start"
      | Some (start, label) ->
	  let now = Unix.gettimeofday () in
	  printf "%s: %g seconds\n" label (now -. start);
	  timer := None
  in
  timer_start, timer_stop

let create_katamari ode space =
  let body = Body.create ode in
  Body.set_auto_disable_flag body false;
  let mass = Mass.sphere ~density:initial_density
    ~radius:initial_radius in
  Mass.set body mass;
  let kata = Geom.create_sphere ~dst:space ~radius:initial_radius () in
  Geom.set_body kata (Some body);
  let x, y, z = initial in
  Geom.set_position kata ~x ~y ~z;
  kata, body

type enabled_box = {
  b_box : box;
  b_body : Body.t;			(* Body. *)
}
and box = {
  b_size : float * float * float;	(* Length of each side. *)
  b_mass : float;			(* Mass (when embodied). *)
  b_geom : Geom.box;			(* Geom. *)
  (* For picked boxes, this points to the transform geom.  In other
   * boxes, it is the same as b_geom.
   *)
  b_tgeom : Geom.some_placeable; 	(* Geom.transform; *)
  (* For picked boxes, this is the time until we ignore the box, which
   * is calculated depending on the relative mass of the box.  In other
   * boxes, it is undefined.
   *)
  b_time : float;
}

module BodyBoxMap =
  Map.Make
    (struct
       type t = Body.t
       let compare = compare
     end)
module GeomBoxMap =
  Map.Make
    (struct
       type t = Geom.some_placeable
       let compare = compare
     end)

let create_boxes ode space =
  let boxes = ref GeomBoxMap.empty in

  let create_box scale base_y base_x =
    let lx, ly, lz =
      Random.float scale +. scale, Random.float scale +. scale,
      Random.float scale +. scale in
    let geom = Geom.create_box ~dst:space ~lx ~ly ~lz () in
    let x, y =
      Random.float (scale *. 10.) +. base_x,
      Random.float (scale *. 10.) +. base_y in
    let z = lz /. 2. in
    Geom.set_position geom ~x ~y ~z;
    let density = Random.float 1.9 +. 0.1 in
    let mass = lx *. ly *. lz *. density in

    let box =
      { b_size = (lx, ly, lz); b_mass = mass;
      b_geom = geom; b_tgeom = Geom.placeable geom; b_time = 0. } in
    boxes := GeomBoxMap.add (Geom.placeable geom) box !boxes
  in
  List.iter (
    fun scale ->
      for i = -10 to 10; do
	let y = scale *. 10. in
	let x = float i *. y in
	create_box scale y x
      done
  ) [ 0.05; 0.1; 0.5; 1.0; 2.0; 5.0 ];
  !boxes
;;
(* Enable boxes smaller than a certain mass. *)
let enable_boxes ode large_boxes enabled_boxes max_mass =
  (* Get a list of boxes which are smaller than the max_mass, and thus
   * candidates to be enabled.
   *)
  let boxes_to_enable =
    GeomBoxMap.fold (fun _ box boxes ->
		       if box.b_mass <= max_mass then box :: boxes else boxes)
      large_boxes [] in

  (* enable_box function below will move boxes from the large_boxes map
   * to the enabled_boxes map.
   *)
  let large_boxes = ref large_boxes in
  let enabled_boxes = ref enabled_boxes in

  (* Function to do the enabling of a single box. *)
  let enable_box box =
    let body = Body.create ode in
    let lx, ly, lz = box.b_size in
    let mass = Mass.box_total ~mass:box.b_mass ~lx ~ly ~lz in
      (* let b_mass = Mass.mass mass in *)
    Mass.set body mass;

    let {|x; y; z|} = Geom.get_position box.b_geom in
    Geom.set_body box.b_geom (Some body);
    Geom.set_position box.b_geom ~x ~y ~z;

    let enabled_box = { b_box = box; b_body = body } in
    large_boxes := GeomBoxMap.remove (Geom.placeable box.b_geom) !large_boxes;
    enabled_boxes := BodyBoxMap.add body enabled_box !enabled_boxes
  in
  List.iter enable_box boxes_to_enable;

  !large_boxes, !enabled_boxes
;;

let init_gl () =
  let bg_r, bg_g, bg_b = 0.9375, 0., 1. in
  GlDraw.viewport ~x:0 ~y:0 ~w:width ~h:height;
  GlClear.color (bg_r, bg_g, bg_b);
  GlClear.depth 1.0;
  Gl.enable `depth_test;
  GlFunc.depth_func `less;
  GlDraw.shade_model `smooth;

(*
  (* Lighting. *)
  Gl.enable `lighting;
  Gl.enable `light0;
  GlLight.light ~num:0 (`position (0., 0., 10., 0.));
*)

(*
  (* Fog *)
  Gl.enable `fog;
  GlMisc.hint `fog `nicest;
  GlLight.fog (`mode `exp);
  GlLight.fog (`color (bg_r, bg_g, bg_b, 1.));
  GlLight.fog (`density 0.5);
*)

  (* Projection matrix. *)
  GlMat.mode `projection;
  GlMat.load_identity ();
  GluMat.perspective ~fovy:60. ~aspect:(float width /. float height)
    ~z:(0.1, 100.);
  GlMat.mode `modelview

(* The game state, used both for drawing and for physics. *)
type state = {
  ode : World.t;			(* The rigid body world. *)
  space : Space.hash;			(* Collision-detection world. *)
  plane : Geom.plane;			(* Ground plane. *)

  kata_geom : Geom.sphere;			(* Katamari geom. *)
  kata_body : Body.t;			(* Katamari body. *)

  (* Boxes (ie. the stuff you're supposed to pick up) exist in four
   * different states, which they transition between.  large -> enabled
   * -> picked -> ignored.  They start off in the 'large' state, where
   * they are just geoms (no bodies, so immovable).  When the katamari
   * reaches a certain mass, large boxes which could potentially be
   * picked up are moved to the 'enabled' state.  In this state they get
   * bodies and can now potentially be bumped around or picked up.  When
   * they are picked up, they are moved into the 'picked' state.  In the
   * picked up state, they are attached as geoms to the katamari and
   * their separate body is deleted (they become part of kata_body).
   * After a while, to make the game more playable, we ignore the boxes,
   * and they are moved onto the ignored list.
   * 
   * Each box must be in exactly one state, and this is reflected by
   * which of the following structures they are contained in.
   *)
  large_boxes : box GeomBoxMap.t;	(* dGeomID -> box *)
  enabled_boxes : enabled_box BodyBoxMap.t; (* dBody ID -> enabled box *)
  picked_boxes : box GeomBoxMap.t;	(* dGeomID -> box *)
  ignored_boxes : box GeomBoxMap.t;	(* dGeomID -> box *)
}

let draw_scene st =
  GlClear.clear [ `color; `depth ];

  (* Initialise modelview matrix. *)
  GlMat.load_identity ();

  (* Get the position and velocity of the katamari.  It affects the camera. *)
  let pos = Body.get_position st.kata_body in
  let vel = Body.get_linear_vel st.kata_body in
  let radius = Geom.sphere_get_radius st.kata_geom in

  (* Camera. *)
  let () =
    let angle = !camera in
    let eye =
      {| pos.x +. camera_dist *. cos angle;
	 pos.y +. camera_dist *. sin angle;
	 pos.z +. radius +. 0.03
      |} in
    let up =
      let up = {|0.; 0.; 1.|} in
      let cam =	{|eye.x -. pos.x; eye.y -. pos.y; eye.z -. pos.z|} in
      (* Vector b will be perpendicular to the up vector and the vector
       * shooting out from the camera.
       *)
      let b = veccross cam up in
      let up = vecneg (veccross cam b) in
      up in
    let eye = eye.x, eye.y, eye.z in
    let center = pos.x, pos.y, pos.z in
    let up = up.x, up.y, up.z in
    GluMat.look_at ~eye ~center ~up in

  (* Katamari. *)
  GlMat.push ();
  let r = Geom.get_rotation st.kata_geom in
  let matrix = [|
    [| r.r11; r.r21; r.r31; 0. |];
    [| r.r12; r.r22; r.r32; 0. |];
    [| r.r13; r.r23; r.r33; 0. |];
    [| pos.x; pos.y; pos.z; 1. |]
  |] in
  GlMat.mult (GlMat.of_array matrix);
  GlDraw.color (1., 1., 1.);
  Glut.wireSphere ~radius ~slices:10 ~stacks:10;
  GlMat.pop ();

  (* Boxes.  Draw them in different colours so it's obvious what state
   * boxes are in.
   *)
  let draw_box col box =
    GlMat.push ();

    let geom = box.b_geom in
    let r = Geom.get_rotation geom in
    let pos = Geom.get_position geom in
    let matrix = [|
      [| r.r11; r.r21; r.r31; 0. |];
      [| r.r12; r.r22; r.r32; 0. |];
      [| r.r13; r.r23; r.r33; 0. |];
      [| pos.x; pos.y; pos.z; 1. |]
    |] in
    GlMat.mult (GlMat.of_array matrix);

    let x, y, z = box.b_size in
    GlMat.scale ~x ~y ~z ();

    GlDraw.color col;
    Glut.wireCube ~size:1.;
    GlMat.pop ();
  in
  let col = ( 0., 0., 0. ) in
  GeomBoxMap.iter (fun _ box -> draw_box col box) st.large_boxes;
  let col = ( 1., 1., 0. ) in
  BodyBoxMap.iter (fun _ box -> draw_box col box.b_box) st.enabled_boxes;

  (* Picked up and ignored boxes are drawn slightly differently. *)
  let draw_box col box =
    GlMat.push ();

    let geom = box.b_geom in
    (* let r = dGeomGetRotation st.kata_geom in -- same as above *)
    let {|x; y; z|} =
      Geom.get_position geom in		(* Relative to katamari centre. *)
    let {|x; y; z|} =
      Body.get_rel_point_pos st.kata_body ~px:x ~py:y ~pz:z in
    let matrix = [|
      [| r.r11; r.r21; r.r31; 0. |];
      [| r.r12; r.r22; r.r32; 0. |];
      [| r.r13; r.r23; r.r33; 0. |];
      [| x;     y;     z;     1. |]
    |] in
    GlMat.mult (GlMat.of_array matrix);

    let x, y, z = box.b_size in
    GlMat.scale ~x ~y ~z ();

    GlDraw.color col;
    Glut.wireCube ~size:1.;
    GlMat.pop ();
  in
  let col = ( 1., 1., 1. ) in
  GeomBoxMap.iter (fun _ box ->
		     draw_box col box) st.picked_boxes;
  let col = ( 0., 1., 1. ) in
  GeomBoxMap.iter (fun _ box ->
		     draw_box col box) st.ignored_boxes

(* Surface parameters used for all contact points. *)
let contact = Contact.be ~mu:(Ode.get_infinity ())
  [Contact.Bounce (0.7, 0.1)]
;;

(* A group to hold the contact joints. *)
let contact_joint_group = JointGroup.create ()

(* See function classify below. *)
type class_t =
  | IsKatamari
  | IsIgnoredBox of box
  | IsPickedBox of box
  | IsLargeBox of box
  | IsEnabledBox of enabled_box
  | IsGround
  | IsScenery

(* Classify each geom/body. *)

let classify st geom body =
  (* must typecheck dynamically, though less efficient than the old
     solution, and not nicer *)
  Geom.match_type geom
    ~plane:(fun p -> IsGround)
    ~sphere:(fun s -> IsKatamari)
    ~transform:(fun geom -> 
		  try
		    let box = GeomBoxMap.find (Geom.placeable geom)
		      st.picked_boxes in
		    IsPickedBox box
		  with
		      Not_found ->
			try
			  let box = GeomBoxMap.find
			    (Geom.placeable geom) st.ignored_boxes in
			  IsIgnoredBox box
			with
			    Not_found -> IsScenery)
    ~box:(fun geom ->
      try
	(match body with
	  | None -> raise Not_found
	  | Some body ->
	      let box = BodyBoxMap.find body st.enabled_boxes in
	      IsEnabledBox box
	)
      with
	  Not_found ->
	    try
	      let box = GeomBoxMap.find (Geom.placeable geom) st.large_boxes in
	      IsLargeBox box
	    with
		Not_found ->
		  try
		    let box = GeomBoxMap.find (Geom.placeable geom)
		      st.picked_boxes in
		    IsPickedBox box
		  with
		      Not_found ->
			try
			  let box = GeomBoxMap.find
			    (Geom.placeable geom) st.ignored_boxes in
			  IsIgnoredBox box
			with
			    Not_found -> IsScenery
    ) ()

(* Old style was this:
let classify st geom body =
  (* Most collisions are with the ground, so test this first. *)
  if geom = st.plane then
    IsGround
  else if geom = st.kata_geom then
    IsKatamari
  else
    try
      (match body with
	 | None -> raise Not_found
	 | Some body ->
	     let box = BodyBoxMap.find body st.enabled_boxes in
	     IsEnabledBox box
      )
    with
	Not_found ->
	  try
	    let box = GeomBoxMap.find geom st.large_boxes in
	    IsLargeBox box
	  with
	      Not_found ->
		try
		  let box = GeomBoxMap.find geom st.picked_boxes in
		  IsPickedBox box
		with
		    Not_found ->
		      try
			let box = GeomBoxMap.find geom st.ignored_boxes in
			IsIgnoredBox box
		      with
			  Not_found -> IsScenery
*)

(* Pick up a box.  This updates the state. *)
let pick_up_box st box =
  let orig_geom = box.b_box.b_geom in
  let orig_body = box.b_body in

  (* Attach the box to the katamari.  To do this we create a transform
   * geom and another box geom inside it, positioned at the correct relative
   * position.  The original geom is destroyed because there is no way to
   * detach geoms from spaces (geoms inside transform geoms must not be
   * in any space).
   *)
  let lx, ly, lz = box.b_box.b_size in
  let geom = Geom.create_box ~lx ~ly ~lz () in
  let tgeom = Geom.create_transform ~dst:(st.space) () in
  Geom.transform_set_geom tgeom geom;
  Geom.set_body tgeom (Some st.kata_body);
  let {|px; py; pz|} = Geom.get_position orig_geom in
  let {|x; y; z|} = Body.get_pos_rel_point st.kata_body ~px ~py ~pz in
  Geom.set_position geom ~x ~y ~z;
  let r = Geom.get_rotation orig_geom in
  Geom.set_rotation geom r;
  Geom.destroy orig_geom;

  (* Adjust the mass of the katamari. *)
  let mass = Mass.of_body st.kata_body in (* Current mass of katamari. *)
  let mass' = Mass.of_body orig_body in	(* Current mass of box. *)
  Mass.rotate mass' r;			(* Mass of box rotated. *)
  Mass.translate mass' ~x ~y ~z;	(* Mass of box translated. *)
  Mass.add mass mass';			(* Mass of katamari + box. *)
  Mass.set st.kata_body mass;

  (* Calculate a time before this box gets ignored. *)
  (* XXX Should be longer for heavier or awkwardly shaped boxes. *)
  let time = !physics_time +. ignore_factor in

  (* New box structure. *)
  let box =
    { box.b_box with b_geom = geom; b_tgeom = Geom.placeable tgeom;
      b_time = time } in

  (* Move the box to the picked list. *)
  let enabled_boxes = BodyBoxMap.remove orig_body st.enabled_boxes in
  let picked_boxes = GeomBoxMap.add (Geom.placeable tgeom)
    box st.picked_boxes in

  (* This box is no longer an independent rigid body. *)
  Body.destroy orig_body;

  (* Return updated state. *)
  { st with
      enabled_boxes = enabled_boxes;
      picked_boxes = picked_boxes }

(* Run the physics loop to a particular time. *)
let physics st to_time =
  let step st =
    (* Get katamari's current mass. *)
    let kata_mass =
      let mass = Mass.of_body st.kata_body in
      Mass.mass mass in

    (* Accumulate forces on the katamari according to the current
     * key states.
     *)
    let () =
      (* The forwards force will be applied at this angle along the ground. *)
      let angle = pi +. !camera in
      let x = cos angle in
      let y = sin angle in
      let fx = x *. stepsize *. 100. in
      let fy = y *. stepsize *. 100. in
      if !key_forward then
	Body.add_force st.kata_body ~fx ~fy ~fz:0.;
      if !key_backward then
	Body.add_force st.kata_body ~fx:(-.fx/.10.) ~fy:(-.fy/.10.) ~fz:0.;
      if !key_left then
	camera := !camera +. stepsize;
      if !key_right then
	camera := !camera -. stepsize;

      (* When forwards/backwards NOT pressed, simulate a little natural
       * friction.
       *)
      if not !key_forward && not !key_backward then (
	let vel = Body.get_linear_vel st.kata_body in
	let vel = vecscalarmul (-. 100. *. stepsize) vel in
	Body.add_force st.kata_body ~fx:vel.x ~fy:vel.y ~fz:0.
      ) in

    (*----- Collision detection. -----*)
    let nr_contacts = ref 0 in
    let contacts = ref [] in

    let near ~o1:geom1 ~o2:geom2 =
      (* geom1 and geom2 are close.  Test if they collide. *)
      (match Geom.collide geom1 geom2 ~max:4 with
	  Some cs -> contacts := (geom1, geom2, cs) :: !contacts
	| _ -> ())
    in
    Space.collide st.space near;

    (* This gives us a list of geom-geom contacts.  There is a
     * potential problem when iterating over this list: we might pick up
     * a geom, but references to that geom could exist later in the list.
     * The function 'loop' below loops avoid the contacts, avoiding this
     * case.
     *)
    let contacts = !contacts in

    let rec loop st = function
      | [] -> st
      | (geom1, geom2, contacts) :: rest ->
	  (* Get the bodies (these might be None if colliding with large
	   * boxes or other scenery).
	   *)
	  let body1 = Geom.get_body geom1 in
	  let body2 = Geom.get_body geom2 in

	  (* Classify each geom/body. *)
	  let class1 = classify st geom1 body1 in
	  let class2 = classify st geom2 body2 in

	  (* Possible to pick something up? *)
	  let st, rest =
	    match class1, class2 with
	      | IsIgnoredBox _, _
	      | _, IsIgnoredBox _
	      | IsKatamari, IsPickedBox _
	      | IsPickedBox _, IsKatamari
	      | IsPickedBox _, IsPickedBox _
	      | IsGround, IsGround ->
		  (* These sorts of collisions are uninteresting. *)
		  st, rest

	      | IsKatamari, IsEnabledBox box
	      | IsEnabledBox box, IsKatamari
	      | IsPickedBox _, IsEnabledBox box
	      | IsEnabledBox box, IsPickedBox _
		  when box.b_box.b_mass *. pick_up_factor < kata_mass ->
		  (* Pick it up - this updates the state because it
		   * moves the box from the enabled list to the picked
		   * list.
		   *)
		  let st = pick_up_box st box in

		  (* Remove the picked geom if it occurs later on in
		   * the contact list.
		   *)
		  let geom_to_remove = box.b_box.b_geom in
		  let rest = List.filter (
		    fun (geom1, geom2, _) ->
		      geom1 <> geom_to_remove &&
			geom2 <> geom_to_remove
		  ) rest in

		  st, rest

	      | _ ->
		  (* Just an ordinary collision. *)
		  (* For each collision, create a contact joint using
		     the global contact variable with surface
		     params set. *)
		  Contact.iter ~f:(
		    fun contact ->
		      incr nr_contacts;
		      let joint =
			Contact.create_joint st.ode
			  ~dst:contact_joint_group contact in

		      (* Attach that joint to the two bodies.  The
		       * bodies may be 'None' indicating a collision with
		       * the static world, but that's OK.
		       *)
		      Joint.attach joint ?b1:body1 ?b2:body2 ()
		  ) ~contact:contact contacts;

		  st, rest in

	  loop st rest
    in
    let st = loop st contacts in

    (*----- Take a simulation step. -----*)
    World.quick_step st.ode stepsize;
    physics_time := !physics_time +. stepsize;

    (* Remove and destroy the contact joints. *)
    JointGroup.empty contact_joint_group;

    (* Consider all the picked boxes and move any to the ignored list if
     * they have been picked for a certain time.
     *)
    let st =
      GeomBoxMap.fold (
	fun geom box st ->
	  if box.b_time <= !physics_time then
	    (* Move to ignored list. *)
	    { st with
		picked_boxes = GeomBoxMap.remove geom st.picked_boxes;
		ignored_boxes = GeomBoxMap.add geom box st.ignored_boxes }
	  else st
      ) st.picked_boxes st in

    st
  in

  let rec loop st =
    if !physics_time < to_time then (
      let st = step st in
      loop st
    ) else
      st in
  loop st

let read_events () =
  let quit = ref false in
  let rec read_events () =
    match Sdlevent.poll () with
      | None -> ()
      | Some event -> do_event event; read_events ()
  and do_event = function
    | Sdlevent.QUIT -> quit := true (* window closed: quit *)
    | Sdlevent.KEYDOWN ke ->
	(match ke.Sdlevent.keysym with
	   | Sdlkey.KEY_ESCAPE -> quit := true (* escape key: quit *)
	   | Sdlkey.KEY_UP -> key_forward := true
	   | Sdlkey.KEY_DOWN -> key_backward := true
	   | Sdlkey.KEY_LEFT -> key_left := true
	   | Sdlkey.KEY_RIGHT -> key_right := true
	   | _ -> () (* ignore this key *)
	)
    | Sdlevent.KEYUP ke ->
	(match ke.Sdlevent.keysym with
	   | Sdlkey.KEY_UP -> key_forward := false
	   | Sdlkey.KEY_DOWN -> key_backward := false
	   | Sdlkey.KEY_LEFT -> key_left := false
	   | Sdlkey.KEY_RIGHT -> key_right := false
	   | _ -> () (* ignore this key *)
	)
    | _ -> () (* ignore this event *)
  in
  read_events ();
  !quit

let main () =
  if seed >= 0 then
    Random.init seed
  else
    Random.self_init ();

  (* Initialise SDL. *)
  Sdl.init [`VIDEO];
  Sdlgl.set_attr [];
  let surface = Sdlvideo.set_video_mode ~w:width ~h:height ~bpp:32 [`OPENGL] in

  (* Initialize ODE! *)
  Ode.init ();
  (* Create the ODE world. *)
  let ode = World.create () in
  World.set_gravity ode ~x:0. ~y:0. ~z:(-9.81) ();

  (* Create the objects in the world. *)
  let space = Space.hash_create () in
  Space.hash_set_levels space ~min:(-4) ~max:4; (* 1/16 .. 16 units. *)

  (* The ground plane goes through the world origin, with the normal
   * facing upwards towards +z.
   *)
  let plane = Geom.create_plane ~dst:space ~a:0. ~b:0. ~c:1. ~d:0. () in

  (* Create the katamari. *)
  let kata_geom, kata_body = create_katamari ode space in

  (* Scatter boxes around. *)
  let large_boxes = create_boxes ode space in

  (* Enable boxes which are up to 10 times larger than could be picked up. *)
  let kata_mass =
    let mass = Mass.of_body kata_body in
    Mass.mass mass in
  let max_mass = kata_mass *. 10. /. pick_up_factor in
  let large_boxes, enabled_boxes =
    enable_boxes ode large_boxes BodyBoxMap.empty max_mass in

  let st = { ode = ode;
	     space = space;
	     plane = plane;
	     kata_geom = kata_geom;
	     kata_body = kata_body;
	     large_boxes = large_boxes;
	     enabled_boxes = enabled_boxes;
	     picked_boxes = GeomBoxMap.empty;
	     ignored_boxes = GeomBoxMap.empty; } in

  (* Initialise GL state. *)
  init_gl ();

  (* Start the clocks counting. *)
  let current_time =
    let base = Unix.gettimeofday () in
    fun () -> Unix.gettimeofday () -. base
  in

  let rec main_loop st =
    draw_scene st;
    let quit = read_events () in
    let st = physics st (current_time ()) in
    Sdlgl.swap_buffers ();
    if not quit then
      main_loop st
  in
  main_loop st;

  (* Clean up the world. *)
  Geom.destroy plane;
  Space.destroy space;

  (* Destroy the ODE world and clean up. *)
  (* currently World cannot be destroyed manually: it's left to finalisation
  dWorldDestroy ode;
  dCloseODE ();
  *)
  (* Quit SDL. *)
  Sdl.quit ();

  (* Find any memory allocation bugs. *)
  Gc.compact ()

let () =
  main ()
