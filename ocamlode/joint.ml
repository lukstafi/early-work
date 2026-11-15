  open Ode

  (* keep in sync with "common.h" enumeration *)
  type joints =
	 None_joint
       | Ball_j				(** ball-and-socket *)
       | Hinge_j
       | Slider_j
       | Contact_j
       | Universal_j
       | Hinge2_j
       | Fixed_j
       | Null_joint_j
       | AMotor_j			(** angular motor *)

  type 'a t

  type ball_t
  type hinge_t
  type slider_t
  type contact_t
  type universal_t
  type hinge2_t
  type fixed_t
  type amotor_t

  type unknown_t

  type ball = ball_t t
  type hinge = hinge_t t
  type slider = slider_t t
  type contact = contact_t t
  type universal = universal_t t
  type hinge2 = hinge2_t t
  type fixed = fixed_t t
  type amotor = amotor_t t

  type some = unknown_t t

  type joint = Ball of ball | Hinge of hinge
	       | Slider of slider | Contact of contact
	       | Universal of universal | Hinge2 of hinge2
	       | Fixed of fixed | AMotor of amotor

  (** comparison works on the whole class of joints *)
  external eq : 'a t -> 'b t -> bool
    = "ml_dJoint_eq"
  external compare : 'a t -> 'b t -> int
    = "ml_dJoint_compare"

  let some (j : 'a t) = ((Obj.magic j) : some)

  (** Create a new joint of a given type. The joint is initially in
      "limbo" (i.e. it has no effect on the simulation) because it does
      not connect to any bodies. If the joint group is given, the joint
      is allocated in the given joint group. *)
  external create_ball : ?dst:JointGroup.t -> World.t -> ball
    = "ml_dJointCreateBall"
  external create_hinge : ?dst:JointGroup.t -> World.t -> hinge
    = "ml_dJointCreateHinge"
  external create_slider : ?dst:JointGroup.t -> World.t -> slider
    = "ml_dJointCreateSlider"
  external create_universal : ?dst:JointGroup.t -> World.t -> universal
    = "ml_dJointCreateUniversal"
  external create_hinge2 : ?dst:JointGroup.t -> World.t -> hinge2
    = "ml_dJointCreateHinge2"
  external create_fixed : ?dst:JointGroup.t -> World.t -> fixed
    = "ml_dJointCreateFixed"
  external create_amotor : ?dst:JointGroup.t -> World.t -> amotor
    = "ml_dJointCreateAMotor"
  external destroy : 'a t -> unit
    = "ml_dJointDestroy"
  external attach : 'a t -> ?b1:Body.t -> ?b2:Body.t -> unit -> unit
    = "ml_dJointAttach"
  external get_type : 'a t -> joints
    = "ml_dJointGetType"
  let type_joint j =
    match get_type j with
	None_joint -> raise (Invalid_argument "Unknown joint")
      | Ball_j -> Ball (Obj.magic j)
      | Hinge_j -> Hinge (Obj.magic j)
      | Slider_j -> Slider (Obj.magic j)
      | Contact_j -> Contact (Obj.magic j)
      | Universal_j -> Universal (Obj.magic j)
      | Hinge2_j -> Hinge2 (Obj.magic j)
      | Fixed_j -> Fixed (Obj.magic j)
      | Null_joint_j -> raise (Invalid_argument "Nullary joint")
      | AMotor_j -> AMotor (Obj.magic j)

  exception Type_mismatch of string
  let nop s _ = raise (Type_mismatch s)
  let match_type j
      ?(ball : ball -> 'a = (nop "ball"))
      ?(hinge : hinge -> 'a =(nop "hinge"))
      ?(slider : slider -> 'a =(nop "slider"))
      ?(contact : contact -> 'a =(nop "contact"))
      ?(universal : universal -> 'a =(nop "universal"))
      ?(hinge2 : hinge2 -> 'a =(nop "hinge2"))
      ?(fixed : fixed -> 'a =(nop "fixed"))
      ?(amotor : amotor -> 'a =(nop "amotor")) () =
    match get_type j with
	None_joint -> raise (Invalid_argument "Unknown joint")
      | Ball_j -> ball (Obj.magic j)
      | Hinge_j -> hinge (Obj.magic j)
      | Slider_j -> slider (Obj.magic j)
      | Contact_j -> contact (Obj.magic j)
      | Universal_j -> universal (Obj.magic j)
      | Hinge2_j -> hinge2 (Obj.magic j)
      | Fixed_j -> fixed (Obj.magic j)
      | Null_joint_j -> raise (Invalid_argument "Nullary joint")
      | AMotor_j -> amotor (Obj.magic j)
	  
  type bodynum = First | Second

  external get_body : 'a t -> bodynum -> Body.t option
    = "ml_dJointGetBody"

  (** During the world time step, the forces that are applied by each
      joint are computed. These forces are added directly to the joined
      bodies, and the user normally has no way of telling which joint
      contributed how much force.

      If this information is desired then the user can allocate a
      feedback structure. During the time step any feedback structures
      that are attached to joints will be filled in with the joint's
      force and torque information. *)
  type feedback

  external create_feedback : ?fb:'a t -> unit -> feedback
    = "ml_dJointFeedbackCreate"
  external set_feedback : 'a t -> feedback -> unit
    = "ml_dJointFeedbackSet"
  external reset_feedback : feedback -> unit
    = "ml_dJointFeedbackReset"

    (** force that joint applies to body 1 *)
  external feedback_f1 : feedback -> vector3
    = "ml_dJointFeedback_f1"

    (** torque that joint applies to body 1 *)
  external feedback_t1 : feedback -> vector3
    = "ml_dJointFeedback_t1"

    (** force that joint applies to body 2 *)
  external feedback_f2 : feedback -> vector3
    = "ml_dJointFeedback_f2"

    (** torque that joint applies to body 2 *)
  external feedback_t2 : feedback -> vector3
    = "ml_dJointFeedback_f2"

  external are_connected : Body.t -> Body.t -> bool
    = "ml_dAreConnected"
  external are_connected_excluding : Body.t -> Body.t -> joints -> bool
    = "ml_dAreConnectedExcluding"

  (** Set the joint anchor point. The joint will try to keep this point
      on each body together. The input is specified in world
      coordinates. *)
  external set_ball_anchor : ball -> x:float -> y:float -> z:float
    -> unit = "ml_dJointSetBallAnchor"

  (** Get the joint anchor point, in world coordinates. This returns
      the point on body 1. If the joint is perfectly satisfied,
      this will be the same as the point on body 2. *)
  external get_ball_anchor : ball -> vector3
    = "ml_dJointGetBallAnchor"

  (** Get the joint anchor point, in world coordinates. This returns
      the point on body 2. You can think of a ball and socket joint as
      trying to keep the result of {!Joint.get_ball_anchor} and
      {!Joint.get_ball_anchor2} the same. If the joint is perfectly
      satisfied, this function will return the same value as
      {!Joint.get_ball_anchor} to within roundoff
      errors. {!Joint.get_ball_anchor2} can be used, along with
      {!Joint.get_ball_anchor}, to see how far the joint has come apart. *)
  external get_ball_anchor2 : ball -> vector3
    = "ml_dJointGetBallAnchor2"

  external set_hinge_anchor : hinge -> x:float -> y:float ->
    z:float -> unit = "ml_dJointSetHingeAnchor"
  external set_hinge_axis : hinge -> ?x:float -> ?y:float ->
    ?z:float -> unit -> unit = "ml_dJointSetHingeAxis"
  external get_hinge_anchor : hinge -> vector3
    = "ml_dJointGetHingeAnchor"
  external get_hinge_anchor2 : hinge -> vector3
    = "ml_dJointGetHingeAnchor2"
  external get_hinge_axis : hinge ->vector3
    = "ml_dJointGetHingeAxis"

  (** Get the hinge angle and the time derivative of this value. The
      angle is measured between the two bodies, or between the
      body and the static environment. The angle will be between
      -pi..pi.

      When the hinge anchor or axis is set, the current position
      of the attached bodies is examined and that position will be
      the zero angle. *)
  external get_hinge_angle : hinge -> float
    = "ml_dJointGetHingeAngle"
  external get_hinge_angle_rate : hinge -> float
    = "ml_dJointGetHingeAngleRate"

  external set_slider_axis : slider -> ?x:float -> ?y:float ->
    ?z:float -> unit -> unit = "ml_dJointSetSliderAxis"
  external get_slider_axis : slider -> vector3
    = "ml_dJointGetSliderAxis"

  (**Get the slider linear position (i.e. the slider's ``extension'')
     and the time derivative of this value.

     When the axis is set, the current position of the attached bodies
     is examined and that position will be the zero position. *)
  external get_slider_position : hinge -> float
    = "ml_dJointGetSliderPosition"
  external get_slider_position_rate : hinge -> float
    = "ml_dJointGetSliderPositionRate"

  (** Set universal anchor and axis parameters. Axis 1 and axis 2 should
      be perpendicular to each other. *)    
  external set_universal_anchor : universal -> x:float -> y:float ->
    z:float -> unit = "ml_dJointSetUniversalAnchor"
  external set_universal_axis1 : universal -> ?x:float -> ?y:float ->
    ?z:float -> unit -> unit = "ml_dJointSetUniversalAxis1"
  external set_universal_axis2 : universal -> ?x:float -> ?y:float ->
    ?z:float -> unit -> unit = "ml_dJointSetUniversalAxis2"

  external get_universal_anchor : universal -> vector3
    = "ml_dJointGetUniversalAnchor"
  external get_universal_anchor2 : universal -> vector3
    = "ml_dJointGetUniversalAnchor2"
  external get_universal_axis1 : universal -> vector3
    = "ml_dJointGetUniversalAxis1"
  external get_universal_axis2 : universal -> vector3
    = "ml_dJointGetUniversalAxis2"
  external get_universal_angle1 : universal -> float
    = "ml_dJointGetUniversalAngle1"
  external get_universal_angle2 : universal -> float
    = "ml_dJointGetUniversalAngle2"
  external get_universal_angle1_rate : universal -> float
    = "ml_dJointGetUniversalAngle1Rate"
  external get_universal_angle2_rate : universal -> float
    = "ml_dJointGetUniversalAngle2Rate"

  external set_hinge2_anchor : hinge2 -> x:float -> y:float ->
    z:float -> unit = "ml_dJointSetHinge2Anchor"
  external set_hinge2_axis1 : hinge2 -> ?x:float -> ?y:float ->
    ?z:float -> unit -> unit = "ml_dJointSetHinge2Axis1"
  external set_hinge2_axis2 : hinge2 -> ?x:float -> ?y:float ->
    ?z:float -> unit -> unit = "ml_dJointSetHinge2Axis2"

  external get_hinge2_anchor : hinge2 -> vector3
    = "ml_dJointGetHinge2Anchor"
  external get_hinge2_anchor2 : hinge2 -> vector3
    = "ml_dJointGetHinge2Anchor2"
  external get_hinge2_axis1 : hinge2 -> vector3
    = "ml_dJointGetHinge2Axis1"
  external get_hinge2_axis2 : hinge2 -> vector3
    = "ml_dJointGetHinge2Axis2"

  external get_hinge2_angle1 : hinge2 -> float
    = "ml_dJointGetHinge2Angle1"
  external get_hinge2_angle1_rate : hinge2 -> float
    = "ml_dJointGetHinge2Angle1Rate"
  external get_hinge2_angle2_rate : hinge2 -> float
    = "ml_dJointGetHinge2Angle2Rate"

  (** Call this on the fixed joint after it has been attached to
      remember the current desired relative offset and desired relative
      rotation between the bodies. *)
  external set_fixed : fixed -> unit
    = "ml_dJointSetFixed"

  type motor_mode =
      AMotor_user (** The AMotor axes and joint angle settings are
		     entirely controlled by the user. This is the
		     default mode.  *)
    | AMotor_euler (** Euler angles are automatically computed. The
		      axis a1 is also automatically computed. The
		      AMotor axes must be set correctly when in this
		      mode, as described below. When this mode is
		      initially set the current relative orientations
		      of the bodies will correspond to all euler
		      angles at zero. *)

  external set_amotor_mode : amotor -> motor_mode -> unit
    = "ml_dJointSetAMotorMode"
  external get_amotor_mode : amotor -> motor_mode
    = "ml_dJointGetAMotorMode"

  type num_axes = No_ax | One_ax | Two_ax | Three_ax
  external set_amotor_num_axes : amotor -> num_axes ->unit
    = "ml_dJointSetAMotorNumAxes"
  external get_amotor_num_axes : amotor -> num_axes
    = "ml_dJointGetAMotorNumAxes"

  type relative = Global_rel | Fst_body_rel | Snd_body_rel
  type ax_num = First_ax | Second_ax | Third_ax

  external set_amotor_axis : amotor -> ax_num -> relative ->
    x:float -> y:float ->
    z:float -> unit = "ml_dJointSetAMotorAxis_bc"
       "ml_dJointSetAMotorAxis"
  external get_amotor_axis : amotor -> ax_num -> vector3
    = "ml_dJointGetAMotorAxis"
  external get_amotor_axis_rel : amotor -> ax_num -> relative
    = "ml_dJointGetAMotorAxisRel"

  let set_euler_amotor mot ~fst_body_ax:(x1,y1,z1) ~snd_body_ax:(x2,y2,z2) =
    set_amotor_mode mot AMotor_euler;
    set_amotor_axis mot First_ax Fst_body_rel x1 y1 z1;
    set_amotor_axis mot Third_ax Snd_body_rel x2 y2 z2

  external set_amotor_angle : amotor -> ax_num -> float -> unit
    = "ml_dJointSetAMotorAngle"
  external get_amotor_angle : amotor -> ax_num -> float
    = "ml_dJointGetAMotorAngle"
  external get_amotor_angle_rate : amotor -> ax_num -> float
    = "ml_dJointGetAMotorAngleRate"

  type params =
      Lo_stop (** Low stop angle or position. Setting this to
		  -infinity (the default value) turns off the low
		  stop. For rotational joints, this stop must be
		  greater than - pi to be effective. *)
    | Hi_stop (** High stop angle or position. Setting this to
		  dInfinity (the default value) turns off the high
		  stop. For rotational joints, this stop must be less
		  than pi to be effective. If the high stop is less
		  than the low stop then both stops will be
		  ineffective. *)
    | Vel (** Desired motor velocity (this will be an angular or
	      linear velocity). *)
    | FMax (** The maximum force or torque that the motor will use to
	       achieve the desired velocity. This must always be greater than
	       or equal to zero. Setting this to zero (the default value) turns
	       off the motor. *)
    | Fudge_factor (** The current joint stop/motor implementation has
		       a small problem: when the joint is at one stop
		       and the motor is set to move it away from the
		       stop, too much force may be applied for one
		       time step, causing a ``jumping'' motion. This
		       fudge factor is used to scale this excess
		       force. It should have a value between zero and
		       one (the default value). If the jumping motion
		       is too visible in a joint, the value can be
		       reduced. Making this value too small can
		       prevent the motor from being able to move the
		       joint away from a stop. *)
    | Bounce (** The bouncyness of the stops. This is a restitution
		 parameter in the range 0..1. 0 means the stops are
		 not bouncy at all, 1 means maximum bouncyness. *)
    | Stop_ERP (** The error reduction parameter (ERP) used by the
		   stops. *)
    | Stop_CFM (** The constraint force mixing (CFM) value used by the
		   stops. Together with the ERP value this can be used
		   to get spongy or soft stops. Note that this is
		   intended for unpowered joints, it does not really
		   work as expected when a powered joint reaches its
		   limit. *)
    | Suspension_ERP (** Suspension error reduction parameter
			 (ERP). Currently this is only implemented on
			 the hinge-2 joint. *)
    | Suspension_CFM (** Suspension constraint force mixing (CFM)
			 value. Currently this is only implemented on
			 the hinge-2 joint. *)

  external set_hinge_param : hinge -> ?ax:ax_num -> params -> float ->
    unit = "ml_dJointSetHingeParam"
  external set_slider_param : slider -> ?ax:ax_num -> params -> float ->
    unit = "ml_dJointSetSliderParam"
  external set_hinge2_param : hinge2 -> ?ax:ax_num -> params -> float ->
    unit = "ml_dJointSetHinge2Param"
  external set_universal_param : universal -> ?ax:ax_num -> params -> float ->
    unit = "ml_dJointSetUniversalParam"
  external set_amotor_param : amotor -> ?ax:ax_num -> params -> float
    = "ml_dJointSetAMotorParam"
  external get_hinge_param : hinge -> ?ax:ax_num -> params -> float
    = "ml_dJointGetHingeParam"
  external get_slider_param : slider -> ?ax:ax_num -> params -> float
    = "ml_dJointGetSliderParam"
  external get_hinge2_param : hinge2 -> ?ax:ax_num -> params -> float
    = "ml_dJointGetHinge2Param"
  external get_universal_param : universal -> ?ax:ax_num -> params -> float
    = "ml_dJointGetUniversalParam"
  external get_amotor_param : amotor -> ?ax:ax_num -> params -> float
    = "ml_dJointGetAMotorParam"

  (** Applies the torque about the hinge axis. That is, it applies a
      torque with magnitude torque, in the direction of the hinge axis,
      to body 1, and with the same magnitude but in opposite direction
      to body 2. This function is just a wrapper for Body.add_torque. *)
  external add_hinge_torque : hinge -> float -> unit
    = "ml_dJointAddHingeTorque"

  (** Applies torque1 about the universal's axis 1, and torque2 about
      the universal's axis 2. This function is just a wrapper for
      Body.add_torque. *)
  external add_universal_torques : universal -> fst_ax:float ->
    snd_ax:float -> unit
    = "ml_dJointAddUniversalTorques"

  (** Applies the given force in the slider's direction. That is, it
      applies a force with magnitude force, in the direction slider's
      axis, to body1, and with the same magnitude but opposite direction
      to body2. This function is just a wrapper for Body.add_force. *)
  external add_slider_force : slider -> float -> unit
    = "ml_dJointAddSliderForce"

  (** Applies torque1 about the hinge2's axis 1, and torque2 about the
      hinge2's axis 2. This function is just a wrapper for
      Body.add_torque. *)
  external add_hinge2_torque : hinge2 -> fst_ax:float ->
    snd_ax:float -> unit
    = "ml_dJointAddHinge2Torque"

  (** Applies torque0 about the AMotor's axis 0, torque1 about the
      AMotor's axis 1, and torque2 about the AMotor's axis 2. If the motor
      has fewer than three axes, the higher torques are ignored. This
      function is just a wrapper for dBodyAddTorque. *)
  external add_amotor_torques : amotor -> fst_ax:float ->
    snd_ax:float -> unit
    = "ml_dJointAddAMotorTorques"

  (** Return a joint attached to this body, given by index. Valid
      indexes are 0 to n-1 where n is the value returned by
      Body.get_num_joints. *)
  external unsafe_from_body : Body.t -> int -> some
    = "ml_dBodyGetJoint"
  let from_body b i =
    if i >= 0 && i < Body.get_num_joints b then unsafe_from_body b i
    else raise (Invalid_argument "Joint index exceeds range")
  let match_from_body b i = match_type (from_body b i)
