(*
 This is a demo of the QuickStep and StepFast methods,
 originally by David Whittaker.
  Rewritten by Lukasz Stafiniak, copyright 2005.
*)
open Ode;;

let _ = Drawstuff.init ();;

let vLENGTH =  3.5		(* chassis length *)
let vWIDTH =  2.5		(* chassis width *)
let vHEIGHT =  1.0		(* chassis height *)
let vRADIUS =  0.5		(* wheel radius *)
let vSTARTZ =  1.0		(* starting height of chassis *)
let vCMASS =  1.			(* chassis mass *)
let vWMASS =  1.			(* wheel mass *)
let vCOMOFFSET =  -5.		(* center of mass offset *)
let vWALLMASS =  1.		(* wall box mass *)
let vBALLMASS =  1.		(* ball mass *)
let vFMAX =  25.		(* car engine fmax *)
let vITERS =  20		(* number of iterations *)
let vWBOXSIZE =  1.0		(* size of wall boxes *)
let vWALLWIDTH =  20.		(* width of wall *)
let vWALLHEIGHT =  10.		(* height of wall *)
let vDISABLE_THRESHOLD = 0.008	(* maximum velocity (squared) a body
				   can have and be disabled *)
let vDISABLE_STEPS = 10         (* number of steps a box has to have
				   been disable-able before it will be
				   disabled *)
let vCANNON_X = -10.		(* x position of cannon *)
let vCANNON_Y = 5.		(* y position of cannon *)
let vCANNON_BALL_MASS = 10.	(* mass of the cannon ball *)
let vCANNON_BALL_RADIUS = 0.5

(* things that the user controls *)

let turn = ref 0.
let speed = ref 0.
let lspeed = 0.
let do_fast = ref false
let cannon_angle = ref 0.
let cannon_elevation = ref (-1.2)

let contact1, contact2 =
  let params = 
    [Contact.Slip1 0.0; Contact.Slip2 0.0; Contact.SoftERP 0.8;
    Contact.SoftCFM 0.01] in
  Contact.be ~mu:0.5 params, Contact.be ~mu:20. params

let start() =
  Drawstuff.set_viewpoint ~xyz:{|3.8548; 9.0843; 7.5900|}
    ~hpr:{|-145.5; -22.5; 0.25|};
  print_string ("Press:\t'a' to increase speed.\n"^
			"\t'z' to decrease speed.\n"^
			"\t',' to steer left.\n"^
			"\t'.' to steer right.\n"^
			"\t' ' to reset speed and steering.\n"^
			"\t'[' to turn the cannon left.\n"^
			"\t']' to turn the cannon right.\n"^
			"\t'1' to raise the cannon.\n"^
			"\t'2' to lower the cannon.\n"^
			"\t'x' to shoot from the cannon.\n"^
			"\t'f' to toggle fast step mode.\n"^
			"\t'+' to increase AutoEnableDepth.\n"^
			"\t'-' to decrease AutoEnableDepth.\n"^
			"\t'r' to reset simulation.\n");
  flush stdout

let world = Ode.init (); World.create ()
let bodies = ref []
let joints = ref []
let boxes = ref []
let spheres = ref []
let cannon_ball_body = ref None
let wall_boxes = ref []
let wall_bodies = ref []
let contactgroup = JointGroup.create ()
let space = ref (Space.hash_create ())

let vBOX = ref true
let vCARS = ref true
let vWALL = ref true
let vBALLS = ref true
let vBALLSTACK = ref true
let vONEBALL = ref true
let vCENTIPEDE = ref true
let vCANNON = ref true
let vROWS = ref 2
let vCOLS = ref 2
let vQUICKSTEP = ref true

let pi = 3.14159265358979323846

let near_callback ~o1 ~o2 =
  match Geom.get_body o1, Geom.get_body o2 with
      Some b1, Some b2 when Joint.are_connected b1 b2 -> ()
    | b1, b2 -> 
	match Geom.collide o1 o2 ~max:4 with
	    None -> ()
	  | Some cs ->
	      let ct =
		if Geom.get_class o1 == `Sphere_c
		  || Geom.get_class o2 == `Sphere_c
		then contact2 else contact1 in
	      Contact.iter ~contact:ct
		~f:(fun c ->
		  let joint = Contact.create_joint world
		    ~dst:contactgroup c in
		  Joint.attach joint ?b1 ?b2 ()) cs
		  
