(** Ragdoll demo for OCamlODE (C) November 2005 by Lukasz Stafiniak
    Rewritten from:

SimpleControllerDemo: 
This demo sets up a ragdoll character using the Open Dynamics Engine.
You can then enable a simple proportional derivative controller that
compute torques at each joint to drive the body into a desired pose...
Copyright (C) 2005  Michael J Mandel  
Contact me at mmandel@gmail.com with any questions/comments
Licensed under the LGPL (see license.txt for more information)
*)

open Ode;;

let timestep = 0.000000000002;;
let is_controller_enabled = ref false;;
let world_scale = 10.0;;
let sim_to_world v = world_scale *. v;;
let world_to_sim v = v /. world_scale;;
type sim =
    {mutable gravity : float; mutable total_remainder : float;
    mutable do_fast : bool};;
let sim = {gravity = -9.8; total_remainder = 0.; do_fast = true};;
let world = Ode.init (); World.create ();;
let space = Space.hash_create ();;
let contactgroup = JointGroup.create ();;
let max_contact_points = 16;;
let allow_attach_to_world = ref true;;
type obj =
    {body : Body.t option; geom : Geom.some_placeable; enabled : bool;
    render : bool; color : (float * float * float) ref}
;;
  
let objects = ref [];;
let contact =
  open Contact in
  be ~mu:100. [Slip1 0.2; Slip2 0.1; Bounce (0.1, 0.2); SoftCFM 0.001];;

type kind =
    Box of float * float * float	(* lengths of edges lx, ly, lz *)
  | CCylinder of float * float		(* radius, length *)
  | Sphere of float			(* radius *)
;;

type mass =
    Total of float
  | Density of float
  | No_body
;;

let create_obj mass kind ~color ~catbits ~colbits =
  let create m g =
    let b = Body.create world in
    Mass.set b m;
    Geom.set_body g (Some b);
    Geom.set_category_bits g catbits;
    Geom.set_collide_bits g colbits;
    Some b, Geom.placeable g
  in
  let b, g =
    match mass, kind with
      | Box (lx, ly, lz), Total mass ->
	  create (Mass.box_total ~mass ~lx ~ly ~lz)
	    (Geom.create_box ~dst:space ~lx ~ly ~lz ())
	    
      | Box (lx, ly, lz), Density density ->
	  create (Mass.box ~density ~lx ~ly ~lz)
	    (Geom.create_box ~dst:space ~lx ~ly ~lz ())
	    
      | Box (lx, ly, lz), No_body ->
	  let g = Geom.create_box ~dst:space ~lx ~ly ~lz () in
	  Geom.set_category_bits g catbits;
	  Geom.set_collide_bits g colbits;
	  None, Geom.placeable g
      | CCylinder (radius, length), Total mass ->
	  create (Mass.capped_cylinder_total ~mass Mass.X (* ??? *)
	    ~radius ~length)
	    (Geom.create_ccylinder ~dst:space ~radius ~length ())
	    
      | CCylinder (radius, length), Density density ->
	  create (Mass.capped_cylinder ~density Mass.X (* ??? *)
	    ~radius ~length)
	    (Geom.create_ccylinder ~dst:space ~radius ~length ())
	    
      | CCylinder (radius, length), No_body ->
	  let g = Geom.create_ccylinder ~dst:space ~radius ~length () in
	  Geom.set_category_bits g catbits;
	  Geom.set_collide_bits g colbits;
	  None, Geom.placeable g
      | Sphere (radius), Total mass ->
	  create (Mass.sphere_total ~mass ~radius)
	    (Geom.create_sphere ~dst:space ~radius ())
	    
      | Sphere (radius), Density density ->
	  create (Mass.sphere ~density ~radius)
	    (Geom.create_sphere ~dst:space ~radius ())
	    
      | Sphere (radius), No_body ->
	  let g = Geom.create_sphere ~dst:space ~radius () in
	  Geom.set_category_bits g catbits;
	  Geom.set_collide_bits g colbits;
	  None, Geom.placeable g
  in
  {body = b; geom = g; enabled = true; render = true; color = color};;

let render_obj {geom = g; render = render; color = color} =
  let err s _ =
     failwith ("Drawing of unsupported yet primitive "^s)
    in
  if render then Geom.match_placeable g
    ~box:(fun box ->
      (*
	print_string (" box x="^(string_of_float
	((Geom.get_position box).x))^" lx="^
	(string_of_float ((Geom.box_get_lengths box).x)));
      *)
      Drawstuff.set_texture Drawstuff.Wood;
      let r, g, b = !color in
      Drawstuff.set_color ~r ~g ~b;
      Drawstuff.draw_box
	~pos:(Geom.get_position box)
	~r:(Geom.get_rotation box)
	~sides:(Geom.box_get_lengths box))
    ~ccylinder:(fun cyl -> print_string "cyl ";
      Drawstuff.set_texture Drawstuff.Wood;
      let r, g, b = !color in
      Drawstuff.set_color ~r ~g ~b;
      let length, radius = Geom.ccylinder_get_params cyl in
      Drawstuff.draw_ccylinder
	~pos:(Geom.get_position cyl)
	~r:(Geom.get_rotation cyl)
	~length ~radius)
    ~sphere:(fun sph -> print_string "sph ";
      Drawstuff.set_texture Drawstuff.Wood;
      let r, g, b = !color in
      Drawstuff.set_color ~r ~g ~b;
      Drawstuff.draw_sphere
	~pos:(Geom.get_position sph)
	~r:(Geom.get_rotation sph)
	~radius:(Geom.sphere_get_radius sph))
    ~cylinder:(err "cylinder") ~ray:(err "ray")
    ~transform:(err "transform") ~trimesh:(err "trimesh")
    ~userclass:(fun _ -> err "userclass")
;;

