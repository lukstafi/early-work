    open Ode

  type t

  (** Create a new, empty world *)
  external create : unit -> t = "ml_dWorldCreate"

  (** Destroy old world and create new one. *)
  external reset : t -> unit = "ml_dWorldReset"

  (** Set and get the world's global gravity vector. The units are
      m/s/s, so Earth's gravity vector would be (0,0,-9.81), assuming that
      +z is up. The default is no gravity, i.e. (0,0,0). *)
  external set_gravity : t -> ?x:float -> ?y:float -> ?z:float -> unit
    -> unit
    = "ml_dWorldSetGravity"
  external get_gravity : t -> vector3
    = "ml_dWorldGetGravity"

  (** Set and get the global ERP value, that controls how much error
      correction is performed in each time step. Typical values are in the
      range 0.1--0.8. The default is 0.2. *)
  external set_ERP : t -> float -> unit
    = "ml_dWorldSetERP"
  external get_ERP : t -> float
    = "ml_dWorldGetERP"

  (** Set and get the global CFM (constraint force mixing)
      value. Typical values are in the range 10e-9 -- 1. The default is
      10e-5 if single precision is being used, or 10e-10 if double
      precision is being used. *)
  external set_CFM : t -> float -> unit
    = "ml_dWorldSetCFM"
  external get_CFM : t -> float
    = "ml_dWorldGetCFM"

  (** Set and get the default auto-disable parameters for newly
      created bodies. The default parameters are:
- AutoDisableFlag = disabled
- AutoDisableLinearThreshold = 0.01 
- AutoDisableAngularThreshold = 0.01
- AutoDisableSteps = 10 
- AutoDisableTime = 0

  *)
  external set_auto_disable_flag : t -> bool -> unit
    = "ml_dWorldSetAutoDisableFlag"
  external get_auto_disable_flag : t -> bool
    = "ml_dWorldGetAutoDisableFlag"
  external set_auto_disable_linear_threshold : t -> float -> unit
    = "ml_dWorldSetAutoDisableLinearThreshold"
  external get_auto_disable_linear_threshold : t -> float
    = "ml_dWorldGetAutoDisableLinearThreshold"
  external set_auto_disable_angular_threshold : t -> float -> unit
    = "ml_dWorldSetAutoDisableAngularThreshold"
  external get_auto_disable_angular_threshold : t -> float
    = "ml_dWorldGetAutoDisableAngularThreshold"
  external set_auto_disable_steps : t -> int -> unit
    = "ml_dWorldSetAutoDisableSteps"
  external get_auto_disable_steps : t -> int
    = "ml_dWorldGetAutoDisableSteps"
  external set_auto_disable_time : t -> float -> unit
    = "ml_dWorldSetAutoDisableTime"
  external get_auto_disable_time : t -> float
    = "ml_dWorldGetAutoDisableTime"

  (** If you want to apply a linear or angular impulse to a rigid
      body, instead of a force or a torque, then you can use this function
      to convert the desired impulse into a force/torque vector before
      calling the dBodyAdd... function.

      This function is given the desired impulse as (ix,iy,iz) and
      puts the force vector in force. The current algorithm simply
      scales the impulse by 1/stepsize, where stepsize is the step
      size for the next step that will be taken.

      This function is given a World.t because, in the future, the
      force computation may depend on integrator parameters that are
      set as properties of the world. *)
  external impulse_to_force : t -> stepsize:float -> ix:float -> iy:float
    -> iz:float -> vector3
    = "ml_dWorldImpulseToForce"

  (** Step the world. This uses a "big matrix" method that takes time
      on the order of m{^3} and memory on the order of m{^2}, where m is
      the total number of constraint rows.

      For large systems this will use a lot of memory and can be very
      slow, but this is currently the most accurate method. *)
  external step : t -> float -> unit
    = "ml_dWorldStep"
      
  (** Step the world. This uses an iterative method that takes time on
      the order of m*N and memory on the order of m, where m is the total
      number of constraint rows and N is the number of iterations.

      For large systems this is a lot faster than dWorldStep, but it
      is less accurate.

      QuickStep is great for stacks of objects especially when the
      auto-disable feature is used as well. However, it has poor
      accuracy for near-singular systems. Near-singular systems can
      occur when using high-friction contacts, motors, or certain
      articulated structures. *)
  external quick_step : t -> float -> unit
    = "ml_dWorldQuickStep"

  (** Set and get the number of iterations that the QuickStep method
      performs per step. More iterations will give a more accurate
      solution, but will take longer to compute. The default is 20
      iterations. *)
  external set_quick_step_num_iterations : t -> int -> unit
    = "ml_dWorldSetQuickStepNumIterations"
  external get_quick_step_num_iterations : t -> int
    = "ml_dWorldGetQuickStepNumIterations"

  (** Set and get the maximum correcting velocity that contacts are
      allowed to generate. The default value is infinity (i.e. no
      limit). Reducing this value can help prevent "popping" of deeply
      embedded objects. *)
  external set_contact_max_correcting_vel : t -> float -> unit
    = "ml_dWorldSetContactMaxCorrectingVel"
  external get_contact_max_correcting_vel : t -> float
    = "ml_dWorldGetContactMaxCorrectingVel"

  (** Set and get the depth of the surface layer around all geometry
      objects. Contacts are allowed to sink into the surface layer up to
      the given depth before coming to rest. The default value is
      zero. Increasing this to some small value (e.g. 0.001) can help
      prevent jittering problems due to contacts being repeatedly made and
      broken. *)
  external set_contact_surface_layer : t -> float -> unit
    = "ml_dWorldSetContactSurfaceLayer"
  external get_contact_surface_layer : t -> float
    = "ml_dWorldGetContactnSurfaceLayer"

  (** Step the world by stepsize seconds using the StepFast1
      algorithm. The number of iterations to perform is given by
      maxiterations. *)
  external step_fast1 : t -> stepsize:float -> maxiterations:int ->
    unit = "ml_dWorldStepFast1"
      
  (** Set and get the AutoEnableDepth parameter used by the StepFast1
      algorithm. *)
  external set_auto_enable_depth_SF1 : t -> int -> unit
    = "ml_dWorldSetAutoEnableDepthSF1"
  external get_auto_enable_depth_SF1 : t -> int
    = "ml_dWorldGetAutoEnableDepthSF1"
