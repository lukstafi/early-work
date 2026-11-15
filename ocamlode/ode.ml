(** Ocaml bindings for the Open Dynamics Engine (ODE).
    Based on low-level bindings by Richard W. M. Jones <rich@annexia.org>
    and on ODE v0.5 User Guide Copyright 2001-2004 Russell Smith
    with lessons learned from lablGL by Jacques Garrigue
    @author Lukasz Stafiniak <lukstafi@gmail.com>
    @since August 2005
    @version 0.1
*)

(* OCaml bindings for the Open Dynamics Engine (ODE).
 * By Richard W.M. Jones <rich@annexia.org>
 * $Id: ode.ml,v 1.1 2005/06/24 18:15:29 rich Exp $
 *)

open StdLabels;;

(** Basic definitions *)
  (** Data represented in form binary-compatible with ODE *)
  type vector4 = { x : float; y : float; z : float; w : float }
  type vector3 = vector4
  type aabb =
      {minx : float; maxx : float; miny : float; maxy : float;
      minz : float; maxz : float}
  type matrix3 = { r11 : float; r12 : float; r13 : float; r14 : float;
		    r21 : float; r22 : float; r23 : float; r24 : float;
		    r31 : float; r32 : float; r33 : float; r34 : float }
  type matrix4 = { s11 : float; s12 : float; s13 : float; s14 : float;
		    s21 : float; s22 : float; s23 : float; s24 : float;
		    s31 : float; s32 : float; s33 : float; s34 : float;
		    s41 : float; s42 : float; s43 : float; s44 : float }
  type matrix6 = {
    t11 : float; t12 : float; t13 : float; t14 : float;
    t15 : float; t16 : float; t17 : float; t18 : float;
    t21 : float; t22 : float; t23 : float; t24 : float;
    t25 : float; t26 : float; t27 : float; t28 : float;
    t31 : float; t32 : float; t33 : float; t34 : float;
    t35 : float; t36 : float; t37 : float; t38 : float;
    t41 : float; t42 : float; t43 : float; t44 : float;
    t45 : float; t46 : float; t47 : float; t48 : float;
    t51 : float; t52 : float; t53 : float; t54 : float;
    t55 : float; t56 : float; t57 : float; t58 : float;
    t61 : float; t62 : float; t63 : float; t64 : float;
    t65 : float; t66 : float; t67 : float; t68 : float
  }
  type quaternion = { qs : float; qx : float; qy : float; qz : float }

  (** This deallocates some extra memory used by ODE that can not be
      deallocated using the normal destroy functions, (e.g. dWorldDestroy
      called at World.t finalization). You can use this function at the
      end of your application to prevent memory leak checkers from
      complaining about ODE. *)
  external close : unit -> unit
    = "ml_dCloseODE"

  (** Initialize before creating any object. *)
  external init : unit -> unit
    = "ml_dInitOCamlODE"

  (** Get the biggest value of ODE numbers *)
  external get_infinity : unit -> float
    = "ml_dInfinity"

  (** Given two line segments A and B with endpoints a1-a2 and b1-b2,
      return the points on A and B that are closest to each other (in
      cp1, cp2). In the case of parallel lines where there are
      multiple solutions, a solution involving the endpoint of at least
      one line will be returned. This will work correctly for zero
      length lines, e.g. if a1==a2 and/or b1==b2. *)
  external closest_line_segment_points : a1:vector3 -> a2:vector3 ->
    b1:vector3 -> b2:vector3 -> vector3 * vector3
    = "ml_dClosestLineSegmentPoints"

(** Given boxes (p1,R1,side1) and (p2,R2,side2), return 1 if they
    intersect or 0 if not. p is the center of the box, R is the
    rotation matrix for the box, and side is a vector of x/y/z side
    lengths. *)
  external box_touches_box : p1:vector3 -> r1:matrix3 ->
    side1:vector3 -> p2:vector3 -> r2:matrix3 -> side2:vector3 ->
    bool = "ml_dBoxTouchesBox_bc" "ml_dBoxTouchesBox"