let make_car x y =
  let chassis = Body.create world in
  Body.set_position chassis ~x ~y ~z:vSTARTZ;
  let mass = Mass.box_total ~mass:(vCMASS /. 2.)
    ~lx:vLENGTH ~ly:vWIDTH ~lz:vHEIGHT in
  Mass.set chassis mass;
  let chassis_box = Geom.create_box ~dst:(!space)
    ~lx:vLENGTH ~ly:vWIDTH ~lz:vHEIGHT () in
  Geom.set_body chassis_box (Some chassis);
  bodies := chassis:: !bodies;
  boxes := chassis_box:: !boxes;
  for i=1 to 4 do
    let wheel = Body.create world in
    let q = Math.q_from_axis_and_angle
      ~ax:1. ~ay:0. ~az:0. ~angle:(pi *. 0.5) in
    Body.set_quaternion wheel q;
    let mass = Mass.sphere_total ~mass:vWMASS ~radius:vRADIUS in
    Mass.set wheel mass;
    let wheel_sphere = Geom.create_sphere ~dst:(!space) ~radius:vRADIUS
      () in
    Geom.set_body wheel_sphere (Some wheel);
    let x =  x+. (if i<=2 then 1. else -1.)
      *. (0.4*.vLENGTH-.0.5*.vRADIUS) in
    let y = y+. (if i mod 2 == 1 then 1.0 else -1.) *. vWIDTH*.0.5 in
    let z = vSTARTZ -. vHEIGHT*.0.5 in
    Body.set_position wheel ~x ~y ~z;
    bodies := wheel:: !bodies;
    spheres := wheel_sphere:: !spheres;
    open Joint in
    let hinge = create_hinge2 world in
    attach hinge ~b1:chassis ~b2:wheel ();
    set_hinge2_anchor hinge ~x ~y ~z;
    set_hinge2_axis1 hinge ~z:(if i <=2 then 1. else -1.) ();
    set_hinge2_axis2 hinge ~y:1. ();
    set_hinge2_param hinge Suspension_ERP 0.8;
    set_hinge2_param hinge Suspension_CFM 1e-5;
    set_hinge2_param hinge ~ax:Second_ax Vel 0.0;
    set_hinge2_param hinge ~ax:Second_ax FMax vFMAX;
    joints := hinge:: !joints
  done;
  let com = Body.create world in	(* Center Of Mass *)
  Body.set_position com ~x ~y ~z:(vSTARTZ+.vCOMOFFSET);
  let mass = Mass.box_total ~mass:(vCMASS/.2.0) ~lx:vLENGTH ~ly:vWIDTH
    ~lz:vHEIGHT in
  Mass.set com mass;
  let fix = Joint.create_fixed world in
  Joint.attach fix ~b1:chassis ~b2:com ();
  Joint.set_fixed fix;
  bodies := com:: !bodies

let i2f = float_of_int

let ask s = true

let ask_int s = 1