let create_stdbox {|lx; ly; lz|} mass ~color ~catbits ~colbits =
  create_obj
    (Box (world_to_sim lx, world_to_sim ly, world_to_sim lz))
    (* if has_body then Density 8. else No_body *) mass
    ~color ~catbits ~colbits
;;

let high_color = (0.45, 0.45, 0.75);;
let low_color = (0.25, 0.25, 0.75);;
let force_color = ref high_color;;
let std_color = ref low_color;;

(* Human Properties *)
type bone = LHipJoint | LFemur | LTibia | LFoot
	      | RHipJoint | RFemur | RTibia | RFoot
	      | LowerBack | UpperBack | Thorax
	      | LowerNeck | UpperNeck | Head
	      | LClavicle | LHumerus | LRadius
	      | RClavicle | RHumerus | RRadius
;;

let iterate_bones f = f LHipJoint; f LFemur; f LTibia; f LFoot
	     ; f RHipJoint; f RFemur; f RTibia; f RFoot
	     ; f LowerBack; f UpperBack; f Thorax
	     ; f LowerNeck; f UpperNeck; f Head
	     ; f LClavicle; f LHumerus; f LRadius
	     ; f RClavicle; f RHumerus; f RRadius
;;

let map_bones f =
  let vLHipJoint = f LHipJoint
  and vLFemur = f LFemur
  and vLTibia = f LTibia
  and vLFoot = f LFoot 
  and vRHipJoint = f RHipJoint
  and vRFemur = f RFemur
  and vRTibia = f RTibia
  and vRFoot = f RFoot
  and vLowerBack = f LowerBack
  and vUpperBack = f UpperBack
  and vThorax = f Thorax
  and vLowerNeck = f LowerNeck
  and vUpperNeck = f UpperNeck
  and vHead = f Head
  and vLClavicle = f LClavicle
  and vLHumerus = f LHumerus
  and vLRadius = f LRadius
  and vRClavicle = f RClavicle
  and vRHumerus = f RHumerus
  and vRRadius = f RRadius in
  function
    | LHipJoint -> vLHipJoint
    | LFemur -> vLFemur
    | LTibia -> vLTibia
    | LFoot -> vLFoot
    | RHipJoint -> vRHipJoint
    | RFemur -> vRFemur
    | RTibia -> vRTibia
    | RFoot -> vRFoot
    | LowerBack -> vLowerBack
    | UpperBack -> vUpperBack
    | Thorax -> vThorax
    | LowerNeck -> vLowerNeck
    | UpperNeck -> vUpperNeck
    | Head -> vHead
    | LClavicle -> vLClavicle
    | LHumerus -> vLHumerus
    | LRadius -> vLRadius
    | RClavicle -> vRClavicle
    | RHumerus -> vRHumerus
    | RRadius -> vRRadius
;;

let bone_names =
  function
    | LHipJoint -> "LHipJoint"
    | LFemur -> "LFemur"
    | LTibia -> "LTibia"
    | LFoot -> "LFoot"
    | RHipJoint -> "RHipJoint"
    | RFemur -> "RFemur"
    | RTibia -> "RTibia"
    | RFoot -> "RFoot"
    | LowerBack -> "LowerBack"
    | UpperBack -> "UpperBack"
    | Thorax -> "Thorax"
    | LowerNeck -> "LowerNeck"
    | UpperNeck -> "UpperNeck"
    | Head -> "Head"
    | LClavicle -> "LClavicle"
    | LHumerus -> "LHumerus"
    | LRadius -> "LRadius"
    | RClavicle -> "RClavicle"
    | RHumerus -> "RHumerus"
    | RRadius -> "RRadius"
;;

type typed_joint = Hinge of Joint.hinge
		  | Universal of Joint.universal
		  | Nojoint
;;
type joint_type = THinge
		  | TUniversal
;;

type body_property =
    {bone : bone; enabled : bool;
    size : vector3; pos : vector3; rot : quaternion; mass : float}
;;

type joint_property =
    {attached_body : bone; parent_body : bone;
    attach_to_world : bool; joint : joint_type;
    lo_joint_range1 : float; lo_joint_range2 : float; 
    high_joint_range1 : float; high_joint_range2 : float;
    joint_anchor : vector3;
    rot_axis1 : vector3;  rot_axis2 : vector3}
;;

type control_property =
    {cbone : bone; is_controllable : bool;
    ks1 : float; kd1 : float; ks2 : float; kd2 : float}
;;

