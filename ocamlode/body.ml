  open Ode

  type t

  (** Create a body in the given world with default mass parameters at
      position (0,0,0). *)
  external create : World.t -> t
    = "ml_dBodyCreate"
  external destroy : t -> unit
    = "ml_dBodyDestroy"

  (** These functions set and get the position, rotation, linear and
      angular velocity of the body. After setting a group of bodies, the
      outcome of the simulation is undefined if the new configuration is
      inconsistent with the joints/constraints that are present. *)
  external set_position : t -> x:float -> y:float -> z:float -> unit
    = "ml_dBodySetPosition"
  external set_rotation : t -> x:float -> y:float -> z:float -> unit
    = "ml_dBodySetRotation"
  external set_quaternion : t -> quaternion -> unit
    = "ml_dBodySetQuaternion"
  external set_linear_vel : t -> x:float -> y:float -> z:float -> unit
    = "ml_dBodySetLinearVel"
  external set_angular_vel : t -> x:float -> y:float -> z:float -> unit
    = "ml_dBodySetAngularVel"
  external get_position : t -> vector3
    = "ml_dBodyGetPosition"
  external get_rotation : t -> matrix3
    = "ml_dBodyGetRotation"
  external get_quaternion : t -> quaternion
    = "ml_dBodyGetQuaternion"
  external get_linear_vel : t -> vector3
    = "ml_dBodyGetLinearVel"
  external get_angular_vel : t -> vector3
    = "ml_dBodyGetAngularVel"

  (** dd forces to bodies (absolute or relative coordinates). The
      forces are accumulated on to each body, and the accumulators are
      zeroed after each time step.

      The ...RelForce and ...RelTorque functions take force vectors
      that are relative to the body's own frame of reference.

      The ...ForceAtPos and ...ForceAtRelPos functions take an extra
      position vector (in global or body-relative coordinates
      respectively) that specifies the point at which the force is
      applied. All other functions apply the force at the center of
      mass. *)
  external add_force : t -> fx:float -> fy:float -> fz:float -> unit
    = "ml_dBodyAddForce"
  external add_torque : t -> fx:float -> fy:float -> fz:float -> unit
    = "ml_dBodyAddTorque"
  external add_rel_force : t -> fx:float -> fy:float -> fz:float -> unit
    = "ml_dBodyAddRelForce"
  external add_rel_torque : t -> fx:float -> fy:float -> fz:float -> unit
    = "ml_dBodyAddRelTorque"
  external add_force_at_pos : t -> fx:float -> fy:float -> fz:float
    -> px:float -> py:float -> pz:float -> unit
    = "ml_dBodyAddForceAtPos_bc" "ml_dBodyAddForceAtPos"
  external add_force_at_rel_pos : t -> fx:float -> fy:float -> fz:float
    -> px:float -> py:float -> pz:float -> unit
    = "ml_dBodyAddForceAtRelPos_bc" "ml_dBodyAddForceAtRelPos"
  external add_rel_force_at_pos : t -> fx:float -> fy:float -> fz:float
    -> px:float -> py:float -> pz:float -> unit
    = "ml_dBodyAddRelForceAtPos_bc" "ml_dBodyAddRelForceAtPos"
  external add_rel_force_at_rel_pos : t -> fx:float -> fy:float -> fz:float
    -> px:float -> py:float -> pz:float -> unit
    = "ml_dBodyAddRelForceAtRelPos_bc"
      "ml_dBodyAddRelForceAtRelPos"

  (** Return the current accumulated force and torque vector. *)
  external get_force : t -> vector3
    = "ml_dBodyGetForce"
  external get_torque : t -> vector3
    = "ml_dBodyGetTorque"

  (** Set the body force and torque accumulation vectors. This is mostly
      useful to zero the force and torque for deactivated bodies before they
      are reactivated, in the case where the force-adding functions were
      called on them while they were deactivated. *)
  external set_force : t -> x:float -> y:float -> z:float -> unit
    = "ml_dBodySetForce"
  external set_torque : t -> x:float -> y:float -> z:float -> unit
    = "ml_dBodySetTorque"

  (** Utility functions that take a point on a body (px,py,pz) and
      return that point's position or velocity in global coordinates. The
      get_rel_point_XXX functions are given the point in body relative
      coordinates, and the get_point_vel function is given the point in
      global coordinates. *)
  external get_rel_point_pos : t -> px:float -> py:float -> pz:float
    -> vector3
    = "ml_dBodyGetRelPointPos"
  external get_rel_point_vel : t -> px:float -> py:float -> pz:float
    -> vector3
    = "ml_dBodyGetRelPointVel"
  external get_point_vel : t -> px:float -> py:float -> pz:float
    -> vector3
    = "ml_dBodyGetPointVel"

  (** This is the inverse of dBodyGetRelPointPos. It takes a point in
      global coordinates (x,y,z) and returns the point's position in
      body-relative coordinates. *)
  external get_pos_rel_point : t -> px:float -> py:float -> pz:float
    -> vector3
    = "ml_dBodyGetPosRelPoint"
      
  (** Given a vector expressed in the body (or world) coordinate
      system (x,y,z), rotate it to the world (or body) coordinate
      system. *)
  external vector_to_world : t -> px:float -> py:float -> pz:float
    -> vector3
    = "ml_dBodyVectorToWorld"
  external vector_from_world : t -> px:float -> py:float -> pz:float
    -> vector3
    = "ml_dBodyVectorFromWorld"

  (** Manually enable and disable a body. Note that a disabled body
      that is connected through a joint to an enabled body will be
      automatically re-enabled at the next simulation step. *)
  external enable : t -> unit
    = "ml_dBodyEnable"
  external disable : t -> unit
    = "ml_dBodyDisable"
  external is_enabled : t -> bool
    = "ml_dBodyIsEnabled"

  (** Set and get the auto-disable flag of a body. If set to true, the
      body will be automatically disabled when it has been idle for long
      enough. *)
  external set_auto_disable_flag : t -> bool -> unit
    = "ml_dBodySetAutoDisableFlag"
  external get_auto_disable_flag : t -> bool
    = "ml_dBodySetAutoDisableFlag"

  (** Set and get a body's linear velocity threshold for automatic
      disabling. The body's linear velocity magnitude must be less than
      this threshold for it to be considered idle. Set the threshold to
      dInfinity to prevent the linear velocity from being considered. *)
  external set_auto_disable_linear_threshold : t -> float -> unit
    = "ml_dBodySetAutoDisableLinearThreshold"
  external get_auto_disable_linear_threshold : t -> float
    = "ml_dBodyGetAutoDisableLinearThreshold"

  (** Set and get a body's angular velocity threshold for automatic
      disabling. The body's linear angular magnitude must be less than
      this threshold for it to be considered idle. Set the threshold to
      dInfinity to prevent the angular velocity from being considered. *)
  external set_auto_disable_angular_threshold : t -> float -> unit
    = "ml_dBodySetAutoDisableAngularThreshold"
  external get_auto_disable_angular_threshold : t -> float
    = "ml_dBodyGetAutoDisableAngularThreshold"

  (** Set and get the number of simulation steps that a body must be
      idle before it is automatically disabled. Set this to zero to
      disable consideration of the number of steps. *)
  external set_auto_disable_steps : t -> int -> unit
    = "ml_dBodySetAutoDisableSteps"
  external set_auto_disable_steps : t -> int -> unit
    = "ml_dBodySetAutoDisableSteps"

  (** Set and get the amount of simulation time that a body must be
      idle before it is automatically disabled. Set this to zero to
      disable consideration of the amount of simulation time. *)
  external set_auto_disable_time : t -> float -> unit
    = "ml_dBodySetAutoDisableTime"
  external get_auto_disable_time : t -> float
    = "ml_dBodyGetAutoDisableTime"

  (** Set the auto-disable parameters of the body to the default
      parameters that have been set on the world. *)
  external set_auto_disable_defaults : t -> unit
    = "ml_dBodySetAutoDisableDefaults"

  type rotation_mode = Infinitesimal | Finite

  (** This function controls the way a body's orientation is updated
      at each time step. The mode argument can be: - Infinitesimal: An
      ``infinitesimal'' orientation update is used. This is fast to
      compute, but it can occasionally cause inaccuracies for bodies that
      are rotating at high speed, especially when those bodies are joined
      to other bodies. This is the default for every new body that is
      created.  - Finite: A ``finite'' orientation update is used. This is
      more costly to compute, but will be more accurate for high speed
      rotations. Note however that high speed rotations can result in many
      types of error in a simulation, and this mode will only fix one of
      those sources of error.

  *)
  external set_rotation_mode : t -> rotation_mode -> unit
    = "ml_dBodySetFiniteRotationMode"
  external get_rotation_mode : t -> rotation_mode
    = "ml_dBodyGetFiniteRotationMode"

  (** This sets the finite rotation axis for a body. This is axis only
      has meaning when the finite rotation mode is set (see
      dBodySetFiniteRotationMode).

      If this axis is zero (0,0,0), full finite rotations are
      performed on the body.

      If this axis is nonzero, the body is rotated by performing a
      partial finite rotation along the axis direction followed by an
      infinitesimal rotation along an orthogonal direction.

      This can be useful to alleviate certain sources of error caused
      by quickly spinning bodies. For example, if a car wheel is
      rotating at high speed you can call this function with the
      wheel's hinge axis as the argument to try and improve its
      behavior. *)
  external set_finite_rotation_axis : t -> ?x:float -> ?y:float ->
    ?z:float -> unit -> unit
    = "ml_dBodySetFiniteRotationAxis"

  (** Return the current finite rotation axis of a body. *)
  external get_finite_rotation_axis : t -> vector3
    = "ml_dBodyGetFiniteRotationAxis"

