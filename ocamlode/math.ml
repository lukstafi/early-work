  open Ode

(* from <rotation.h> *)

  external r_set_identity : unit -> matrix3
    = "ml_dRSetIdentity"
  external r_from_axis_and_angle : ?ax:float -> ?ay:float -> ?az:float
    -> angle:float -> unit -> matrix3
    = "ml_dRFromAxisAndAngle"
  external r_from_euler_angles : phi:float -> theta:float -> psi:float
    -> matrix3 = "ml_dRFromEulerAngles"
  external r_from_2_axes : ?ax:float -> ?ay:float -> ?az:float ->
    ?bx:float -> ?by:float -> ?bz:float -> unit -> unit
    = "ml_dRFrom2Axes" "ml_dRFrom2Axes"
  external r_from_z_axis : ?ax:float -> ?ay:float -> ?az:float ->unit -> unit
    = "ml_dRFromZAxis"
  external q_set_identity : unit -> quaternion
    = "ml_dQSetIdentity"
  external q_from_axis_and_angle : ?ax:float -> ?ay:float -> ?az:float
    -> angle:float -> quaternion
    = "ml_dQFromAxisAndAngle"

(** Quaternion multiplication, analogous to the matrix multiplication
    routines. *)
  (** Rotate by second, then by first argument. *)
  external q_multiply0 : quaternion -> quaternion -> quaternion
    = "ml_dQMultiply0"

  (** Rotate by second, then by inverse of first argument. *)
  external q_multiply1 : quaternion -> quaternion -> quaternion
    = "ml_dQMultiply1"

  (** Rotate by inverse of second, then by first argument. *)
  external q_multiply2 : quaternion -> quaternion -> quaternion
    = "ml_dQMultiply2"

  (** Rotate by inverse of second, then by inverse of first argument. *)
  external q_multiply3 : quaternion -> quaternion -> quaternion
    = "ml_dQMultiply3"

  external r_from_q : quaternion -> matrix3
    = "ml_dRfromQ"
  external q_from_r : matrix3 -> quaternion
    = "ml_dQfromR"
  external dq_from_w : vector3 -> quaternion -> vector4
    = "ml_dDQfromW"

(* from <matrix.h> *)

(** matrix multiplication. all matrices are stored in standard row format.
 * the digit refers to the argument that is transposed:
 *   0:   A = B  * C   (sizes: A:p*r B:p*q C:q*r)
 *   1:   A = B' * C   (sizes: A:p*r B:q*p C:q*r)
 *   2:   A = B  * C'  (sizes: A:p*r B:p*q C:r*q)
 * case 1,2 are equivalent to saying that the operation is A=B*C but
 * B or C are stored in standard column format.
*)
  external multiply0 : matrix3 -> matrix3 -> matrix3
    = "ml_dM3Multiply0"
  external multiply1 : matrix3 -> matrix3 -> matrix3
    = "ml_dM3Multiply1"
  external multiply2 : matrix3 -> matrix3 -> matrix3
    = "ml_dM3Multiply2"