let body_props = function
  | LHipJoint -> {bone = LHipJoint; enabled = true; size = {|4.701126;
    4.701126; 6.183650|}; pos = {|2.210537; -1.881518; 1.064327|}; rot
      = {qx = 0.371142; qy = 0.436043; qz = 0.000000; qs = 0.819829};
    mass = 3.0}
  | LFemur -> {bone = LFemur; enabled = true; size = {|4.819100;
    4.819100; 16.384600|}; pos = {|7.223005; -11.461282; 2.128654|};
    rot = {qx = 0.696363; qy = 0.122787; qz = 0.122787; qs =
	0.696363}; mass = 6.05098068}
  | LTibia -> {bone = LTibia; enabled = true; size = {|4.515653;
    4.515653; 17.012524|}; pos = {|12.930611; -27.142811; 1.703518|};
    rot = {qx = 0.713552; qy = 0.125818; qz = 0.119679; qs =
	0.678738}; mass = 3.54112135}
  | LFoot -> {bone = LFoot; enabled = true; size = {|4.082203;
    4.082203; 5.017975|}; pos = {|16.122274; -35.911842; 3.643932|};
    rot = {qx = 0.166501; qy = 0.029359; qz = 0.171148; qs =
	0.970629}; mass = 1.11162485}
  | RHipJoint -> {bone = RHipJoint; enabled = true; size = {|4.659840;
    4.659840; 6.097925|}; pos = {|-2.150189; -1.881512; 1.064323|};
    rot = {qx = 0.375683; qy = -0.429330; qz = 0.000000; qs =
	0.821303}; mass = 3.0}
  | RFemur -> {bone = RFemur; enabled = true; size = {|4.597451;
    4.597451; 16.850399|}; pos = {|-7.181965; -11.680123; 2.128645|};
    rot = {qx = 0.696363; qy = -0.122787; qz = -0.122787; qs =
	0.696363}; mass = 5.93510880}
  | RTibia -> {bone = RTibia; enabled = true; size = {|4.337556;
    4.337556; 17.350225|}; pos = {|-13.026905; -27.738977; 1.695070|};
    rot = {qx = 0.713552; qy = -0.125818; qz = -0.119679; qs =
	0.678738}; mass = 3.51998805}
  | RFoot -> {bone = RFoot; enabled = true; size = {|3.977424;
    3.977424; 4.841075|}; pos = {|-16.215303; -36.499031; 3.590887|};
    rot = {qx = 0.135130; qy = -0.023827; qz = -0.172005; qs =
	0.975491}; mass = 1.12088208}
  | LowerBack -> {bone = LowerBack; enabled = true; size = {|4.073971;
    4.073971; 5.003900|}; pos = {|-0.031552; 2.493519; -0.202789|};
    rot = {qx = -0.735145; qy = -0.009302; qz = 0.000000; qs =
	0.677843}; mass = 13.40858920}
  | UpperBack -> {bone = UpperBack; enabled = true; size = {|4.014784;
    4.014784; 4.903600|}; pos = {|-0.003502; 7.432600; -0.241279|};
    rot = {qx = -0.682800; qy = 0.016641; qz = 0.000000; qs =
	0.730413}; mass = 12.0}
  | Thorax -> {bone = Thorax; enabled = true; size = {|4.066469;
    4.066469; 4.991100|}; pos = {|0.137105; 12.358345; 0.187403|}; rot
      = {qx = -0.668244; qy = 0.021825; qz = 0.000000; qs = 0.743619};
    mass = 10.0}
  | LowerNeck -> {bone = LowerNeck; enabled = true; size = {|3.375753;
    3.375753; 3.905550|}; pos = {|0.300635; 16.769709; 0.729377|}; rot
      = {qx = -0.654324; qy = 0.027961; qz = 0.000000; qs = 0.755695};
    mass = 5.87688157}
  | UpperNeck -> {bone = UpperNeck; enabled = true; size = {|3.417371;
    3.417371; 3.966475|}; pos = {|0.314781; 20.627439; 0.541177|}; rot
      = {qx = -0.785273; qy = -0.027871; qz = 0.000000; qs =
	  0.618519}; mass = 3.0}
  | Head -> {bone = Head; enabled = true; size = {|3.450344; 3.450344;
    4.015100|}; pos = {|0.227126; 24.552254; -0.116532|}; rot = {qx =
	-0.740099; qy = -0.007140; qz = 0.000000; qs = 0.672457}; mass
      = 5.87688157}
  | LClavicle -> {bone = LClavicle; enabled = true; size = {|5.311928;
    5.311928; 7.675075|}; pos = {|3.854127; 16.065308; 0.418672|}; rot
      = {qx = -0.227028; qy = 0.672882; qz = 0.000000; qs = 0.704048};
    mass = 1.5}
  | LHumerus -> {bone = LHumerus; enabled = true; size = {|5.942909;
    5.942909; 11.028575|}; pos = {|13.004432; 17.292088; 0.385557|};
    rot = {qx = -0.612372; qy = 0.353553; qz = -0.612372; qs =
	0.353553}; mass = 2.21222229}
  | LRadius -> {bone = LRadius; enabled = true; size = {|5.431472;
    5.431472; 8.043400|}; pos = {|22.535393; 17.392588; 0.559629|};
    rot = {qx = -0.603343; qy = 0.338135; qz = -0.621019; qs =
	0.368751}; mass = 1.10030929}
  | RClavicle -> {bone = RClavicle; enabled = true; size = {|5.237526;
    5.237526; 7.463150|}; pos = {|-3.247896; 16.217402; 0.350926|};
    rot = {qx = -0.264890; qy = -0.665842; qz = 0.000000; qs =
	0.697484}; mass = 1.5}
  | RHumerus -> {bone = RHumerus; enabled = true; size = {|5.949380;
    5.949380; 11.344575|}; pos = {|-12.386189; 17.596273; 0.250065|};
    rot = {qx = -0.612372; qy = -0.353553; qz = 0.612372; qs =
	0.353553}; mass = 2.21222229}
  | RRadius -> {bone = RRadius; enabled = true; size = {|5.410233;
    5.410233; 7.975075|}; pos = {|-22.041031; 17.695921; 0.422659|};
    rot = {qx = -0.603343; qy = -0.338135; qz = 0.621019; qs =
	0.368751}; mass = 1.10030929}
;;
(*     {attached_body : bone; parent_body : bone;
    attach_to_world : bool; joint_type : joint_type;
    lo_joint_range1 : float; lo_joint_range2 : float; 
    high_joint_range1 : float; high_joint_range2 : float;
    joint_anchor : vector3;
    rot_axis1 : vector3;  rot_axis2 : vector3}
*)

let pi = 3.14195;;
let deg_to_rad = 180./.pi;;

