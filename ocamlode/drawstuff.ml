(** Ocaml bindings for the Drawstuff library of Open Dynamics Engine (ODE).
    Documentation exerpts from <drawstuff.h>
    @author Lukasz Stafiniak <lukstafi@gmail.com>
    @since August 2005
    @version 0.1

This is a library for rendering simple 3D objects in a virtual environment.

NOTES
-----

in the virtual world, the z axis is "up" and z=0 is the floor.

the user is able to click+drag in the main window to move the camera:
  * left button - pan and tilt.
  * right button - forward and sideways.
  * left + right button (or middle button) - sideways and up.
*)

open Ode;;

external init : unit -> unit
  = "ml_InitDrawstuff"

external simulation_loop :
  width:int ->
  height:int ->
  ?start:(unit->unit) -> (** called before sim loop starts *)
  ?step:(int->unit) -> (** called before every frame *)
  ?command:(char->unit) -> (** called if a command key is pressed *)
  ?stop:(unit->unit) -> (** called after sim loop exits *)
  ?path:string -> unit -> unit
  = "ml_dsSimulationLoop_bc" "ml_dsSimulationLoop"

(** these functions display an error message then exit. You do not
    have to add a terminating '\n'. {!debug} tries to dump core or
    start the debugger. *)
external error : string -> unit
  = "ml_dsError"
external debug : string -> unit
  = "ml_dsDebug"

(** {!print} prints out a message. You must add a '\n' at the end of
    every line. *)
external print : string -> unit
  = "ml_dsPrint"

(** Set and get the camera position. xyz is the cameria position
    (x,y,z).  hpr contains heading, pitch and roll numbers in
    degrees. heading=0 points along the x axis, pitch=0 is looking
    towards the horizon, and roll 0 is "unrotated". {!get_viewpoint}
    returns [(xyz, hpr)]. *)
external set_viewpoint : xyz:vector3 -> hpr:vector3 -> unit
  = "ml_dsSetViewpoint"
external get_viewpoint : unit -> vector3 * vector3
  = "ml_dsGetViewpoint"

(** Stop the simulation loop. calling this from within
    {!simulation_loop} will cause it to exit and return to the
    caller. It is the same as if the user used the exit command. Using
    this outside the loop will have no effect. *)
external stop : unit -> unit
  = "ml_dsStop"

type texture = None | Wood

(** Change the way objects are drawn. These changes will apply to all
    further [drawXXX] functions. The red, green, and blue number are
    between 0 and 1.  alpha is between 0 and 1 - if alpha is not
    specified it's assubed to be 1.  The current texture is colored
    according to the current color.  At the start of each frame, the
    texture is reset to none and the color is reset to white. *)
external set_texture : texture -> unit
  = "ml_dsSetTexture"
external set_color : r:float -> g:float -> b:float -> unit
  = "ml_dsSetColor"
external set_color_alpha : r:float -> g:float -> b:float
  -> alpha:float -> unit
  = "ml_dsSetColorAlpha"

(** Draw objects.
- [pos] is the x,y,z of the center of the object.
- [r] is a 3x3 rotation matrix for the object, stored by row like this:
        [ R11 R12 R13 0 ]
        [ R21 R22 R23 0 ]
        [ R31 R32 R33 0 ]
- [sides] is a vector of x,y,z side lengths.
- all cylinders are aligned along the z axis.

*)
external draw_box : pos:vector3 -> r:matrix3 -> sides:vector3 ->
  unit
  = "ml_dsDrawBoxD"
external draw_sphere : pos:vector3 -> r:matrix3 -> radius:float ->
  unit
  = "ml_dsDrawSphereD"
external draw_cylinder : pos:vector3 -> r:matrix3 -> length:float
  -> radius:float -> unit
  = "ml_dsDrawCylinderD"
external draw_ccylinder : pos:vector3 -> r:matrix3 -> length:float
  -> radius:float -> unit
  = "ml_dsDrawCappedCylinderD"
external draw_line : vector3 -> vector3 -> unit
  = "ml_dsDrawLineD"

(** Set the drawn quality of the objects. Higher numbers are higher
    quality, but slower to draw. This must be set before the first
    objects are drawn to be effective. *)
external set_sphere_quality : int -> unit
  = "ml_dsSetSphereQuality"
external set_ccylinder_quality : int -> unit
  = "ml_dsSetCappedCylinderQuality"
