(**
  This code is in public domain.
  <Open ... in ...> written by Alain Frisch.  2002-02-05.
  and extended by Lukasz Stafiniak Aug 2005.
  ODE type bindings written by Lukasz Stafiniak Aug/Sep 2005.
  Example:
  {|a; b; c|} ==> ({x=a; y=b; z=c; w=0.} : vector3)
  written by Lukasz Stafiniak Aug 2005.
*)

let no = ref 0

let local_struct loc st e = 
  incr no;
  let x = "OPENIN_" ^ (string_of_int !no) in
  let st = st @ [<:str_item< value res = $e$ >>] in
  <:expr<  let module $x$ = struct $list: st$ end in ($uid:x$.res) >>

EXTEND
 GLOBAL: Pcaml.expr;

 Pcaml.expr: LEVEL "expr1" [
   [ "open"; ils = LIST1 (LIST1 UIDENT SEP ".") SEP "and"; "in";
        e = Pcaml.expr LEVEL "top" -> 
	  local_struct loc
            (List.map (fun i -> <:str_item< open $i$ >>) ils) e
   | "struct"; st = LIST0 [ s = Pcaml.str_item; OPT ";;" -> s ]; "end"; "in";
	  e = Pcaml.expr LEVEL "top" -> 
	    local_struct loc st e
   ]
 ];
 Pcaml.expr: LEVEL "simple" [
   [ "{|"; e1 = Pcaml.expr LEVEL "expr1"; ";";
   e2 = Pcaml.expr LEVEL "expr1"; ";";
   e3 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|}" ->
     <:expr< ({ x = $e1$; y = $e2$; z = $e3$; w = 0.} : vector3) >>
   | "{|"; e1 = Pcaml.expr LEVEL "expr1"; ";";
   e2 = Pcaml.expr LEVEL "expr1"; ";";
   e3 = Pcaml.expr LEVEL "expr1"; ";";
   e4 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|}" ->
     <:expr< { x = $e1$; y = $e2$; z = $e3$; w = $e4$} >> 

 |  "{|"; e11 = Pcaml.expr LEVEL "expr1"; ";";
   e12 = Pcaml.expr LEVEL "expr1"; ";";
   e13 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|"; OPT "|";
   e21 = Pcaml.expr LEVEL "expr1"; ";";
   e22 = Pcaml.expr LEVEL "expr1"; ";";
   e23 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|"; OPT "|";
   e31 = Pcaml.expr LEVEL "expr1"; ";";
   e32 = Pcaml.expr LEVEL "expr1"; ";";
   e33 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|}" ->
     <:expr< { r11 = $e11$ ; r12 = $e12$ ; r13 = $e13$ ; r14 = 0. ;
     r21 = $e21$ ; r22 = $e22$ ; r23 = $e23$ ;  r24=0. ;
     r31 = $e31$ ; r32 = $e32$ ; r33 = $e33$ ; r34=0. } >> 

 | "{|"; e11 = Pcaml.expr LEVEL "expr1"; ";";
   e12 = Pcaml.expr LEVEL "expr1"; ";";
   e13 = Pcaml.expr LEVEL "expr1"; ";";
   e14 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|"; OPT "|";
   e21 = Pcaml.expr LEVEL "expr1"; ";";
   e22 = Pcaml.expr LEVEL "expr1"; ";";
   e23 = Pcaml.expr LEVEL "expr1"; ";";
   e24 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|"; OPT "|";
   e31 = Pcaml.expr LEVEL "expr1"; ";";
   e32 = Pcaml.expr LEVEL "expr1"; ";";
   e33 = Pcaml.expr LEVEL "expr1"; ";";
   e34 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|}" ->
     <:expr< { r11 = $e11$ ; r12 = $e12$ ; r13 = $e13$ ; r14 = $e14$ ;
     r21 = $e21$ ; r22 = $e22$ ; r23 = $e23$ ;  r24 = $e24$ ;
     r31 = $e31$ ; r32 = $e32$ ; r33 = $e33$ ; r34 = $e34$ } >> 
 | "{|"; e11 = Pcaml.expr LEVEL "expr1"; ";";
   e12 = Pcaml.expr LEVEL "expr1"; ";";
   e13 = Pcaml.expr LEVEL "expr1"; ";";
   e14 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|"; OPT "|";
   e21 = Pcaml.expr LEVEL "expr1"; ";";
   e22 = Pcaml.expr LEVEL "expr1"; ";";
   e23 = Pcaml.expr LEVEL "expr1"; ";";
   e24 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|"; OPT "|";
   e31 = Pcaml.expr LEVEL "expr1"; ";";
   e32 = Pcaml.expr LEVEL "expr1"; ";";
   e33 = Pcaml.expr LEVEL "expr1"; ";";
   e34 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|"; OPT "|";
   e41 = Pcaml.expr LEVEL "expr1"; ";";
   e42 = Pcaml.expr LEVEL "expr1"; ";";
   e43 = Pcaml.expr LEVEL "expr1"; ";";
   e44 = Pcaml.expr LEVEL "expr1"; OPT ";"; "|}" ->
     <:expr< { s11 = $e11$ ; s12 = $e12$ ; s13 = $e13$ ; s14 = $e14$ ;
     s21 = $e21$ ; s22 = $e22$ ; s23 = $e23$ ;  s24 = $e24$ ;
     s31 = $e31$ ; s32 = $e32$ ; s33 = $e33$ ;  s34 = $e34$ ;
     s41 = $e41$ ; s42 = $e42$ ; s43 = $e43$ ; s44 = $e44$ } >>      
   ]
 ];

 Pcaml.patt: LEVEL "simple" [
   [ "{|"; e1 = Pcaml.patt; ";";
   e2 = Pcaml.patt; ";";
   e3 = Pcaml.patt; OPT ";"; "|}" ->
     <:patt< ({ x = $e1$ ; y = $e2$ ; z = $e3$ } : vector3) >>
   | "{|"; e1 = Pcaml.patt; ";";
   e2 = Pcaml.patt; ";";
   e3 = Pcaml.patt; ";";
   e4 = Pcaml.patt; OPT ";"; "|}" ->
     <:patt< { x = $e1$ ; y = $e2$ ; z = $e3$ ; w = $e4$} >> 
  | "{|"; e11 = Pcaml.patt; ";";
   e12 = Pcaml.patt; ";";
   e13 = Pcaml.patt; OPT ";"; "|"; OPT "|";
   e21 = Pcaml.patt; ";";
   e22 = Pcaml.patt; ";";
   e23 = Pcaml.patt; OPT ";"; "|"; OPT "|";
   e31 = Pcaml.patt; ";";
   e32 = Pcaml.patt; ";";
   e33 = Pcaml.patt; OPT ";"; "|}" ->
     <:patt< { r11 = $e11$ ; r12 = $e12$ ; r13 = $e13$ ;
     r21 = $e21$ ; r22 = $e22$ ; r23 = $e23$ ;
     r31 = $e31$ ; r32 = $e32$ ; r33 = $e33$ } >>
   | "{|"; e11 = Pcaml.patt; ";";
   e12 = Pcaml.patt; ";";
   e13 = Pcaml.patt; ";";
   e14 = Pcaml.patt; OPT ";"; "|"; OPT "|";
   e21 = Pcaml.patt; ";";
   e22 = Pcaml.patt; ";";
   e23 = Pcaml.patt; ";";
   e24 = Pcaml.patt; OPT ";"; "|"; OPT "|";
   e31 = Pcaml.patt; ";";
   e32 = Pcaml.patt; ";";
   e33 = Pcaml.patt; ";";
   e34 = Pcaml.patt; OPT ";"; "|}" ->
     <:patt< { r11 = $e11$ ; r12 = $e12$ ; r13 = $e13$ ; r14 = $e14$ ;
     r21 = $e21$ ; r22 = $e22$ ; r23 = $e23$ ;  r24 = $e24$ ;
     r31 = $e31$ ; r32 = $e32$ ; r33 = $e33$ ; r34 = $e34$ } >>
   | "{|"; e11 = Pcaml.patt; ";";
   e12 = Pcaml.patt; ";";
   e13 = Pcaml.patt; ";";
   e14 = Pcaml.patt; OPT ";"; "|"; OPT "|";
   e21 = Pcaml.patt; ";";
   e22 = Pcaml.patt; ";";
   e23 = Pcaml.patt; ";";
   e24 = Pcaml.patt; OPT ";"; "|"; OPT "|";
   e31 = Pcaml.patt; ";";
   e32 = Pcaml.patt; ";";
   e33 = Pcaml.patt; ";";
   e34 = Pcaml.patt; OPT ";"; "|"; OPT "|";
   e41 = Pcaml.patt; ";";
   e42 = Pcaml.patt; ";";
   e43 = Pcaml.patt; ";";
   e44 = Pcaml.patt; OPT ";"; "|}" ->
     <:patt< { s11 = $e11$ ; s12 = $e12$ ; s13 = $e13$ ; s14 = $e14$ ;
     s21 = $e21$ ; s22 = $e22$ ; s23 = $e23$ ;  s24 = $e24$ ;
     s31 = $e31$ ; s32 = $e32$ ; s33 = $e33$ ;  s34 = $e34$ ;
     s41 = $e41$ ; s42 = $e42$ ; s43 = $e43$ ; s44 = $e44$ } >>      
   ]

 ];

END



(* examples:
let r =
  {|3.; 4.; 5.
  | 4.; 5.; 6.
  | 5.; 6.; 7.|}
;;

let add {|x; y; z|} {|x'; y'; z'|} = {|x+x'; y+y'; z+z'|}
;;
*)