let joint_props = function
  | LHipJoint -> {attached_body = LHipJoint; parent_body = LowerBack;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	0.0; lo_joint_range2 = 0.0; high_joint_range1 =  0.0;
    high_joint_range2 =  0.0; joint_anchor =
	{|~-.0.000000;0.000001;~-.0.000000|}; rot_axis1 =
	{|0.619732;0.323668;~-.0.714962|}; rot_axis2 =
	{|0.0;0.0;0.0|}}
  | LFemur -> {attached_body = LFemur; parent_body = LHipJoint;
    attach_to_world = false; joint = TUniversal; lo_joint_range1 =
	~-.165.0 *. deg_to_rad; lo_joint_range2 = 45.0*. deg_to_rad;
    high_joint_range1 =  ~-.120.0 *. deg_to_rad; high_joint_range2 =
	20.0 *. deg_to_rad; joint_anchor =
	{|4.421082;~-.3.763035;2.128654|}; rot_axis1 =
	{|0.939693;0.342019;~-.0.000001|}; rot_axis2 =
	{|0.000000;0.000000;1.000000|}}
  | LTibia -> {attached_body = LTibia; parent_body = LFemur;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	0.05; lo_joint_range2 = 165.0 *. deg_to_rad; high_joint_range1
	  =  ~-.pi; high_joint_range2 =  pi; joint_anchor =
	{|10.024943;~-.19.159527;2.128654|}; rot_axis1 =
	{|0.939693;0.342019;~-.0.000001|}; rot_axis2 =
	{|0.0;0.0;0.0|}}
  | LFoot -> {attached_body = LFoot; parent_body = LTibia;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	~-.0.2; lo_joint_range2 = 0.2; high_joint_range1 =  ~-.0.2;
    high_joint_range2 =  0.2; joint_anchor =
	{|15.836287;~-.35.126095;1.278382|}; rot_axis1 =
	{|0.939693;0.342020;0.000000|}; rot_axis2 = {|0.0;0.0;0.0|}}
  | RHipJoint -> {attached_body = RHipJoint; parent_body = LowerBack;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	0.0; lo_joint_range2 = 0.0; high_joint_range1 =  0.0;
    high_joint_range2 =  0.0; joint_anchor =
	{|~-.0.000001;~-.0.000001;0.000001|}; rot_axis1 =
	{|0.631352;~-.0.322584;0.705220|}; rot_axis2 =
	{|0.0;0.0;0.0|}}
  | RFemur -> {attached_body = RFemur; parent_body = RHipJoint;
    attach_to_world = false; joint = TUniversal; lo_joint_range1 =
	~-.165.0 *. deg_to_rad; lo_joint_range2 = 45.0*. deg_to_rad;
    high_joint_range1 =  ~-.120.0 *. deg_to_rad; high_joint_range2 =
	20.0 *. deg_to_rad; joint_anchor =
	{|~-.4.300385;~-.3.763023;2.128645|}; rot_axis1 =
	{|0.939693;~-.0.342019;0.000001|}; rot_axis2 =
	{|~-.0.000000;0.000000;1.000000|}}
  | RTibia -> {attached_body = RTibia; parent_body = RFemur;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	0.05; lo_joint_range2 = 165.0 *. deg_to_rad; high_joint_range1
	  =  ~-.pi; high_joint_range2 =  pi; joint_anchor =
	{|~-.10.063559;~-.19.597225;2.128645|}; rot_axis1 =
	{|0.939693;~-.0.342019;0.000001|}; rot_axis2 =
	{|0.0;0.0;0.0|}}
  | RFoot -> {attached_body = RFoot; parent_body = RTibia;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	~-.0.2; lo_joint_range2 = 0.2; high_joint_range1 =  ~-.0.2;
    high_joint_range2 =  0.2; joint_anchor =
	{|~-.15.990259;~-.35.880726;1.261497|}; rot_axis1 =
	{|0.939693;~-.0.342019;0.000000|}; rot_axis2 =
	{|0.0;0.0;0.0|}}
  | LowerBack -> {attached_body = LowerBack; parent_body = UpperBack;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	~-.45.0 *. deg_to_rad; lo_joint_range2 = 25.0 *. deg_to_rad;
    high_joint_range1 =  ~-.pi; high_joint_range2 =  pi; joint_anchor
      = {|~-.0.063104;4.987037;~-.0.405578|}; rot_axis1 =
	{|0.999827;0.013677;0.012611|}; rot_axis2 = {|0.0;0.0;0.0|}}
  | UpperBack -> {attached_body = UpperBack; parent_body = Thorax;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	~-.20.0*. deg_to_rad; lo_joint_range2 = 10.0*. deg_to_rad;
    high_joint_range1 =  0.0; high_joint_range2 = 0.0; joint_anchor =
	{|0.056100;9.878162;~-.0.076980|}; rot_axis1 =
	{|0.999446;~-.0.022725;~-.0.024310|}; rot_axis2 =
	{|0.0;0.0;0.0|}}
  | Thorax -> {attached_body = Thorax; parent_body = LowerNeck;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	~-.5.0*. deg_to_rad; lo_joint_range2 =2.5*. deg_to_rad;
    high_joint_range1 = 0.0; high_joint_range2 = 0.0; joint_anchor =
	{|0.218111;14.838529;0.451788|}; rot_axis1 =
	{|0.999047;~-.0.029170;~-.0.032460|}; rot_axis2 =
	{|0.0;0.0;0.0|}}
  | LowerNeck -> {attached_body = LowerNeck; parent_body = UpperNeck;
    attach_to_world = false; joint = TUniversal; lo_joint_range1 =
	~-.50.0 *. deg_to_rad; lo_joint_range2 = 89.0 *. deg_to_rad;
    high_joint_range1 =  ~-.60.0*. deg_to_rad; high_joint_range2 =
	60.0*. deg_to_rad; joint_anchor =
	{|0.383159;18.700890;1.006970|}; rot_axis1 =
	{|0.998436;~-.0.036591;~-.0.042260|}; rot_axis2 =
	{|~-.0.036591;0.143717;~-.0.988942|}}
  | UpperNeck -> {attached_body = UpperNeck; parent_body = Head;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	~-.45.0 *. deg_to_rad; lo_joint_range2 = 45.0 *. deg_to_rad;
    high_joint_range1 =  0.0; high_joint_range2 =  0.0; joint_anchor =
	{|0.246403;22.553988;0.075381|}; rot_axis1 =
	{|0.998446;0.043773;0.034478|}; rot_axis2 = {|0.0;0.0;0.0|}}
  | Head -> {attached_body = Head; parent_body = Head; attach_to_world
      = true; joint = THinge; lo_joint_range1 = ~-.pi;
    lo_joint_range2 = pi; high_joint_range1 =  ~-.pi;
    high_joint_range2 =  pi; joint_anchor =
	{|0.207849;26.550516;~-.0.308451|}; rot_axis1 =
	{|0.999898;0.010568;0.009602|}; rot_axis2 = {|0.0;0.0;0.0|}}
  | LClavicle -> {attached_body = LClavicle; parent_body = Thorax;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	0.0; lo_joint_range2 =0.0; high_joint_range1 = 0.0;
    high_joint_range2 = 0.0; joint_anchor =
	{|0.218112;14.838528;0.451786|}; rot_axis1 =
	{|0.094455;~-.0.305528;~-.0.947487|}; rot_axis2 =
	{|0.0;0.0;0.0|}}
  | LHumerus -> {attached_body = LHumerus; parent_body = LClavicle;
    attach_to_world = false; joint = TUniversal; lo_joint_range1 =
	~-.40.0*. deg_to_rad; lo_joint_range2 = 120.0*. deg_to_rad;
    high_joint_range1 =  ~-.85.0*. deg_to_rad; high_joint_range2 =
	85.0*. deg_to_rad; joint_anchor =
	{|7.490144;17.292086;0.385556|}; rot_axis1 =
	{|0.000000;~-.0.866026;0.500000|}; rot_axis2 =
	{|~-.0.000000;0.500000;0.866026|}}
  | LRadius -> {attached_body = LRadius; parent_body = LHumerus;
    attach_to_world = false; joint = THinge; lo_joint_range1
      =0.05; lo_joint_range2 = 120.0*. deg_to_rad; high_joint_range1 =
	0.0; high_joint_range2 = 0.0; joint_anchor =
	{|18.518719;17.292088;0.385557|}; rot_axis1 =
	{|~-.0.000000;~-.0.866025;0.500000|}; rot_axis2 =
	{|0.0;0.0;0.0|}}
  | RClavicle -> {attached_body = RClavicle; parent_body = Thorax;
    attach_to_world = false; joint = THinge; lo_joint_range1 =
	0.0; lo_joint_range2 =0.0; high_joint_range1 = 0.0;
    high_joint_range2 = 0.0; joint_anchor =
	{|0.218109;14.838530;0.451787|}; rot_axis1 =
	{|0.113305;0.352752;0.928832|}; rot_axis2 = {|0.0;0.0;0.0|}}
  | RHumerus -> {attached_body = RHumerus; parent_body = RClavicle;
    attach_to_world = false; joint = TUniversal; lo_joint_range1 =
	~-.40.0*. deg_to_rad; lo_joint_range2 = 120.0*. deg_to_rad;
    high_joint_range1 =  ~-.85.0*. deg_to_rad; high_joint_range2 =
	85.0*. deg_to_rad; joint_anchor =
	{|~-.6.713902;17.596272;0.250064|}; rot_axis1 =
	{|0.000000;0.866026;~-.0.500000|}; rot_axis2 =
	{|~-.0.000000;~-.0.500000;~-.0.866026|}}
  | RRadius -> {attached_body = RRadius; parent_body = RHumerus;
    attach_to_world = false; joint = THinge; lo_joint_range1
      =0.05; lo_joint_range2 = 120.0*. deg_to_rad; high_joint_range1 =
	0.0; high_joint_range2 = 0.0; joint_anchor =
	{|~-.18.058479;17.596275;0.250065|}; rot_axis1 =
	{|~-.0.000000;0.866025;~-.0.500000|}; rot_axis2 =
	{|0.0;0.0;0.0|}}
