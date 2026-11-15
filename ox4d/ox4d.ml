(* Comment 2007: I've returned this old baby to life, but I don't
   remember how it works. ;-)
   To run in interpreter, uncomment the #load line below and do:

   ocaml -I +labltk ox4d.ml

   To compile for native code, remove the comment out the #load line below
   and try something like:

   ocamlopt -I +labltk labltk.cmxa ox4d.ml -o ox4d
*)

(* #load "labltk/labltk.cma";; *)

(*** Here the size of the matrix and the winning length is decided ***)
let (xlen, ylen, zlen, vlen, nlen, siz, mortal) =
begin
  let topw = Tk.openTk() in
  let minlen = ref 6 in
  let xlen = ref 8 in
  let ylen = ref 6 in
  let zlen = ref 6 in
  let vlen = ref 6 in
  let nlen = ref 4 in
  let siz = ref 40 in
  let mortal = ref false in
  let scaNlen = Textvariable.create () in
  let scaN = Scale.create ~label:"winning line" ~max:10.0 ~min:3.0 
      ~orient:`Horizontal ~variable:scaNlen topw in
  (* length of winning line must be no longer
     than that of the shortest dimension *)
  let check_len f =
    nlen := int_of_float f;
    if !nlen > !minlen then begin
      Scale.set scaN (float_of_int !minlen);
      nlen := !minlen
    end in
  Scale.configure ~command:check_len scaN;
  let set_maxlen f =
    if f < !nlen then Scale.set scaN (float_of_int f);
    if f < !minlen then minlen := f
    else while !xlen > !minlen && !ylen > !minlen && !zlen > !minlen
	&& !vlen > !minlen
    do incr minlen done
  in
  let setXlen f = let n = int_of_float f in xlen := n; set_maxlen n in
  let setYlen f = let n = int_of_float f in ylen := n; set_maxlen n in
  let setZlen f = let n = int_of_float f in zlen := n; set_maxlen n in
  let setVlen f = let n = int_of_float f in vlen := n; set_maxlen n in
  let scaXlen = Textvariable.create () in
  let scaX = Scale.create ~label:"X dimension" ~max:10.0 ~min:3.0 
      ~orient:`Horizontal ~variable:scaXlen ~command:setXlen topw in
  let scaYlen = Textvariable.create () in
  let scaY = Scale.create ~label:"Y dimension" ~max:10.0 ~min:3.0 
      ~orient:`Horizontal ~variable:scaYlen ~command:setYlen topw in
  let scaZlen = Textvariable.create () in
  let scaZ = Scale.create ~label:"Z dimension" ~max:10.0 ~min:3.0 
      ~orient:`Horizontal ~variable:scaZlen ~command:setZlen topw in
  let scaVlen = Textvariable.create () in
  let scaV = Scale.create ~label:"V dimension" ~max:10.0 ~min:3.0 
      ~orient:`Horizontal ~variable:scaVlen ~command:setVlen topw in
  let setSiz f = siz := (int_of_float f) in
  let scaSiz = Textvariable.create () in
  let scaS = Scale.create ~label:"wrapping size" ~max:120.0 ~min:10.0 
      ~orient:`Horizontal ~variable:scaSiz ~command:setSiz topw in
  let comment = Label.create ~text:"Press any key for UNDO" topw in
  Scale.set scaN 4.0;
  Scale.set scaX 8.0;
  Scale.set scaY 6.0;
  Scale.set scaZ 6.0;
  Scale.set scaV 6.0;
  Scale.set scaS 40.0;
  let fblood () =
    mortal := false;
    Tk.closeTk () in
  let mortalc () =
    mortal := true;
    Tk.closeTk () in
  let but1 = Button.create ~command:fblood ~text:"First Blood" topw in
  let but2 = Button.create ~command:mortalc ~text:"Mortal Combat" topw in
  Tk.pack [scaX; scaY; scaZ; scaV; scaN; scaS];
  Tk.pack [but1; but2]; Tk.pack [comment];
  Tk.appname_set "set properties and close window";
  Tk.mainLoop();
  !xlen, !ylen, !zlen, !vlen, !nlen, !siz, !mortal
end;;

(**** matrices definition ****)

let make_4D fu xlen ylen zlen vlen =
  let p0000 = fu 0 0 0 0 in
  let mat = Array.make_matrix xlen ylen (Array.make_matrix 0 0 p0000) in
  for x = 0 to (xlen - 1) do
    for y = 0 to (ylen - 1) do
      mat.(x).(y) <- Array.make_matrix zlen vlen p0000;
      for z = 0 to (zlen - 1) do
	for v = 0 to (vlen - 1) do
	  if x <> 0 || y <> 0 || z <> 0 || v <> 0 then
	    mat.(x).(y).(z).(v) <- fu x y z v
	done
      done
    done
  done;
  mat;;

(**** Game algorithm ****)


type cellt = O | X | E;;
let board = make_4D (fun x y z v -> E) xlen ylen zlen vlen;;
(* How many possibilities at given point *)
let gain = make_4D (fun x y z v -> 0) xlen ylen zlen vlen;;
let lines = make_4D (fun x y z v -> 0) xlen ylen zlen vlen;;

(* FIXME: I forgot what value this should be *)
let candlen = 2*nlen + 6;;
(* Free cells that appear in lines of given filling *)
(* Categories: good, open, blocked x mine (cpu), enemy's (man) *)
let cand = Array.make candlen [];;


(** auxiliary tools **)

let proj n (x, y, z, v) =
  match n with
  | 0 -> x
  | 1 -> y
  | 2 -> z
  | 3 -> v
  | _ -> failwith "Dimension out of our universe";;
(* translation vector: i, j, k, l = -1 or 0 or 1 *)
let transl n (x, y, z, v) (i, j, k, l) =
  x + i*n, y + j*n, z + k*n, v + l*n;;
exception OutOfBoard of int*int*int*int;;
let get ar (x, y, z, v) =
  try ar.(x).(y).(z).(v)
  with Invalid_argument _ -> raise (OutOfBoard (x, y, z, v));;
let set ar (x, y, z, v) e =
  try ar.(x).(y).(z).(v) <- e
  with Invalid_argument _ -> raise (OutOfBoard (x, y, z, v));;
exception CandFail of int*(int*int*int*int);;
(* With binary trees here I could save (lots of) place *)
let appcand p c =
  try cand.(p) <- c::(cand.(p))
  with Invalid_argument _ -> raise (CandFail (p,c));;


(** Looking through all possible lines on the board **)

let yourpts = ref 0;;
let mypts = ref 0;;

exception Youwon;;

let fold ((x, y, z, v) as p) ((i, j, k, l) as dp) =
  let kind = ref E in
  let layer = ref 0 in
  let filled = ref 0 in
  let n = ref 0 in
(* good means that a line needs two moves to become broken *)
(* blocked means that a line cannot be turned good *)
(* oneopen means that a line has space to at least one side *)
  let good = ref false and closed = ref false and blocked = ref false
  and oneopen = ref false in
  while !n < (nlen-1) && (get board (transl !n p dp)) = E do incr n done;
  kind := get board (transl !n p dp);
  begin
    let px = x - i and py = y - j and pz = z - k and pv = v - l in
    if px >= 0 && py >= 0 && pz >= 0 && pv >= 0
	&& px < xlen && py < ylen && pz < zlen && pv < vlen
    then begin
      let left = (get board (px, py, pz, pv)) in
      if left = E || left = !kind then oneopen := !n > 0
      else blocked := true
    end
  end;
  if (get board p) = E then good := true;
  if !kind = X  then layer := !layer + 1;
  if !kind <> E then
    begin
      while !n < nlen && ((get board (transl !n p dp)) = !kind
			|| (get board (transl !n p dp)) = E) do
	if (get board (transl !n p dp)) = !kind then begin
	  layer := !layer + 2; if !closed then good := false;
	  incr filled
	end else closed := true;
	incr n
      done;
      begin
	let nx = x + nlen*i and ny = y + nlen*j and nz = z + nlen*k
	and nv = v + nlen*l in
	if nx >= 0 && ny >= 0 && nz >= 0 && nv >= 0
	    && nx < xlen && ny < ylen && nz < zlen && nv < vlen
	then begin
	  let right = (get board (nx, ny, nz, nv)) in
	  if right = E || right = !kind
	  then oneopen := (get board (transl (nlen-1) p dp)) = E
	  else blocked := true
	end
      end;
      if !good && !closed && !oneopen then layer := !layer + 2;
      if !n < nlen then layer := ~-1
      else if !filled = nlen - 2 && not !blocked then
	layer := 2*nlen + (if !kind = X then 1 else 0)
      else if !filled = nlen - 1 then
	layer := 2*nlen + (if !kind = X then 3 else 2)
      else if (not mortal) && !filled = nlen && !kind = O then raise Youwon
      else if !filled = nlen then
	if !kind = O then incr yourpts
	else incr mypts
    end;
   !layer, !filled, !kind;;

exception Iwon of (int*int*int*int);;

(* Game heuristic function *)
let heurist layer filled who = (* 1;; *)
  layer + nlen*6;;

let collect () =
  yourpts := 0; mypts := 0;
  Array.fill cand 0 candlen [];
  let mywin = ref false and mywinpos = ref (-1, -1, -1, -1) in
  for x = 0 to xlen - 1 do
    for y = 0 to ylen - 1 do
      for z = 0 to zlen - 1 do
	for v = 0 to vlen - 1 do
	  let p = x, y, z, v in
	  set gain p 0;
	  set lines p 0
	done
      done
    done
  done;
  for x = 0 to xlen - 1 do
    for y = 0 to ylen - 1 do
      for z = 0 to zlen - 1 do
	for v = 0 to vlen - 1 do
	  let p = x, y, z, v in
	  for i = -1 to 1 do
	    for j = -1 to 1 do
	      for k = -1 to 1 do
		for l = -1 to 1 do
		  if (i <> 0 || j <> 0 || k <> 0 || l <> 0) &&
		    (i < 1 || x <= xlen - nlen) &&
		    (j < 1 || y <= ylen - nlen) &&
		    (k < 1 || z <= zlen - nlen) &&
		    (l < 1 || v <= vlen - nlen) &&
		    (i >= 0 || x >= nlen-1) &&
		    (j >= 0 || y >= nlen-1) &&
		    (k >= 0 || z >= nlen-1) &&
		    (l >= 0 || v >= nlen-1)
(* I allow all lines to be counted twice - in opposite directions *)
		  then
		    let lay, fil, who = fold p (i,j,k,l) in
		    if fil < nlen then
		      for n = 0 to nlen - 1 do
			let p1 = (transl n p (i, j, k, l)) in
			if (get board p1) = E && lay >= 0 then begin
			  if (not mortal) && fil = nlen - 1
			      && who = X
			  then begin
			    mywin := true; mywinpos := p1
			  end;
			  set gain p1 ((get gain p1)+(heurist lay fil who));
			  set lines p1 ((get lines p1)+1);
			  appcand lay p1
			end
		      done
		done
	      done
	    done
	  done
	done
      done
    done
  done;
  if !mywin then raise (Iwon !mywinpos)
;;

(* select seems useful but isn't used *)
let select () =
  let sel = ref [] in
  let lns = ref 0 in
  for x = 0 to xlen - 1 do
    for y = 0 to ylen - 1 do
      for z = 0 to zlen - 1 do
	for v = 0 to vlen - 1 do
	  let p = x, y, z, v in
	  if get lines p > !lns then begin
	    lns := get lines p; sel := [p]
	  end else if get lines p = !lns then
	    sel := p:: !sel
	done
      done
    done
  done; !sel;;

exception Mymove of (int*int*int*int);;
exception Gameover;;
let my_turn () =
  collect ();
(* special tactic - you may turn it on here *)
(*
  if mortal then
    let cnd = select () in
    if cnd = [] then raise Gameover else raise
      (Mymove (List.hd (List.sort (fun a b -> ~- (compare (get gain a)
				       (get gain b))) cnd)))
  else
*)
    let nl = ref (candlen-1) in
    while !nl >= 0 && (cand.(!nl)) = [] do decr nl done;
    if !nl < 0 then
      if mortal then raise Gameover
      else failwith "collect () didn't collect anything";
(* \/ depends on strategy *)
    if !nl = 2*nlen + 3 then mypts := !mypts+2;
    raise (Mymove (List.hd (List.sort (fun a b -> ~- (compare (get gain a)
				       (get gain b))) cand.(!nl))));;
(*return the biggest-gain element *)
  


(**** MAIN ****)

let topw = Tk.openTk ();;
let canv = Canvas.create ~width:1024 ~height:768 topw;;
let xboard =
  make_4D 
    (fun x y z v ->
      let xp = (x*siz)*2+(z*siz) in
      let yp = (y*zlen*siz)/2 + (z*siz)/2 in
      Canvas.create_arc
	~x1:xp ~y1:yp
	~x2:(xp + siz - (z*siz)/(2*zlen))
	~y2:(yp + siz - (z*siz)/(2*zlen))
	~start:((float_of_int v)*.(360.0 /. (float_of_int (vlen+1))))
	~extent:(360.0 /. (float_of_int (vlen+1))) canv
    ) xlen ylen zlen vlen;;

let activ p cell _ =
  if (get board p) = E then
    Canvas.configure_arc ~fill:`Blue canv cell;;
let deactiv p cell _ =
  if (get board p) = E then
    Canvas.configure_arc ~fill:(`Color "Gray") canv cell;;

let undobuf = ref [];;

Tk.bind ~events:[`KeyPress]
  ~action:
  (fun _ -> match !undobuf with [] -> () | (man,cpu)::tl ->
    Bell.ring ();
    undobuf := tl;
    Canvas.configure_arc ~fill:(`Color "Gray") canv (get xboard man);
    Canvas.configure_arc ~fill:(`Color "Gray") canv (get xboard cpu);
    collect ()
  ) ~extend:true canv;;
Tk.bind ~events:[`KeyPress]
  ~action:
  (fun _ -> match !undobuf with [] -> () | (man,cpu)::tl ->
    Bell.ring ();
    undobuf := tl;
    set board man E;
    set board cpu E;
    Canvas.configure_arc ~fill:(`Color "Gray") canv (get xboard man);
    Canvas.configure_arc ~fill:(`Color "Gray") canv (get xboard cpu);
    collect ()
  ) ~extend:true topw;;

let reset () =
  undobuf := [];
  mypts := 0; yourpts := 0;
  for x = 0 to xlen - 1 do
    for y = 0 to ylen - 1 do
      for z = 0 to zlen - 1 do
	for v = 0 to vlen - 1 do
	  let p = x, y, z, v in
	  set board p E;
	  Canvas.configure_arc ~fill:(`Color "Gray") canv (get xboard p)
	done
      done
    done
  done;
;;
let youwon () =
  Bell.ring ();
  let ans = Dialog.create ~parent:topw ~title:"You won!"
    ~message:"Congratulations. How was it possible?"
    ~buttons:["Play again"; "Leave"] () in
  reset (); ans;;
let iwon () =
  Bell.ring ();
  let ans = Dialog.create ~parent:topw ~title:"I won!"
    ~message:"Don't worry, it is because I count all those lines."
    ~buttons:["Play again"; "Leave"] () in
  reset (); ans;;

let labpts = Label.create  ~text:"Points:" topw;;
let labmypts = Label.create ~anchor:`S ~foreground:`Red ~text:"0" topw;;
let labyourpts = Label.create ~anchor:`S ~foreground:`Green ~text:"0" topw;;
(* for debugging next_turn_deb returns info *)
let next_turn_deb p cell =
  if (get board p) = E then
    begin
      set board p O;
      Canvas.configure_arc ~fill:`Green canv cell;
      try my_turn (); ("Hey!", None) with
      | Gameover ->
	  if (if !mypts > !yourpts then iwon () else youwon ()) = 1
	  then Tk.closeTk (); ("Gameover", None)
      | Youwon -> if (youwon ()) = 1 then Tk.closeTk (); ("Youwon", None)
      | Iwon pos ->
	  Canvas.configure_arc ~fill:`Red canv (get xboard pos);
	  if (iwon ()) = 1 then Tk.closeTk (); ("Iwon", Some pos)
      | Mymove pos ->
	  set board pos X;
	  undobuf := (p, pos):: !undobuf;
	  Canvas.configure_arc ~fill:`Red canv (get xboard pos);
	  Label.configure ~text:(string_of_int !mypts) labmypts;
	  Label.configure ~text:(string_of_int !yourpts) labyourpts;
	  ("Mymove", Some pos)
    end else ("Not on empty place", Some p);;
let next_turn p cell _ = ignore (next_turn_deb p cell);;
for x = 0 to xlen-1 do
  for y = 0 to ylen-1 do
    for z = 0 to zlen-1 do
      for v = 0 to vlen-1 do
	let cell =xboard.(x).(y).(z).(v) in
	Canvas.bind ~events:[`ButtonPress] ~action:(next_turn (x,y,z,v)
						      cell) canv cell;
	Canvas.bind ~events:[`Enter]
	  ~action:(activ(x,y,z,v) cell) canv cell;
	Canvas.bind ~events:[`Leave]
	  ~action:(deactiv(x,y,z,v) cell) canv cell
      done
    done
  done
done;;
Tk.appname_set "ox4D by Luk";;
Tk.pack ~side:`Right [canv];;
if mortal then Tk.pack ~fill:`X [labpts; labyourpts; labmypts];;
Tk.mainLoop();;