(** Return the number of joints that are attached to this body. *)
  external get_num_joints : t -> int
    = "ml_dBodyGetNumJoints"

  type gravity_mode = GravOff | GravOn

  (** Set/get whether the body is influenced by the world's gravity or
      not. If mode is nonzero it is, if mode is zero, it isn't. Newly
      created bodies are always influenced by the world's gravity. *)
  external set_gravity_mode : t -> gravity_mode -> unit
    = "ml_dBodySetGravityMode"
  external get_gravity_mode : t -> gravity_mode
    = "ml_dBodyGetGravityMode"

(** Set and get the per-body AutoDisableThreshold parameter used by
    the StepFast1 algorithm. *)
  external set_auto_disable_threshold_SF1 : t -> float -> unit
    = "ml_dBodySetAutoDisableThresholdSF1"
  external get_auto_disable_threshold_SF1 : t -> float
    = "ml_dBodyGetAutoDisableThresholdSF1"

  (** Set and get the per-body AutoDisableSteps parameter used by the
      StepFast1 algorithm. *)
  external set_auto_disable_steps_SF1 : t -> int -> unit
    = "ml_dBodySetAutoDisableStepsSF1"
  external get_auto_disable_steps_SF1 : t -> int
    = "ml_dBodyGetAutoDisableStepsSF1"

(** Set and get the per-body AutoDisable flag used by the StepFast1
    algorithm. If AutoDisable is true, auto-disabling is
    enabled. If AutoDisable is false, auto-disabling is disabled. *)
  external set_auto_disable_steps_SF1 : t -> bool -> unit
    = "ml_dBodySetAutoDisableSF1"
  external get_auto_disable_steps_SF1 : t -> bool
    = "ml_dBodyGetAutoDisableSF1"