;;

(*
    {cbone : bone; is_controllable : bool;
    ks1 : float; kd1 : float; ks2 : float; kd2 : float}
*)

let control_props_default = function
  | LHipJoint -> {cbone = LHipJoint; is_controllable = false; ks1 =
	0.0; kd1 = 0.0; ks2 = 0.0; kd2 = 0.0}
  | LFemur -> {cbone = LFemur; is_controllable = true; ks1 = 60.0; kd1
      = 15.0; ks2 = 60.0; kd2 = 15.0}
  | LTibia -> {cbone = LTibia; is_controllable = true; ks1 = 10.0; kd1
      = 2.0; ks2 = 0.0; kd2 = 0.0}
  | LFoot -> {cbone = LFoot; is_controllable = true; ks1 = 3.0; kd1 =
	1.0; ks2 = 0.0; kd2 = 0.0}
  | RHipJoint -> {cbone = RHipJoint; is_controllable = false; ks1 =
	0.0; kd1 = 0.0; ks2 = 0.0; kd2 = 0.0}
  | RFemur -> {cbone = RFemur; is_controllable = true; ks1 = 60.0; kd1
      = 15.0; ks2 = 60.0; kd2 = 15.0}
  | RTibia -> {cbone = RTibia; is_controllable = true; ks1 = 10.0; kd1
      = 2.0; ks2 = 0.0; kd2 = 0.0}
  | RFoot -> {cbone = RFoot; is_controllable = true; ks1 = 3.0; kd1 =
	1.0; ks2 = 0.0; kd2 = 0.0}
  | LowerBack -> {cbone = LowerBack; is_controllable = true; ks1 =
	100.0; kd1 = 40.0; ks2 = 0.0; kd2 = 0.0}
  | UpperBack -> {cbone = UpperBack; is_controllable = true; ks1 =
	40.0; kd1 = 15.0; ks2 = 0.0; kd2 = 0.0}
  | Thorax -> {cbone = Thorax; is_controllable = true; ks1 = 30.0; kd1
      = 10.0; ks2 = 0.0; kd2 = 0.0}
  | LowerNeck -> {cbone = LowerNeck; is_controllable = true; ks1 =
	30.0; kd1 = 10.0; ks2 = 0.0; kd2 = 0.0}
  | UpperNeck -> {cbone = UpperNeck; is_controllable = true; ks1 =
	25.0; kd1 = 4.0; ks2 = 0.0; kd2 = 0.0}
  | Head -> {cbone = Head; is_controllable = true; ks1 = 24.0; kd1 =
	4.0; ks2 = 0.0; kd2 = 0.0}
  | LClavicle -> {cbone = LClavicle; is_controllable = false; ks1 =
	0.0; kd1 = 0.0; ks2 = 0.0; kd2 = 0.0}
  | LHumerus -> {cbone = LHumerus; is_controllable = true; ks1 = 40.0;
    kd1 = 12.0; ks2 = 40.0; kd2 = 12.0}
  | LRadius -> {cbone = LRadius; is_controllable = true; ks1 = 30.0;
    kd1 = 8.0; ks2 = 0.0; kd2 = 0.0}
  | RClavicle -> {cbone = RClavicle; is_controllable = false; ks1 =
	0.0; kd1 = 0.0; ks2 = 0.0; kd2 = 0.0}
  | RHumerus -> {cbone = RHumerus; is_controllable = true; ks1 = 40.0;
    kd1 = 12.0; ks2 = 40.0; kd2 = 12.0}
  | RRadius -> {cbone = RRadius; is_controllable = true; ks1 = 30.0;
    kd1 = 8.0; ks2 = 0.0; kd2 = 0.0}