let reset_simulation () =
  if !bodies <> [] then begin
    JointGroup.empty contactgroup;
    bodies := [];
    joints := [];
    boxes := [];
    wall_boxes := [];
    spheres := [];
    cannon_ball_body := None;
    space := Space.hash_create ();
    World.reset world;
    Gc.compact ()
  end;
  World.set_gravity world ~z:(-1.5) ();
  World.set_CFM world 1e-5;
  World.set_ERP world 0.8;
  World.set_quick_step_num_iterations world vITERS;
  ignore (Geom.create_plane ~dst:(!space) ~c:1. ());
  vBOX := ask "BOX";
  vCARS := ask "CARS";
  vWALL := ask "WALL";
  vBALLS := ask "BALLS";
  vBALLSTACK := ask "BALLSTACK";
  vONEBALL := ask "ONEBALL";
  vCENTIPEDE := ask "CENTIPEDE";
  vCANNON := ask "CANNON";
  vROWS := ask_int "ROWS";			(* rows of cars *)
  vCOLS := ask_int "COLS";			(* columns of cars *)
  vQUICKSTEP := ask "QUICKSTEP";
  if !vCARS then
    for i = 1 to !vCOLS do
      let x = (i2f i) *. (vLENGTH+.vRADIUS) in
      for j = 1 to !vROWS do
	let y = (i2f j) *. (vWIDTH+.vRADIUS*.2.) -.
	  (vWIDTH+.vRADIUS*.2.) /. 2. in
	make_car x y
      done
    done;
  if !vWALL then begin
    let rec row z offset =
      let rec brick y =
	let b = Body.create world in
	Body.set_position b ~x:(-20.) ~y ~z;
	let m = Mass.box_total ~mass:vWALLMASS ~lx:vWBOXSIZE
	  ~ly:vWBOXSIZE ~lz:vWBOXSIZE in
	Mass.set b m;
	let box = Geom.create_box ~dst:(!space) ~lx:vWBOXSIZE
	  ~ly:vWBOXSIZE ~lz:vWBOXSIZE () in
	Geom.set_body box (Some b);
	wall_bodies := b:: !wall_bodies;
	wall_boxes := (ref 0, box):: !wall_boxes;
	if y+.vWBOXSIZE <= (vWALLWIDTH-.z) /. 2. then
	  brick (y+.vWBOXSIZE)
      in
      brick ((z-.vWALLWIDTH) /. 2.);
      if z+.vWBOXSIZE <= vWALLHEIGHT then
	row (z +. vWBOXSIZE) (not offset)
    in row (vWBOXSIZE /. 2.) true
  end;
  if !vBALLS then
    for i= -7 to -4 do
      for j= -1 to 2 do
	for k=1 to 4 do
	  let b = Body.create world in
	  Body.set_position b ~x:((i2f i)*.vRADIUS*.2.)
	    ~y:((i2f j)*.vRADIUS*.2.) ~z:((i2f k)*.vRADIUS*.2.);
	  let m = Mass.sphere_total ~mass:vBALLMASS ~radius:vRADIUS in
	  Mass.set b m;
	  let sph = Geom.create_sphere ~dst:(!space) ~radius:vRADIUS () in
	  Geom.set_body sph (Some b);
	  spheres := sph:: !spheres
	done
      done
    done;
  if !vONEBALL then begin
    let b = Body.create world in
    Body.set_position b ~x:0. ~y:0. ~z:2.;
    let m = Mass.sphere_total ~mass:1. ~radius:vRADIUS in
    Mass.set b m;
    let sph = Geom.create_sphere ~dst:(!space) ~radius:vRADIUS () in
    Geom.set_body sph (Some b);
    spheres := sph:: !spheres
  end;
  if !vBALLSTACK then
    for i=1 to 6 do
      let b = Body.create world in
      Body.set_position b ~x:0. ~y:0. ~z:((i2f i)*.vRADIUS*.2.);
      let m = Mass.sphere_total ~mass:0.1 ~radius:vRADIUS in
      let sph = Geom.create_sphere ~dst:(!space) ~radius:vRADIUS () in
      Geom.set_body sph (Some b);
      spheres := sph:: !spheres
    done;
  if !vCENTIPEDE then begin
    let rec chassis y last =
      let b = Body.create world in
      Body.set_position b ~x:(-15.) ~y ~z:vSTARTZ;
      let m = Mass.box_total ~mass:vCMASS ~lx:vWIDTH ~ly:vLENGTH
	~lz:vHEIGHT in
      Mass.set b m;
      let box = Geom.create_box ~dst:(!space) ~lx:vWIDTH ~ly:vLENGTH
	~lz:vHEIGHT () in
      Geom.set_body box (Some b);
      boxes := box:: !boxes;
      bodies := b:: !bodies;
      let rec legs x ?last_left ?last_right () =
	let leg x vel last =
	  let lb = Body.create world in
	  Body.set_position lb ~x ~y ~z:vSTARTZ;
	  let m = Mass.sphere_total ~mass:vWMASS ~radius:vRADIUS in
	  Mass.set lb m;
	  let sph = Geom.create_sphere ~dst:(!space) ~radius:vRADIUS () in
	  Geom.set_body sph (Some lb);
	  open Joint in
	  let j = create_hinge2 world in
	  (match last with
	      None -> attach j ~b1:b ~b2:lb ()
	    | Some old ->  attach j ~b1:old ~b2:lb ());
	  set_hinge2_anchor j ~x ~y ~z:vSTARTZ;
	  set_hinge2_axis1 j ~z:1. ();
	  set_hinge2_axis2 j ~x:1. ();
	  set_hinge2_param j Suspension_ERP 1.0;
	  set_hinge2_param j Suspension_CFM 1e-5;
	  set_hinge2_param j Lo_stop 0.0;
	  set_hinge2_param j Hi_stop 0.0;
	  set_hinge2_param j ~ax:Second_ax Vel vel;
	  set_hinge2_param j ~ax:Second_ax FMax vFMAX;
	  bodies := lb:: !bodies;
	  spheres := sph:: !spheres;
	  joints := j:: !joints;
	  lb in
	if x > -20. then
	  legs (x -. vRADIUS*.2.)
	    ~last_left:(leg x (-10.0) last_left)
	    ~last_right:(leg (-30. -. x) 10.0 last_right) () in
      legs (-17.) ();
      (match last with None -> ()
	| Some old ->
	    let j = Joint.create_fixed world in
	    Joint.attach j ~b1:b ~b2:old ();
	    Joint.set_fixed j);
      if y < 10.*.vLENGTH then
	chassis (y+.vLENGTH+.0.1) (Some b) in
    chassis 0. None
  end;
  if !vBOX then begin
    let b = Body.create world in
    Body.set_position b ~x:0. ~y:0. ~z:(vHEIGHT/.2.);
    let m = Mass.box_total ~mass:1. ~lx:vLENGTH ~ly:vWIDTH ~lz:vHEIGHT
    in Mass.set b m;
    let box = Geom.create_box ~dst:(!space)  ~lx:vLENGTH ~ly:vWIDTH
      ~lz:vHEIGHT () in
    Geom.set_body box (Some b);
    bodies := b:: !bodies
  end;
  if !vCANNON then begin
    let b = Body.create world in
    Body.set_position b ~x:vCANNON_X ~y:vCANNON_Y ~z:vCANNON_BALL_RADIUS;
    let sph = Geom.create_sphere ~dst:(!space)
      ~radius:vCANNON_BALL_RADIUS () in
    Geom.set_body sph (Some b);
    let m = Mass.sphere_total ~mass:vCANNON_BALL_MASS
      ~radius:vCANNON_BALL_RADIUS in
    Mass.set b m;
    cannon_ball_body := Some b;
  end

