open Ode

    open StdLabels

  type t

  external create : mu:float -> t
    = "ml_dContactCreate"

  type array

  external array_size : array -> int
    = "ml_dContactGeomArray_size"
      
  (** Currently it is not possible to have an empty array... *)
  external array_is_empty : array -> bool
    = "ml_dContactGeomArray_is_empty"
  external append : array -> array -> array
    = "ml_dContactArrayAppend"
  external set_from_array : t -> array -> int -> unit
    = "ml_dSetContactGeomFromArray"

  let iter array ~contact ~f =
    let size = (array_size array) - 1 in
    for i = 0 to size do
      set_from_array contact array i; f contact
    done

  external create_joint : World.t -> ?dst:JointGroup.t -> t ->
    Joint.contact = "ml_dJointCreateContact"

  type surface_params =
      Mu2 of float (** If not set, use mu for both friction
		       directions. If set, use mu for friction
		       direction 1, use mu2 for friction direction
		       2. *)
    | FDir1 of vector3 (** If set, take fdir1 as friction direction 1,
			   otherwise automatically compute friction
			   direction 1 to be perpendicular to the
			   contact normal (in which case its resulting
			   orientation is unpredictable). *)
    | Bounce of float * float (** If set, the contact surface is
				  bouncy, in other words the bodies
				  will bounce off each other. The
				  exact amount of bouncyness is
				  controlled by the first
				  parameter. *)
    | SoftERP of float (** If set, the error reduction parameter of
			    the contact normal can be set with the
			    soft_erp parameter. This is useful to make
			    surfaces soft. *)
    | SoftCFM of float (** If set, the constraint force mixing
			    parameter of the contact normal can be set
			    with the soft_cfm parameter. This is
			    useful to make surfaces soft. *)
    | Motion1 of float (** If set, the contact surface is assumed to
			   be moving independently of the motion of
			   the bodies. This is kind of like a conveyor
			   belt running over the surface. When this
			   flag is set, motion1 defines the surface
			   velocity in friction direction 1. *)
    | Motion2 of float (** The same thing as above, but for friction
			   direction 2. *)
    | Slip1 of float (** Force-dependent-slip (FDS) in friction
			 direction 1. *)
    | Slip2 of float (** Force-dependent-slip (FDS) in friction
			 direction 2. *)
    | Approx1_1 (** Use the friction pyramid approximation for
		    friction direction 1. If this is not specified
		    then the constant-force-limit approximation is
		    used (and mu is a force limit). *)
    | Approx1_2 (** Use the friction pyramid approximation for
		    friction direction 2. If this is not specified
		    then the constant-force-limit approximation is
		    used (and mu is a force limit). *)
    | Approx1 (** Equivalent to both Approx1 and Approx2. *)
	

  external set_surface_fdir1 : t -> vector3 -> unit
    = "ml_dSetSurfaceParameter_fdir1"
  external set_surface_mu : t -> float -> unit
    = "ml_dSetSurfaceParameter_mu"
  external set_surface_mu2 : t -> float -> unit
    = "ml_dSetSurfaceParameter_mu2"
  external set_surface_bounce : t -> float -> unit
    = "ml_dSetSurfaceParameter_bounce"
  external set_surface_bounce_vel : t -> float -> unit
    = "ml_dSetSurfaceParameter_bounce_vel"
  external set_surface_soft_erp : t -> float -> unit
    = "ml_dSetSurfaceParameter_soft_erp"
  external set_surface_soft_cfm : t -> float -> unit
    = "ml_dSetSurfaceParameter_soft_cfm"
  external set_surface_motion1 : t -> float -> unit
    = "ml_dSetSurfaceParameter_motion1"
  external set_surface_motion2 : t -> float -> unit
    = "ml_dSetSurfaceParameter_motion2"
  external set_surface_slip1 : t -> float -> unit
    = "ml_dSetSurfaceParameter_slip1"
  external set_surface_slip2 : t -> float -> unit
    = "ml_dSetSurfaceParameter_slip2"
  external set_surface_approx1_1 : t -> unit
    = "ml_dSetSurfaceModeParam_Approx1_1"
  external set_surface_approx1_2 : t -> unit
    = "ml_dSetSurfaceModeParam_Approx1_2"
  external set_surface_approx1 : t -> unit
    = "ml_dSetSurfaceModeParam_Approx1"
  external reset_surface_mode : t -> unit
    = "ml_dResetSurfaceMode"

  let set_surface_params c ~mu params =
    reset_surface_mode c;
    set_surface_mu c mu;
    List.iter ~f:(function
	Mu2 mu2 -> set_surface_mu2 c mu2
      | FDir1 v -> set_surface_fdir1 c v
      | Bounce (b, vel) -> set_surface_bounce c b;
	  set_surface_bounce_vel c vel
      | SoftERP erp -> set_surface_soft_erp c erp
      | SoftCFM cfm -> set_surface_soft_cfm c cfm
      | Motion1 mot1 -> set_surface_motion1 c mot1
      | Motion2 mot2 -> set_surface_motion2 c mot2
      | Slip1 sl1 -> set_surface_slip1 c sl1
      | Slip2 sl2 -> set_surface_slip2 c sl2
      | Approx1_1 -> set_surface_approx1_1 c
      | Approx1_2 -> set_surface_approx1_2 c
      | Approx1 -> set_surface_approx1 c) params

  let modify_surface_params c params =
    List.iter ~f:(function
	Mu2 mu2 -> set_surface_mu2 c mu2
      | FDir1 v -> set_surface_fdir1 c v
      | Bounce (b, vel) -> set_surface_bounce c b;
	  set_surface_bounce_vel c vel
      | SoftERP erp -> set_surface_soft_erp c erp
      | SoftCFM cfm -> set_surface_soft_cfm c cfm
      | Motion1 mot1 -> set_surface_motion1 c mot1
      | Motion2 mot2 -> set_surface_motion2 c mot2
      | Slip1 sl1 -> set_surface_slip1 c sl1
      | Slip2 sl2 -> set_surface_slip2 c sl2
      | Approx1_1 -> set_surface_approx1_1 c
      | Approx1_2 -> set_surface_approx1_2 c
      | Approx1 -> set_surface_approx1 c) params

  let be ~mu params =
    let c = create ~mu in
    modify_surface_params c params; c