;;
  
let set_enabled obj b =
  if b then begin
    Geom.enable obj.geom;
    match obj.body with Some b -> Body.enable b | None -> ()
  end else begin
    Geom.disable obj.geom;
    match obj.body with Some b -> Body.disable b | None -> ()
  end;;

let set_pos obj pos =
  Geom.set_position obj.geom
    ~x:(world_to_sim pos.x) ~y:(world_to_sim pos.y) ~z:((world_to_sim
      pos.z)+. 3.0);
  match obj.body with None -> ()
    | Some b -> Body.set_linear_vel b ~x:0. ~y:0. ~z:0.;;

let set_rot obj rot =
  Geom.set_quaternion obj.geom rot;
  match obj.body with None -> ()
    | Some b -> Body.set_angular_vel b 0. 0. 0.;;

let get_pos obj =
  let pos = Geom.get_position obj.geom in
  {|sim_to_world pos.x; sim_to_world pos.y; sim_to_world pos.z|};;

let get_rot obj =
  let rot = Geom.get_quaternion obj.geom in
  {rot with qx = ~-.(rot.qx); qy = ~-.(rot.qy); qz = ~-.(rot.qz)};;

type joint_with_props =
    {jattached_body : bone; jparent_body : bone;
    jattach_to_world : bool; jjoint : typed_joint;
    jlo_joint_range1 : float; jlo_joint_range2 : float; 
    jhigh_joint_range1 : float; jhigh_joint_range2 : float;
    jjoint_anchor : vector3;
    jrot_axis1 : vector3;  jrot_axis2 : vector3}
;;

let adhinge jp joint =
  {jattached_body = jp.attached_body; jparent_body = jp.parent_body;
  jattach_to_world = jp.attach_to_world; jjoint = Hinge joint;
  jlo_joint_range1 = jp.lo_joint_range1;
  jlo_joint_range2 = jp.lo_joint_range2; 
  jhigh_joint_range1 = jp.high_joint_range1;
  jhigh_joint_range2 = jp.high_joint_range2;
  jjoint_anchor = jp.joint_anchor;
  jrot_axis1 = jp.rot_axis1;  jrot_axis2 = jp.rot_axis2}
let aduniversal jp joint =
  {jattached_body = jp.attached_body; jparent_body = jp.parent_body;
  jattach_to_world = jp.attach_to_world; jjoint = Universal joint;
  jlo_joint_range1 = jp.lo_joint_range1;
  jlo_joint_range2 = jp.lo_joint_range2; 
  jhigh_joint_range1 = jp.high_joint_range1;
  jhigh_joint_range2 = jp.high_joint_range2;
  jjoint_anchor = jp.joint_anchor;
  jrot_axis1 = jp.rot_axis1;  jrot_axis2 = jp.rot_axis2}
let adnone jp =
  {jattached_body = jp.attached_body; jparent_body = jp.parent_body;
  jattach_to_world = jp.attach_to_world; jjoint = Nojoint;
  jlo_joint_range1 = jp.lo_joint_range1;
  jlo_joint_range2 = jp.lo_joint_range2; 
  jhigh_joint_range1 = jp.high_joint_range1;
  jhigh_joint_range2 = jp.high_joint_range2;
  jjoint_anchor = jp.joint_anchor;
  jrot_axis1 = jp.rot_axis1;  jrot_axis2 = jp.rot_axis2}