let command cmd =
  match cmd with
      'a' | 'A' -> speed := !speed +. 0.3
    | 'z' | 'Z' -> speed := !speed -. 0.3
    | ',' -> turn := !turn +. 0.1; if !turn > 0.3 then turn := 0.3
    | '.' -> turn := !turn -. 0.1; if !turn < -0.3 then turn := -0.3
    | ' ' -> speed := 0.; turn := 0.
    | 'f' -> do_fast := not !do_fast
    | '+' -> World.set_auto_enable_depth_SF1 world
	(1 + (World.get_auto_enable_depth_SF1 world))
    | '-' -> World.set_auto_enable_depth_SF1 world
	((World.get_auto_enable_depth_SF1 world) - 1)
    | 'r' | 'R' -> reset_simulation ()
    | '[' -> cannon_angle := !cannon_angle +. 0.1
    | ']' -> cannon_angle := !cannon_angle -. 0.1
    | '1' -> cannon_elevation := !cannon_elevation +. 0.1
    | '2' -> cannon_elevation := !cannon_elevation -. 0.1
    | 'x' | 'X' -> (match !cannon_ball_body with
	  None -> ()
	| Some cb ->
	    let r2 = Math.r_from_axis_and_angle ~az:1.
	      ~angle:(!cannon_angle) () in
	    let r3 = Math.r_from_axis_and_angle ~ay:1.
	      ~angle:(!cannon_elevation) () in
	    let r4 = Math.multiply0 r2 r3 in
	    let x = vCANNON_X +. 3. *. r4.r13 in
	    let y = vCANNON_Y +. 3. *. r4.r23 in
	    let z = 1. +. 3. *. r4.r33 in
	    Body.set_position cb ~x ~y ~z;
	    let force = 10. in
	    Body.set_linear_vel cb ~x:(force *. r4.r13)
	      ~y:(force *. r4.r23) ~z:(force *. r4.r33);
	    Body.set_angular_vel cb ~x:0. ~y:0. ~z:0.)
    | _ -> ()

