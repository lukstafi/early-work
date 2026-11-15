    open Ode

  type t

  external create : unit -> t = "ml_dJointGroupCreate"

  (** Empty a joint group. All joints in the joint group will be
      destroyed, but the joint group itself will not be destroyed. *)
  external empty : t -> unit = "ml_dJointGroupEmpty"