let create_bodies_and_joints allow_attach_to_world =
  let bodies = map_bones (fun b ->
    let bprop = body_props b in
    let newbox = create_stdbox bprop.size (Total bprop.mass)
      ~color:(if b = LowerBack then force_color else std_color)
      ~catbits:(
	match b with LHipJoint | RHipJoint -> Nativeint.of_int 2
	  | LClavicle | RClavicle -> Nativeint.of_int 4
	  | _ -> Nativeint.of_int 1)
      ~colbits:(
	match b with LHipJoint | RHipJoint -> Nativeint.of_int (4+1)
	  | LClavicle | RClavicle -> Nativeint.of_int (2+1)
	  | _ -> Nativeint.of_int (1+2+4))
    in
    set_pos newbox bprop.pos;
    set_rot newbox bprop.rot;
    set_enabled newbox false;
    objects := newbox::(!objects); newbox
  ) in
  bodies, map_bones (fun b ->
    let jprop = joint_props b in
    if jprop.attach_to_world && not allow_attach_to_world then
      adnone jprop
    else match jprop.joint with
	THinge ->
	  let newjoint = Joint.create_hinge world in
	  if jprop.attach_to_world then
	    Joint.attach newjoint ?b1:((bodies b).body) ()
	  else
	    Joint.attach newjoint ?b1:((bodies b).body)
	      ?b2:((bodies (jprop.parent_body)).body) ();
	  Joint.set_hinge_anchor newjoint
	    ~x:(world_to_sim jprop.joint_anchor.x)
	    ~y:(world_to_sim jprop.joint_anchor.y)
	    ~z:(world_to_sim jprop.joint_anchor.z);
	  Joint.set_hinge_axis newjoint
	    ~x:(world_to_sim jprop.rot_axis1.x)
	    ~y:(world_to_sim jprop.rot_axis1.y)
	    ~z:(world_to_sim jprop.rot_axis1.z) ();
	  (if not jprop.attach_to_world then
	    open Joint in
	    set_hinge_param newjoint Lo_stop jprop.lo_joint_range1;
	    set_hinge_param newjoint Hi_stop jprop.high_joint_range1;
	    set_hinge_param newjoint Lo_stop jprop.lo_joint_range1;
	    set_hinge_param newjoint Hi_stop jprop.high_joint_range1);
	  set_enabled (bodies b) true;
	  let an1 = Joint.get_hinge_anchor newjoint in
	  let an2 = Joint.get_hinge_anchor2 newjoint in
	  let f2s = string_of_float in
	  print_string ((bone_names b)^
	    " hinge: x1="^(f2s an1.x)^",y1="^(f2s an1.y)^
	    ",z1="^(f2s an1.z)^" x2="^(f2s an2.x)^",y2="^(f2s an2.y)
	  ^",z2="^(f2s an2.z)^"\n");
	  adhinge jprop newjoint
      | TUniversal ->
	  let newjoint = Joint.create_universal world in
	  if jprop.attach_to_world then
	    Joint.attach newjoint ?b1:((bodies b).body) ()
	  else
	    Joint.attach newjoint ?b1:((bodies b).body)
	      ?b2:((bodies (jprop.parent_body)).body) ();
	  Joint.set_universal_anchor newjoint
	    ~x:(world_to_sim jprop.joint_anchor.x)
	    ~y:(world_to_sim jprop.joint_anchor.y)
	    ~z:(world_to_sim jprop.joint_anchor.z);
	  Joint.set_universal_axis1 newjoint
	    ~x:(world_to_sim jprop.rot_axis1.x)
	    ~y:(world_to_sim jprop.rot_axis1.y)
	    ~z:(world_to_sim jprop.rot_axis1.z) ();
	  Joint.set_universal_axis2 newjoint
	    ~x:(world_to_sim jprop.rot_axis2.x)
	    ~y:(world_to_sim jprop.rot_axis2.y)
	    ~z:(world_to_sim jprop.rot_axis2.z) ();
	  (if not jprop.attach_to_world then
	    open Joint in
	    set_universal_param newjoint Lo_stop jprop.lo_joint_range1;
	    set_universal_param newjoint Hi_stop jprop.high_joint_range1;
	    set_universal_param newjoint Lo_stop jprop.lo_joint_range1;
	    set_universal_param newjoint Hi_stop jprop.high_joint_range1;
	    set_universal_param newjoint ~ax:Second_ax
	      Lo_stop jprop.lo_joint_range2;
	    set_universal_param newjoint ~ax:Second_ax
	      Hi_stop jprop.high_joint_range2;
	    set_universal_param newjoint ~ax:Second_ax
	      Lo_stop jprop.lo_joint_range2;
	    set_universal_param newjoint ~ax:Second_ax
	      Hi_stop jprop.high_joint_range2);
	  set_enabled (bodies b) true;
	  let an1 = Joint.get_universal_anchor newjoint in
	  let an2 = Joint.get_universal_anchor2 newjoint in
	  let f2s = string_of_float in
	  print_string ((bone_names b)^
	    " universal: x1="^(f2s an1.x)^",y1="^(f2s an1.y)^
	    ",z1="^(f2s an1.z)^" x2="^(f2s an2.x)^",y2="^(f2s an2.y)
	  ^",z2="^(f2s an2.z)^"\n");
	  aduniversal jprop newjoint)
;;

let control_props = control_props_default;;
let bodies, joints = create_bodies_and_joints !allow_attach_to_world;;

let max_torque = ref 60.0;;

let clamp_torque torque =
  if torque > !max_torque then !max_torque
  else if torque < ~-. !max_torque then ~-. !max_torque
  else torque
;;