let sim_loop pause =
  Drawstuff.set_texture Drawstuff.Wood;
  if (* pause == 0 *) true then begin 			(* if not pause then *)
    if !vBOX then Body.add_force (List.hd !bodies) ~fx:lspeed
      ~fy:0. ~fz:0.;
    open Joint in
    List.iter
      (fun j ->
	let curturn = get_hinge2_angle1 j in
	set_hinge2_param j Vel (!turn -. curturn);
	set_hinge2_param j FMax (Ode.get_infinity ());
	set_hinge2_param j ~ax:Second_ax Vel !speed;
	set_hinge2_param j ~ax:Second_ax FMax vFMAX;
	List.iter (fun n -> match get_body j n with
	    Some b -> Body.enable b
	  | None -> ()) [First; Second]
      ) !joints;
    if !do_fast then begin
      Space.collide !space near_callback;
      if !vQUICKSTEP then
	World.quick_step world 0.05
      else (* if !vSTEPFAST then *)
	World.step_fast1 world 0.05 vITERS;
	  (* else raise "Undefined stepfast method"; *)
      JointGroup.empty contactgroup
    end else begin
      Space.collide !space near_callback;
      World.step world 0.05;
      JointGroup.empty contactgroup
    end;
    List.iter
      (fun stepsdis, box ->
	let (Some b) = Geom.get_body box in
	if Body.is_enabled b then begin
	  if
	    let lvel = Body.get_linear_vel b in
	    let lspeed = lvel.x*.lvel.x +. lvel.y*.lvel.y +.
	      lvel.z*.lvel.z in
	    if lspeed > vDISABLE_THRESHOLD then false
	    else
	      let avel = Body.get_angular_vel b in
	      let aspeed = avel.x*.avel.x +. avel.y*.avel.y +.
	      avel.z*.avel.z in
	      if aspeed > vDISABLE_THRESHOLD then false
	      else true
	  then incr stepsdis
	  else stepsdis := 0;
	  if !stepsdis > vDISABLE_STEPS then begin
	    Body.disable b;
	    Drawstuff.set_color ~r:0.5 ~g:0.5 ~b:1.
	  end else Drawstuff.set_color ~r:1. ~g:1. ~b:1.
	end else Drawstuff.set_color ~r:0.4 ~g:0.4 ~b:0.4;
	Drawstuff.draw_box
	  ~pos:(Geom.get_position box)
	  ~r:(Geom.get_rotation box)
	  ~sides:(Geom.box_get_lengths box)
      ) !wall_boxes
  end else
    List.iter
      (fun stepsdis, box ->
	let (Some b) = Geom.get_body box in
	if Body.is_enabled b then
	  Drawstuff.set_color ~r:1. ~g:1. ~b:1.
	else Drawstuff.set_color ~r:0.4 ~g:0.4 ~b:0.4;
	Drawstuff.draw_box
	  ~pos:(Geom.get_position box)
	  ~r:(Geom.get_rotation box)
	  ~sides:(Geom.box_get_lengths box)
      ) !wall_boxes;
  Drawstuff.set_color ~r:0. ~g:1. ~b:1.;
  let sides = {|vLENGTH; vWIDTH; vHEIGHT|} in
  List.iter
    (fun box ->
      Drawstuff.draw_box ~pos:(Geom.get_position box)
	~r:(Geom.get_rotation box) ~sides) !boxes;
  Drawstuff.set_color ~r:1. ~g:1. ~b:1.;
  List.iter
    (fun box ->
      Drawstuff.draw_sphere ~pos:(Geom.get_position box)
	~r:(Geom.get_rotation box) ~radius:vRADIUS) !spheres;
  (* draw the cannon *)
  Drawstuff.set_color ~r:1. ~g:1. ~b:0.;
  let r2 = Math.r_from_axis_and_angle ~az:1. ~angle:(!cannon_angle) () in
  let r3 = Math.r_from_axis_and_angle ~ay:1. ~angle:(!cannon_elevation) ()
  in
  let r4 = Math.multiply0 r2 r3 in
  Drawstuff.draw_box ~pos:{|vCANNON_X; vCANNON_Y; 1.|}
    ~r:r2 ~sides:{|2.; 2.; 2.|};
  Drawstuff.draw_cylinder
    ~pos:{|vCANNON_X+.1.5*.r4.r13; vCANNON_Y+.1.5*.r4.r23;
    1.+.1.5*.r4.r33|} ~r:r4 ~length:3. ~radius:0.5;
  (* draw the cannon ball *)
  match !cannon_ball_body with
      None -> ()
    | Some cb ->
	Drawstuff.draw_sphere ~pos:(Body.get_position cb)
    ~r:(Body.get_rotation cb) ~radius:(vCANNON_BALL_RADIUS)
    

let main () =
  print_endline "entering main()";
  do_fast := true;

  reset_simulation ();

  Drawstuff.simulation_loop ~width:352 ~height:288 ~start:(start)
    ~step:(sim_loop) ~command:(command)
    ~path:("../ode-0.5/drawstuff/textures") ();

  print_endline "leaving main ()"

let _ = main ()