let apply_control_torques () =
  if !is_controller_enabled then
    iterate_bones (fun b ->
      let cprop = control_props b
      and bprop = body_props b
      and jprop = joints b in
      if cprop.is_controllable && bprop.enabled
	&& not jprop.jattach_to_world
      then
	let desired_x = 0.0 in
	let desired_y = 0.0 in
	match jprop.jjoint with
	  | Hinge hinge ->
	      let cur_angle_x = Joint.get_hinge_angle hinge in
	      let cur_vel_x = Joint.get_hinge_angle_rate hinge in
	      let torque_x = cprop.ks1 *. (desired_x -. cur_angle_x)
		-. cprop.kd1 *. cur_vel_x in
	      Joint.add_hinge_torque hinge (clamp_torque torque_x)
	  | Universal universal ->
	      let cur_angle_x = Joint.get_universal_angle1 universal in
	      let cur_vel_x = Joint.get_universal_angle1_rate universal in
	      let torque_x = cprop.ks1 *. (desired_x -. cur_angle_x)
		-. cprop.kd1 *. cur_vel_x in
	      let cur_angle_y = Joint.get_universal_angle2 universal in
	      let cur_vel_y = Joint.get_universal_angle2_rate universal in
	      let torque_y = cprop.ks1 *. (desired_y -. cur_angle_y)
		-. cprop.kd1 *. cur_vel_y in
	      Joint.add_universal_torques universal
		~fst_ax:(clamp_torque torque_x)
		~snd_ax:(clamp_torque torque_y)
	  | Nojoint -> ()
    )
;;

let _ = Drawstuff.init ();;

let start() =
  Drawstuff.set_viewpoint  ~xyz:{|3.8548; 9.0843; 7.5900|}
    ~hpr:{|-145.5; -22.5; 0.25|};
  print_string ("Press:\t'c' to disable/enable controller.\n"^
			"\t'f' to apply force to pelvis.\n"^
			"\t'r' to reset simulation.\n");
  flush stdout
;;

let rec near_callback ~o1 ~o2 =

  (* Collision filtering is done by category/collide bitfields *)

  let isp1 =
    Geom.match_kind o1
      ~space:(fun sp -> (Space.collide sp near_callback; true))
      ~default:(fun _ -> false) ()
  and isp2 =
    Geom.match_kind o2
      ~space:(fun sp -> Space.collide sp near_callback; true)
      ~default:(fun _ -> false) ()
  in if isp1 || isp2
  then Space.collide2 o1 o2 near_callback
  else 
    match Geom.get_body o1, Geom.get_body o2 with
	Some b1, Some b2
	  when Joint.are_connected_excluding b1 b2 Joint.Contact_j -> ()
      | b1, b2 -> 
	  match Geom.collide o1 o2 ~max:max_contact_points with
	      None -> ()
	    | Some cs ->
	      Contact.iter ~contact
		~f:(fun c ->
		  let joint = Contact.create_joint world
		    ~dst:contactgroup c in
		  Joint.attach joint ?b1 ?b2 ()) cs
;;


let render ctrl_state =
  force_color := if ctrl_state then high_color else low_color;
  List.iter (fun obj -> render_obj obj) !objects
;;

let set_velocity obj {|x; y; z|} = match obj.body with None -> ()
  | Some b -> Body.set_linear_vel b ~x ~y ~z;;
let zero_velocity obj = match obj.body with None -> ()
  | Some b -> (*Body.set_linear_vel b ~x:0.0 ~y:0.0 ~z:0.0;*)
      Body.set_angular_vel b ~x:0.0 ~y:0.0 ~z:0.0;;
let add_force obj {|fx; fy; fz|} = match obj.body with None -> ()
  | Some b -> Body.add_force b ~fx ~fy ~fz;;
let zero_force obj = match obj.body with None -> ()
  | Some b -> Body.set_force b ~x:0.0 ~y:0.0 ~z:0.0;;
let zero_torque obj = match obj.body with None -> ()
  | Some b -> Body.set_torque b ~x:0.0 ~y:0.0 ~z:0.0;;

let enable_controller () =
  is_controller_enabled := not !is_controller_enabled
;;

let apply_force () = ()

let reset_simulation () =
  World.set_CFM world 1e-5;
  World.set_ERP world 0.3;
  sim.gravity <- -9.8;
  List.iter (fun b ->
    zero_velocity b;
    (* zero_force b;*) zero_torque b) !objects;
;;

let stats () =
  iterate_bones (fun b ->
    let j = joints b in
    match j.jjoint with
      | Universal j ->
	  let an1 = Joint.get_universal_anchor j in
	  let an2 = Joint.get_universal_anchor2 j in
	  let f2s = string_of_float in
	  print_string ((bone_names b)^
	    " universal: xd="^(f2s (an1.x -. an2.x))^",yd="^(f2s
  	      (an1.y -. an2.y))^
	    ",zd="^(f2s (an1.z -. an2.z))^"\n")
      | Hinge j ->
	  let an1 = Joint.get_hinge_anchor j in
	  let an2 = Joint.get_hinge_anchor2 j in
	  let f2s = string_of_float in
	  print_string ((bone_names b)^
	    " hinge: xd="^(f2s (an1.x -. an2.x))^",yd="^(f2s
  	      (an1.y -. an2.y))^
	    ",zd="^(f2s (an1.z -. an2.z))^"\n")
      | Nojoint -> ())
;;

let update dt =
  reset_simulation ();
  stats ();
  (* Space.collide space near_callback; *)
  if sim.do_fast then
    World.quick_step world dt
  else World.step world dt;
  JointGroup.empty contactgroup;
  (* if !is_controller_enabled then apply_control_torques () *)
;;

let sim_loop pause =
  update timestep;
  render !is_controller_enabled
;;

let command cmd =
  match cmd with
      'c' | 'C' -> enable_controller ()
    | 'f' | 'F' -> apply_force ()
    | 'r' | 'R' -> reset_simulation ()
    | _ -> ()
;;

(*
	//create the ODE simulator
	gSimulator = new ODESimulation();
	//create ragdoll character
	ODEPosition pos;
	pos[0] = pos[1] = pos[2] = 0.0f;
	gRagdoll = new ODEHuman(pos,gSimulator);
*)

let main () =

  reset_simulation ();
  stats ();
  Drawstuff.simulation_loop ~width:352 ~height:288 ~start:(start)
    ~step:(sim_loop) ~command:(command)
    ~path:("../ode-0.5/drawstuff/textures") ()
;;

let _ = main ()
;;
