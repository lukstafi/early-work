/* OCaml bindings for the Open Dynamics Engine (ODE).
 * By Lukasz Stafiniak <lukstafi@gmail.com>
 */

#define CAML_NAME_SPACE 1


#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/config.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/printexc.h>

#include <ode/ode.h>

#define MLODE_DEBUG

//debug test only:
//#define ARCH_ALIGN_DOUBLE

#include "yacintf.h"


/** The [RefCount] structure mediates between the object and the
    references to the object. It lives as long as the object or any
    reference to it lives. */
typedef struct RefCount {
  int ref_count;		/** how many related references,
				    plus the object if not destroyed */
  int obj_state;		/** is the object still alife? */
} RefCount;

void ml_dFnAtDestroy (void *memdata)
{
  RefCount *rc = (RefCount *)memdata;
  rc->ref_count--;
  rc->obj_state = 0;
  if (rc->ref_count == 0) free (rc);
}
int ml_dCondDestroy (void *memdata)
{
  RefCount *rc = (RefCount *)memdata;
  return (rc->ref_count <= 1);
}

/** Memory management must be initialized, before anything is created. */
static int ocamlode_initialized = 0;

CAMLprim value
ml_dInitOCamlODE (value unit)
{
  dMemSetFnAtDestroy (ml_dFnAtDestroy);
  dMemSetCondDestroy (ml_dCondDestroy);
  ocamlode_initialized = 1;
  return Val_unit;
}

/** Return a RefCount struct for the object, if it exists, create one
   otherwise. [rc->ref_count] starts with 2 to include the reference
   and the object. */
static inline void *
RefCountCreate_body (dBodyID id)
{
  RefCount *rc = dMemGetDataBody (id);
  if (rc) rc->ref_count++;
  else {
    rc = (RefCount *) malloc (sizeof (RefCount));
    rc->ref_count = 2;
    rc->obj_state = 1;
    dMemSetDataBody (id, (void *) rc);
  }
  return (void *)rc;
}

static inline void *
RefCountCreate_joint (dJointID id)
{
  RefCount *rc = dMemGetDataJoint (id);
  if (rc) rc->ref_count++;
  else {
    rc = (RefCount *) malloc (sizeof (RefCount));
    rc->ref_count = 2;
    rc->obj_state = 1;
    dMemSetDataJoint (id, (void *) rc);
  }
  return (void *)rc;
}

static inline void *
RefCountCreate_geom (dGeomID id)
{
  RefCount *rc = dMemGetDataGeom (id);
  if (rc) rc->ref_count++;
  else {
    rc = (RefCount *) malloc (sizeof (RefCount));
    rc->ref_count = 2;
    rc->obj_state = 1;
    dMemSetDataGeom (id, (void *) rc);
  }
  return (void *)rc;
}


/** World */

/** Worlds are supported in a one world - one handle manner. World is
    only destroyed when its value is finalized. */

CAMLprim value
ml_dInfinity (value unit)
{
  return caml_copy_double (dInfinity);
}

#define WorldID_prepare(v)
#define WorldID_val(v) (*((dWorldID*) (Data_custom_val(v))))

static int
compare_worlds (value v1, value v2)
{
  CAMLparam2 (v1, v2);
  CAMLreturn ((*((long*)(Data_custom_val(v1))))
	       - (*((long*)(Data_custom_val(v2)))));
}

static long
hash_world (value v)
{
  CAMLparam1 (v);
  CAMLreturn (*((long*) (Data_custom_val(v))));
}

void finalize_world (value v)
{
  dWorldDestroy (*((dWorldID*) (Data_custom_val(v))));
}

static struct custom_operations custom_world = {
  identifier: "ocamlode_world",
  finalize: finalize_world,
  compare: compare_worlds,
  hash: hash_world,
  serialize: custom_serialize_default,
  deserialize: custom_deserialize_default
};

CAMLprim value
ml_dWorldCreate (value unit)
{
  if (!ocamlode_initialized) {
    caml_failwith ("Initialize ODE first!");
  }
  value v = caml_alloc_custom (&custom_world, sizeof (dWorldID), 0, 1);
  *((dWorldID*)Data_custom_val (v)) = dWorldCreate ();
  return v;
}

CAMLprim value
ml_dWorldReset (value w)
{
  if (!ocamlode_initialized) {
    caml_failwith ("Initialize ODE first!");
  }
  dWorldDestroy (WorldID_val (w));
  *((dWorldID*)Data_custom_val (w)) = dWorldCreate ();
  return Val_unit;
}

#define WorldID_prepare_copy(v) dWorldID v##_C = WorldID_val(v);
#define WorldID_val_copy(v) v##_C
ML_4u (dWorldSetGravity, WorldID, Real_OPT, Real_OPT, Real_OPT);
ML_1_1s (dWorldGetGravity, WorldID, Vector3);

ML_2 (dWorldSetERP, WorldID, Real);
ML_1_ (dWorldGetERP, WorldID, Real);

ML_2 (dWorldSetCFM, WorldID, Real);
ML_1_ (dWorldGetCFM, WorldID, Real);

ML_2 (dWorldSetAutoDisableFlag, WorldID, Integer);
ML_1_ (dWorldGetAutoDisableFlag, WorldID, Integer);
ML_2 (dWorldSetAutoDisableLinearThreshold, WorldID, Real);
ML_1_ (dWorldGetAutoDisableLinearThreshold, WorldID, Real);
ML_2 (dWorldSetAutoDisableAngularThreshold, WorldID, Real);
ML_1_ (dWorldGetAutoDisableAngularThreshold, WorldID, Real);
ML_2 (dWorldSetAutoDisableSteps, WorldID, Integer);
ML_1_ (dWorldGetAutoDisableSteps, WorldID, Integer);
ML_2 (dWorldSetAutoDisableTime, WorldID, Real);
ML_1_ (dWorldGetAutoDisableTime, WorldID, Real);

ML_5_1 (dWorldImpulseToForce, WorldID, Real, Real, Real, Real, Vector3);
ML_0 (dCloseODE);

ML_2 (dWorldStep, WorldID, Real);
ML_2 (dWorldQuickStep, WorldID, Real);

ML_2 (dWorldSetQuickStepNumIterations, WorldID, Integer);
ML_1_ (dWorldGetQuickStepNumIterations, WorldID, Integer);

ML_2 (dWorldSetContactMaxCorrectingVel, WorldID, Real);
ML_1_ (dWorldGetContactMaxCorrectingVel, WorldID, Real);

ML_2 (dWorldSetContactSurfaceLayer, WorldID, Real);
ML_1_ (dWorldGetContactSurfaceLayer, WorldID, Real);

     /** Body */

/** Bodies can be destroyed manually, otherwise are destroyed when the
    world is finalized. */

typedef struct CustomBody {
  dBodyID id;
  RefCount *rc;
} CustomBody;

static inline dBodyID
BodyID_val (value v)
{
  CustomBody *b = (CustomBody *) (Data_custom_val (v));  
#ifdef ML_DEBUG
  if (!(b->rc->obj_state))
    caml_failwith ("Accessing destroyed body");
#endif
  return b->id;
}

/* Do not destroy bodies, because they still live in their worlds */

void finalize_body (value v)
{
  CustomBody *b = ((CustomBody *) Data_custom_val(v));
  if (--(b->rc->ref_count) == 0) free (b->rc);
  //if ref_count==0, already destroyed
}


static int
compare_bodys (value v1, value v2)
{
  CAMLparam2 (v1, v2);
  CAMLreturn ((*((long*)(Data_custom_val(v1))))
	       - (*((long*)(Data_custom_val(v2)))));
}

static long
hash_body (value v)
{
  CAMLparam1 (v);
  CAMLreturn (*((long*) (Data_custom_val(v))));
}

static struct custom_operations custom_body = {
  identifier: "ocamlode_body",
  finalize: NULL,
  compare: compare_bodys,
  hash: hash_body,
  serialize: custom_serialize_default,
  deserialize: custom_deserialize_default
};

#define Val_BodyID(rv,v) \
  rv = caml_alloc_custom (&custom_body, sizeof (CustomBody), 0, 1); \
  CustomBody *b = ((CustomBody *) Data_custom_val (rv)); \
  b->rc = RefCountCreate_body (v); \
  b->id = v;

#define BodyID_prepare(v)
#define BodyID_prepare_copy(v) dBodyID v##_C = BodyID_val(v);
#define BodyID_val_copy(v) v##_C
#define BodyID_OPT_prepare(v)
#define BodyID_OPT_val(v) (Int_val (v)==0 ? 0 : BodyID_val (Field ((v), 0)))
#define Val_BodyID_OPT(rv,v) Val_OPTION(BodyID,rv,v)
#define dBodyID_OPT dBodyID

ML_1_ (dBodyCreate, WorldID, BodyID);
ML_1 (dBodyDestroy, BodyID);

ML_4 (dBodySetPosition, BodyID, Real, Real, Real);
ML_2 (dBodySetRotation, BodyID, Matrix3);
ML_2 (dBodySetQuaternion, BodyID, Quaternion);
ML_4 (dBodySetLinearVel, BodyID, Real, Real, Real);
ML_4 (dBodySetAngularVel, BodyID, Real, Real, Real);
ML_1_r (dBodyGetPosition, BodyID, Vector3);
ML_1_r (dBodyGetRotation, BodyID, Matrix3);
ML_1_r (dBodyGetQuaternion, BodyID, Quaternion);
ML_1_r (dBodyGetLinearVel, BodyID, Vector3);
ML_1_r (dBodyGetAngularVel, BodyID, Vector3);

ML_4 (dBodyAddForce, BodyID, Real, Real, Real);
ML_4 (dBodyAddTorque, BodyID, Real, Real, Real);
ML_4 (dBodyAddRelForce, BodyID, Real, Real, Real);
ML_4 (dBodyAddRelTorque, BodyID, Real, Real, Real);
ML_7 (dBodyAddForceAtPos, BodyID, Real, Real, Real, Real, Real, Real);
ML_bc7 (ml_dBodyAddForceAtPos);
ML_7 (dBodyAddForceAtRelPos, BodyID, Real, Real, Real, Real, Real, Real);
ML_bc7 (ml_dBodyAddForceAtRelPos);
ML_7 (dBodyAddRelForceAtPos, BodyID, Real, Real, Real, Real, Real, Real);
ML_bc7 (ml_dBodyAddRelForceAtPos);
ML_7 (dBodyAddRelForceAtRelPos, BodyID, Real, Real, Real, Real, Real, Real);
ML_bc7 (ml_dBodyAddRelForceAtRelPos);

ML_1_r (dBodyGetForce, BodyID, Vector3);
ML_1_r (dBodyGetTorque, BodyID, Vector3);
ML_4 (dBodySetForce, BodyID, Real, Real, Real);
ML_4 (dBodySetTorque, BodyID, Real, Real, Real);

ML_4_1 (dBodyGetRelPointPos, BodyID, Real, Real, Real, Vector3);
ML_4_1 (dBodyGetRelPointVel, BodyID, Real, Real, Real, Vector3);
ML_4_1 (dBodyGetPointVel, BodyID, Real, Real, Real, Vector3);
ML_4_1 (dBodyGetPosRelPoint, BodyID, Real, Real, Real, Vector3);
ML_4_1 (dBodyVectorToWorld, BodyID, Real, Real, Real, Vector3);
ML_4_1 (dBodyVectorFromWorld, BodyID, Real, Real, Real, Vector3);

ML_1 (dBodyEnable, BodyID);
ML_1 (dBodyDisable, BodyID);
ML_1_ (dBodyIsEnabled, BodyID, Integer);
ML_2 (dBodySetAutoDisableFlag, BodyID, Integer);
ML_1_ (dBodyGetAutoDisableFlag, BodyID, Integer);
ML_2 (dBodySetAutoDisableLinearThreshold, BodyID, Real);
ML_1_ (dBodyGetAutoDisableLinearThreshold, BodyID, Real);
ML_2 (dBodySetAutoDisableAngularThreshold, BodyID, Real);
ML_1_ (dBodyGetAutoDisableAngularThreshold, BodyID, Real);
ML_2 (dBodySetAutoDisableSteps, BodyID, Integer);
ML_1_ (dBodyGetAutoDisableSteps, BodyID, Integer);
ML_2 (dBodySetAutoDisableTime, BodyID, Real);
ML_1_ (dBodyGetAutoDisableTime, BodyID, Real);
ML_1 (dBodySetAutoDisableDefaults, BodyID);

ML_2 (dBodySetFiniteRotationMode, BodyID, Integer);
ML_1_ (dBodyGetFiniteRotationMode, BodyID, Integer);
ML_4u (dBodySetFiniteRotationAxis, BodyID, Real_OPT, Real_OPT, Real_OPT);
ML_1_1s (dBodyGetFiniteRotationAxis, BodyID, Vector3);
ML_1_ (dBodyGetNumJoints, BodyID, Integer);

ML_2 (dBodySetGravityMode, BodyID, Integer);
ML_1_ (dBodyGetGravityMode, BodyID, Integer);

/** JointGroup */

/** Joint groups, like worlds, follow one group - one handle rule. They
    can be only destroyed by finalization. */

#define JointGroupID_prepare(v)
#define JointGroupID_prepare_copy(v) dJointGroupID v##_C = JointGroupID_val(v);
#define JointGroupID_val_copy(v) v##_C
#define JointGroupID_val(v) (*((dJointGroupID*) (Data_custom_val (v))))

#define JointGroupID_OPT_prepare(v)
#define JointGroupID_OPT_val(v) ((dJointGroupID) (((Int_val(v) == 0) ? 0 : \
			    JointGroupID_val(Field ((v), 0)))))
#define Val_JointGroupID_OPT(rv,v) Val_OPTION(JointGroupID,rv,v)
#define dJointGroupID_OPT dJointGroupID

static int
compare_jointGroups (value v1, value v2)
{
  CAMLparam2 (v1, v2);
  CAMLreturn ((long)(*((dJointGroupID*)(Data_custom_val(v1))))
	       - (long) (*((dJointGroupID*)(Data_custom_val(v2)))));
}

static long
hash_jointGroup (value v)
{
  CAMLparam1 (v);
  CAMLreturn (*((long*) (Data_custom_val(v))));
}

void finalize_jointGroup (value v)
{
  dJointGroupDestroy (*((dJointGroupID*) (Data_custom_val(v))));
}

static struct custom_operations custom_jointGroup = {
  identifier: "ocamlode_jointGroup",
  finalize: finalize_jointGroup,
  compare: compare_jointGroups,
  hash: hash_jointGroup,
  serialize: custom_serialize_default,
  deserialize: custom_deserialize_default
};

CAMLprim value
ml_dJointGroupCreate (value unit)
{
  value v = caml_alloc_custom
    (&custom_jointGroup, sizeof (dJointGroupID), 0, 1);
  *((dJointGroupID*) Data_custom_val (v)) = dJointGroupCreate (0);
  return v;
};


ML_1 (dJointGroupEmpty, JointGroupID);

     /** Joints */

/** Joints are not destroyed at finalization (they are guarded by
    their worlds/groups) - this prevents indeterminism. */

typedef struct CustomJoint {
  dJointID id;
  RefCount *rc;
} CustomJoint;

#define JointID_prepare(v)
#define JointID_prepare_copy(v) dJointID v##_C = JointID_val(v);
#define JointID_val_copy(v) v##_C
static inline dJointID
JointID_val (value v)
{
  CustomJoint *j = (CustomJoint *) (Data_custom_val (v));  
#ifdef ML_DEBUG
  if (!(j->rc->obj_state))
    caml_failwith ("Accessing destroyed joint");
#endif
  return j->id;
}

/* Do not finalize joints, because they still live in their worlds/groups */

void finalize_joint (value v)
{
  CustomJoint *b = ((CustomJoint *) Data_custom_val(v));
  if (--(b->rc->ref_count) == 0) free (b->rc);
  //if ref_count==0, joint is already destroyed
}

int compare_joints (value v1, value v2)
{
  CAMLparam2 (v1, v2);
  CAMLreturn ( (long) (*((dJointID*)(Data_custom_val(v1))))
	       - (long) (*((dJointID*)(Data_custom_val(v2)))));
}

static long
hash_joint (value v)
{
  CAMLparam1 (v);
  CAMLreturn (*((long*) (Data_custom_val(v))));
}

static struct custom_operations custom_joint = {
  identifier: "ocamlode_joint",
  finalize: finalize_joint,
  compare: compare_joints,
  hash: hash_joint,
  serialize: custom_serialize_default,
  deserialize: custom_deserialize_default
};

#define Val_JointID(rv,v) \
  rv = caml_alloc_custom (&custom_joint, sizeof (CustomJoint), 0, 1); \
  CustomJoint *b = ((CustomJoint *) Data_custom_val (rv)); \
  b->id = v; b->rc = RefCountCreate_joint (v);
#define Val_JointID_OPT(rv,v) Val_OPTION(JointID,rv,v)
#define dJointID_OPT dJointID

CAMLprim value
ml_dJoint_eq (value j1, value j2)
{
  return Val_bool ((*((dJointID*)(Data_custom_val(j1))))
		   == (*((dJointID*)(Data_custom_val(j2)))));
}

CAMLprim value
ml_dJoint_compare (value j1, value j2)
{
  return Val_int ((long) (*((dJointID*)(Data_custom_val(j1))))
		   - (long) (*((dJointID*)(Data_custom_val(j2)))));
}

#define JointID_OPT_val(v) ((dJointID) (((Int_val(v) == 0) ? 0 : \
		       JointID_val(Field ((v), 0)))))

#define ML_JointCreate(x) CAMLprim value \
ml_dJointCreate##x (value j, value v) \
{ \
  dJointID id = dJointCreate##x (WorldID_val (v), JointGroupID_OPT_val (j)); \
  value rv; Val_JointID(rv,id) \
  return rv; \
}

ML_JointCreate (Ball);
ML_JointCreate (Hinge);
ML_JointCreate (Slider);
ML_JointCreate (Universal);
ML_JointCreate (Hinge2);
ML_JointCreate (Fixed);
ML_JointCreate (AMotor);


ML_1 (dJointDestroy, JointID);
ML_3u (dJointAttach, JointID, BodyID_OPT, BodyID_OPT);
ML_1_ (dJointGetType, JointID, Integer);
     
ML_2_ (dJointGetBody, JointID, Integer, BodyID_OPT);
ML_2_ (dBodyGetJoint, BodyID, Integer, JointID);


/** Feedbacks */

/** Feedback pin to joint RefCounts just like Caml joint values. They
    are custom blocks that store dJointFeedback struct. When
    finalizing or changing the joint they reset old joint's feedback
    if necessary. */

typedef struct mlode_feedback {
  dJointFeedback jf;
  dJointID id;
  RefCount *rc;
} mlode_feedback;

static int
compare_jointFeedbacks (value v1, value v2)
{
  CAMLparam2 (v1, v2);
  CAMLreturn (((long)(Data_custom_val(v1)))
	       - ((long) (Data_custom_val(v2))));
}

static long
hash_jointFeedback (value v)
{
  CAMLparam1 (v);
  CAMLreturn ((long) (Data_custom_val(v)));
}

void finalize_jointFeedback (value v)
{
  mlode_feedback *fd = (mlode_feedback*) Data_custom_val (v);
  if (fd->rc && (fd->rc->obj_state)
      && &(fd->jf) == dJointGetFeedback (fd->id)) 
    dJointSetFeedback (fd->id, 0);
  if (fd->rc && --(fd->rc->ref_count) == 0) free (fd->rc);
  //if ref_count==0, joint already destroyed
}

static struct custom_operations custom_jointFeedback = {
  identifier: "ocamlode_jointFeedback",
  finalize: finalize_jointFeedback,
  compare: compare_jointFeedbacks,
  hash: hash_jointFeedback,
  serialize: custom_serialize_default,
  deserialize: custom_deserialize_default
};

CAMLprim value
ml_dJointFeedbackCreate (value j, value unit)
{
  CAMLparam2 (j, unit);
  CAMLlocal1 (v);
  v = caml_alloc_custom (&custom_jointFeedback,
			  sizeof (mlode_feedback), 0, 1);
  mlode_feedback *fd = (mlode_feedback*) Data_custom_val (v);
  if (Int_val (j) == 0) { // None
    fd->id = 0; fd->rc = 0;
  } else {
    CustomJoint *cj = (CustomJoint *) Data_custom_val (Field (j, 0));
    fd->id = cj->id; fd->rc = cj->rc;
    (fd->rc->ref_count)++;
    dJointSetFeedback (fd->id, &(fd->jf));
  }
  CAMLreturn (v);
}

CAMLprim value
ml_dJointFeedbackSet (value j, value v)
{
  mlode_feedback *fd = (mlode_feedback*) Data_custom_val (v);
  if (fd->rc && (fd->rc->obj_state)
      && dJointGetFeedback (fd->id) == &(fd->jf))
    dJointSetFeedback (fd->id, 0);
  if (fd->rc && --(fd->rc->ref_count) == 0) free (fd->rc);
  CustomJoint *cj = (CustomJoint *) Data_custom_val (j);
  fd->id = cj->id; fd->rc = cj->rc;
  (fd->rc->ref_count)++;
  dJointSetFeedback (fd->id, &(fd->jf));
  return Val_unit;
}

CAMLprim value
ml_dJointFeedbackReset (value v)
{
  mlode_feedback *fd = (mlode_feedback*) Data_custom_val (v);
  if (fd->rc && (fd->rc->obj_state)
      && &(fd->jf) == dJointGetFeedback (fd->id)) 
    dJointSetFeedback (fd->id, 0);
  if (fd->rc && --(fd->rc->ref_count) == 0) free (fd->rc);
  fd->rc = 0; fd->id = 0;
  return Val_unit;
}

CAMLprim value
ml_dJointFeedback_f1 (value v)
{
  mlode_feedback *fd = (mlode_feedback*) Data_custom_val (v);
  value r = Val_int(0); Val_Vector3 (r, (fd->jf).f1);
  return r;
}
CAMLprim value
ml_dJointFeedback_t1 (value v)
{
  mlode_feedback *fd = (mlode_feedback*) Data_custom_val (v);
  value r = Val_int(0); Val_Vector3 (r, (fd->jf).t1);
  return r;
}
CAMLprim value
ml_dJointFeedback_f2 (value v)
{
  mlode_feedback *fd = (mlode_feedback*) Data_custom_val (v);
  value r = Val_int(0); Val_Vector3 (r, (fd->jf).f2);
  return r;
}
CAMLprim value
ml_dJointFeedback_t2 (value v)
{
  mlode_feedback *fd = (mlode_feedback*) Data_custom_val (v);
  value r = Val_int(0); Val_Vector3 (r, (fd->jf).t2);
  return r;
}

/** Joints continued */

ML_2_ (dAreConnected, BodyID, BodyID, Integer);
ML_3_ (dAreConnectedExcluding, BodyID, BodyID, Integer, Integer);

ML_4 (dJointSetBallAnchor, JointID, Real, Real, Real);
ML_1_1 (dJointGetBallAnchor, JointID, Vector3);
ML_1_1 (dJointGetBallAnchor2, JointID, Vector3);

ML_4 (dJointSetHingeAnchor, JointID, Real, Real, Real);
ML_4u (dJointSetHingeAxis, JointID, Real_OPT, Real_OPT, Real_OPT);
ML_1_1s (dJointGetHingeAnchor, JointID, Vector3);
ML_1_1s (dJointGetHingeAnchor2, JointID, Vector3);
ML_1_1s (dJointGetHingeAxis, JointID, Vector3);
ML_1_ (dJointGetHingeAngle, JointID, Real);
ML_1_ (dJointGetHingeAngleRate, JointID, Real);

ML_4u (dJointSetSliderAxis, JointID, Real_OPT, Real_OPT, Real_OPT);
ML_1_1s (dJointGetSliderAxis, JointID, Vector3);
ML_1_ (dJointGetSliderPosition, JointID, Real);
ML_1_ (dJointGetSliderPositionRate, JointID, Real);

ML_4 (dJointSetUniversalAnchor, JointID, Real, Real, Real);
ML_4u (dJointSetUniversalAxis1, JointID, Real_OPT, Real_OPT, Real_OPT);
ML_4u (dJointSetUniversalAxis2, JointID, Real_OPT, Real_OPT, Real_OPT);
ML_1_1s (dJointGetUniversalAnchor, JointID, Vector3);
ML_1_1s (dJointGetUniversalAnchor2, JointID, Vector3);
ML_1_1s (dJointGetUniversalAxis1, JointID, Vector3);
ML_1_1s (dJointGetUniversalAxis2, JointID, Vector3);
ML_1_ (dJointGetUniversalAngle1, JointID, Real);
ML_1_ (dJointGetUniversalAngle2, JointID, Real);
ML_1_ (dJointGetUniversalAngle1Rate, JointID, Real);
ML_1_ (dJointGetUniversalAngle2Rate, JointID, Real);

ML_4 (dJointSetHinge2Anchor, JointID, Real, Real, Real);
ML_4u (dJointSetHinge2Axis1, JointID, Real_OPT, Real_OPT, Real_OPT);
ML_4u (dJointSetHinge2Axis2, JointID, Real_OPT, Real_OPT, Real_OPT);
ML_1_1s (dJointGetHinge2Anchor, JointID, Vector3);
ML_1_1s (dJointGetHinge2Anchor2, JointID, Vector3);
ML_1_1s (dJointGetHinge2Axis1, JointID, Vector3);
ML_1_1s (dJointGetHinge2Axis2, JointID, Vector3);
ML_1_ (dJointGetHinge2Angle1, JointID, Real);
ML_1_ (dJointGetHinge2Angle1Rate, JointID, Real);
ML_1_ (dJointGetHinge2Angle2Rate, JointID, Real);

ML_1 (dJointSetFixed, JointID);

ML_2 (dJointSetAMotorMode, JointID, Integer);
ML_1_ (dJointGetAMotorMode, JointID, Integer);
ML_2 (dJointSetAMotorNumAxes, JointID, Integer);
ML_1_ (dJointGetAMotorNumAxes, JointID, Integer);
ML_6 (dJointSetAMotorAxis, JointID, Integer, Integer, Real, Real, Real);
ML_bc6 (ml_dJointSetAMotorAxis);
ML_2_1s (dJointGetAMotorAxis, JointID, Integer, Vector3);
ML_2_ (dJointGetAMotorAxisRel, JointID, Integer, Integer);

ML_3 (dJointSetAMotorAngle, JointID, Integer, Real);
ML_2_ (dJointGetAMotorAngle, JointID, Integer, Real);
ML_2_ (dJointGetAMotorAngleRate, JointID, Integer, Real);

#define ML_JointSetParam(x) CAMLprim value \
ml_dJointSet##x##Param (value j, value a, value p, value v) \
{ \
  int m = (Int_val(a) == 0) ? 0 : Int_val(Field(a,0)); \
  dJointSet##x##Param (JointID_val (j), \
    Int_val(p) + m * dParamGroup, Real_val(v)); \
  return Val_unit; \
}
ML_JointSetParam(Hinge);
ML_JointSetParam(Slider);
ML_JointSetParam(Hinge2);
ML_JointSetParam(Universal);
ML_JointSetParam(AMotor);

#define ML_JointGetParam(x) CAMLprim value \
ml_dJointGet##x##Param (value j, value a, value p) \
{ \
  int m = (Int_val(a) == 0) ? 0 : Int_val(Field(a,0)); \
  double r = dJointGet##x##Param (JointID_val (j), \
    Int_val(p) + m * dParamGroup); \
  return caml_copy_double (r); \
}
ML_JointGetParam(Hinge);
ML_JointGetParam(Slider);
ML_JointGetParam(Hinge2);
ML_JointGetParam(Universal);
ML_JointGetParam(AMotor);

ML_2 (dJointAddHingeTorque, JointID, Real);
ML_3 (dJointAddUniversalTorques, JointID, Real, Real);
ML_2 (dJointAddSliderForce, JointID, Real);
ML_3 (dJointAddHinge2Torques, JointID, Real, Real);
ML_4 (dJointAddAMotorTorques, JointID, Real, Real, Real);


/** StepFast */

ML_3 (dWorldStepFast1, WorldID, Real, Integer);
ML_2 (dWorldSetAutoEnableDepthSF1, WorldID, Integer);
ML_1_ (dWorldGetAutoEnableDepthSF1, WorldID, Integer);
/* Supported only by contrib/BreakableJoints 
ML_2 (dBodySetAutoDisableThresholdSF1, BodyID, Real);
ML_1_ (dBodyGetAutoDisableThresholdSF1, BodyID, Real);

ML_2 (dBodySetAutoDisableStepsSF1, BodyID, Integer);
ML_1_ (dBodyGetAutoDisableStepsSF1, BodyID, Integer);

ML_2 (dBodySetAutoDisableSF1, BodyID, Integer);
ML_1_ (dBodyGetAutoDisableSF1, BodyID, Integer);
*/

     /** Masses */

/** Simply a wrapper for dMass struct. */

static struct custom_operations custom_mass = {
  identifier: "ocamlode_mass",
  finalize: NULL,
  compare: custom_compare_default,
  hash: custom_hash_default,
  serialize: custom_serialize_default,
  deserialize: custom_deserialize_default
};


#define Mass_prepare(v)
#define Mass_prepare_copy(v) dMass v##_C = *Mass_val(v);
#define Mass_val_copy(v) &v##_C
#define Mass_val(massv) ((dMass *) Data_custom_val (massv))

ML_2 (dBodySetMass, BodyID, Mass);

CAMLprim value
ml_dBodyGetMass (value b) {
  CAMLparam1 (b);
  CAMLlocal1 (massv);
  massv = caml_alloc_custom (&custom_mass, sizeof (dMass), 0, 1);
  dBodyGetMass (BodyID_val (b), Mass_val (massv));
  CAMLreturn (massv);
}

CAMLprim value
ml_dCreateMass (value arg1, value arg2,
                     value arg3, value arg4, value arg5, value arg6,
		 value arg7, value arg8, value arg9, value arg10)
{
  CAMLparam5 (arg1, arg2, arg3, arg4, arg5);
  CAMLxparam5 (arg6, arg7, arg8, arg9, arg10);
  CAMLlocal1 (massv);
  massv = caml_alloc_custom (&custom_mass, sizeof (dMass), 0, 1);
   
  dMassSetParameters (Mass_val (massv), Real_val(arg1), Real_val(arg2),
		      Real_val(arg3), Real_val(arg4), Real_val(arg5),
		      Real_val(arg6), Real_val(arg7), Real_val (arg8),
		      Real_val (arg9), Real_val (arg10));
  CAMLreturn (massv); }
ML_bc10 (ml_dCreateMass);
  
#define ML_Mass_2(cname, typ1, typ2) CAMLprim value \
ml_create_##cname (value arg1, value arg2) { \
  CAMLparam2 (arg1, arg2); \
  CAMLlocal1 (massv); \
  massv = caml_alloc_custom (&custom_mass, sizeof (dMass), 0, 1); \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  cname (Mass_val (massv), typ1##_val (arg1), typ2##_val (arg2)); \
  CAMLreturn (massv); \
}
#define ML_Mass_4(cname, typ1, typ2, typ3, typ4) CAMLprim value \
ml_create_##cname (value arg1, value arg2, value arg3, value arg4) { \
  CAMLparam4 (arg1, arg2, arg3, arg4); \
  CAMLlocal1 (massv); \
  massv = caml_alloc_custom (&custom_mass, sizeof (dMass), 0, 1); \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  typ3##_prepare(arg3) typ4##_prepare(arg4) \
  cname (Mass_val (massv), typ1##_val (arg1), typ2##_val (arg2), \
    typ3##_val (arg3), typ4##_val (arg4)); \
  CAMLreturn (massv); \
}

ML_1 (dMassSetZero, Mass);

CAMLprim value ml_dMassSetParameters (value arg1, value arg2, value arg3,
                     value arg4, value arg5, value arg6, value arg7,
		 value arg8, value arg9, value arg10, value arg11)
{
    dMassSetParameters (Mass_val (arg1), Real_val(arg2), Real_val(arg3),
		      Real_val(arg4), Real_val(arg5), Real_val(arg6),
		      Real_val(arg7), Real_val(arg8), Real_val (arg9),
		      Real_val (arg10), Real_val (arg11));
  return Val_unit;
}

ML_bc11 (ml_dMassSetParameters);

ML_3 (dMassSetSphere, Mass, Real, Real);
ML_Mass_2 (dMassSetSphere, Real, Real);
ML_3 (dMassSetSphereTotal, Mass, Real, Real);
ML_Mass_2 (dMassSetSphereTotal, Real, Real);

ML_5 (dMassSetCappedCylinder, Mass, Real, IncrInt, Real, Real);
ML_Mass_4 (dMassSetCappedCylinder, Real, IncrInt, Real, Real);
ML_5 (dMassSetCappedCylinderTotal, Mass, Real, IncrInt, Real, Real);
ML_Mass_4 (dMassSetCappedCylinderTotal, Real, IncrInt, Real, Real);
ML_5 (dMassSetCylinder, Mass, Real, IncrInt, Real, Real);
ML_Mass_4 (dMassSetCylinder, Real, IncrInt, Real, Real);
ML_5 (dMassSetCylinderTotal, Mass, Real, IncrInt, Real, Real);
ML_Mass_4 (dMassSetCylinderTotal, Real, IncrInt, Real, Real);
ML_5 (dMassSetBox, Mass, Real, Real, Real, Real);
ML_Mass_4 (dMassSetBox, Real, Real, Real, Real);
ML_5 (dMassSetBoxTotal, Mass, Real, Real, Real, Real);
ML_Mass_4 (dMassSetBoxTotal, Real, Real, Real, Real);
ML_2 (dMassAdjust, Mass, Real);
ML_4 (dMassTranslate, Mass, Real, Real, Real);
ML_2 (dMassRotate, Mass, Matrix3);
ML_2 (dMassAdd, Mass, Mass);

CAMLprim value
ml_dMass_mass (value m) {
  return caml_copy_double ((Mass_val (m))->mass);
}
CAMLprim value
ml_dMass_cog (value m) {
  CAMLparam1 (m);
  CAMLlocal1 (r); 
  r = caml_alloc (4 * Double_wosize, Double_array_tag); 
  Val_Vector3 (r, Mass_val(m)->c); 
  CAMLreturn (r); }

CAMLprim value
ml_dMass_I (value m) {
  CAMLparam1 (m);
  CAMLlocal1 (r); 
  r = caml_alloc (4 * 3 * Double_wosize, Double_array_tag); 
  Val_Matrix3 (r, Mass_val(m)->I); 
  CAMLreturn (r); }


     /** Contacts */

/** A wrapper for dContact struct with initialization support. */

typedef dContact *dContactID;

typedef struct valContact {
  dContact contact;
#ifdef ML_DEBUG
  int initialized;
#endif
} valContact;

static struct custom_operations custom_contact = {
  identifier: "ocamlode_contact",
  finalize: NULL,
  compare: custom_compare_default,
  hash: custom_hash_default,
  serialize: custom_serialize_default,
  deserialize: custom_deserialize_default
};

CAMLprim value
ml_dContactCreate (value mu)
{
  CAMLparam1 (mu);
  CAMLlocal1 (contactv);
  contactv = caml_alloc_custom
    (&custom_contact, sizeof (valContact), 0, 1);
  valContact *ct = (valContact*) (Data_custom_val (contactv));
  (ct->contact).surface.mode = 0;
  (ct->contact).surface.mu = Real_val(mu);
#ifdef ML_DEBUG
  ct->initialized = 0;
#endif
  CAMLreturn (contactv);
}

#define ContactID_prepare(v)
static inline dContact *
ContactID_val (value contactv)
{
  valContact *cp = (valContact *) Data_custom_val (contactv);
#ifdef ML_DEBUG
  if (cp->initialized == 0) caml_failwith ("Accessing uninitialized contact");
#endif
  return &(cp->contact);
}

static struct custom_operations custom_contactGeomArray = {
  identifier: "ocamlode_contactGeomArray",
  finalize: NULL,
  compare: custom_compare_default,
  hash: custom_hash_default,
  serialize: custom_serialize_default,
  deserialize: custom_deserialize_default
};

CAMLprim value
ml_dContactGeomArray_size (value v)
{
  return Val_int (*((int*)Data_custom_val (v)));
}

CAMLprim value
ml_dContactGeomArray_is_empty (value v)
{
  return Val_int (!(*((int*)Data_custom_val (v))));
}

ML_3_ (dJointCreateContact, WorldID, JointGroupID_OPT, ContactID, JointID);

CAMLprim value ml_dResetSurfaceMode (value cont)
{
  valContact *ct = (valContact*) Data_custom_val (cont);
  (ct->contact).surface.mode = 0;
  return Val_unit;  
}

#define ML_SetSurfaceParameter(m,x) CAMLprim value \
  ml_dSetSurfaceParameter_##x (value cont, \
      value arg) \
{ \
  dContact *cp = &(((valContact*) Data_custom_val (cont))->contact); \
  (cp->surface).mode |= dContact##m; \
  (cp->surface).x = Real_val (arg); \
  return Val_unit; }

CAMLprim value
ml_dSetSurfaceParameter_mu (value cont, value arg)
{
  dContact *cp = &(((valContact*) Data_custom_val (cont))->contact);
  (cp->surface).mu = Real_val (arg);
  return Val_unit;
}

ML_SetSurfaceParameter (Mu2, mu2);
ML_SetSurfaceParameter (Bounce, bounce);
ML_SetSurfaceParameter (Bounce, bounce_vel);
ML_SetSurfaceParameter (SoftERP, soft_erp);
ML_SetSurfaceParameter (SoftCFM, soft_cfm);
ML_SetSurfaceParameter (Motion1, motion1);
ML_SetSurfaceParameter (Motion2, motion2);
ML_SetSurfaceParameter (Slip1, slip1);
ML_SetSurfaceParameter (Slip2, slip2);

#define ML_SetSurfaceModeParam(m) CAMLprim value \
  ml_dSetSurfaceModeParam_##m (value cont) \
{ \
  dContact *cp = &(((valContact*) Data_custom_val (cont))->contact); \
  (cp->surface).mode |= dContact##m; \
  return Val_unit; }

ML_SetSurfaceModeParam (Approx1_1);
ML_SetSurfaceModeParam (Approx1_2);
ML_SetSurfaceModeParam (Approx1);

CAMLprim value ml_dSetSurfaceParameter_fdir1 (value cont, value d)
{
  valContact *ct = (valContact*) Data_custom_val (cont);
#ifdef ML_DEBUG
  ct->initialized |= 4;
#endif
  Vector3_prepare(d)
  memcpy(&((ct->contact).fdir1), Vector3_val (d), sizeof (dVector3));
  (ct->contact).surface.mode |= dContactFDir1;
  return Val_unit;
}
  

CAMLprim value
ml_dSetContactGeomFromArray (value cont, value cGeomArray, value iv)
{
  int i = Int_val (iv);
#ifdef ML_DEBUG
  if (i < 0 || i >= *((int*) Data_custom_val (cGeomArray)))
    caml_invalid_argument ("Index exceeds contact_geom_array range");
  ((valContact*) Data_custom_val (cont))->initialized = 1;
#endif
  dContact *cp = ContactID_val (cont);
  int size = sizeof (dContactGeom);
  memcpy (&(cp->geom), Data_custom_val (cGeomArray)+sizeof (int)
	  + i*size, size);
  return Val_unit;
}

CAMLprim value
ml_dContactArrayAppend (value arr1, value arr2)
{
  CAMLparam2 (arr1, arr2);
  CAMLlocal1 (rv);
  int n1 = *((int*) Data_custom_val (arr1));
  int n2 = *((int*) Data_custom_val (arr2));
  int siz1 = n1 * sizeof (dContactGeom);
  int siz2 = n2 * sizeof (dContactGeom);
  rv = caml_alloc_custom (&custom_contactGeomArray,
				    siz1 + siz2+sizeof (int), 0, 1);
  *((int*)Data_custom_val (rv)) = n1+n2;
  if (siz1) memcpy (Data_custom_val (rv)+sizeof (int),
		     Data_custom_val (arr1)+sizeof (int), siz1);
  if (siz2) memcpy (Data_custom_val (rv)+siz1+sizeof (int),
		     Data_custom_val (arr2)+sizeof (int)+siz1, siz2);  
  CAMLreturn (rv);
}


/** Collision detection: geoms */

/** Geoms are destroyed at finalization of their last reference if
    they are not contained in any space. */

typedef struct CustomGeom {
  dGeomID id;
  RefCount *rc;
} CustomGeom;

static inline dGeomID
GeomID_val (value v)
{
  CustomGeom *j = (CustomGeom *) (Data_custom_val (v));  
#ifdef ML_DEBUG
  if (!(j->rc->obj_state))
    caml_failwith ("Accessing destroyed geom");
#endif
  return j->id;
}
#define GeomID_prepare(v)
void finalize_geom (value v)
{
  CustomGeom *b = ((CustomGeom *) Data_custom_val(v));
  if (--(b->rc->ref_count) == 0) free (b->rc);
  //if ref_count==0, already destroyed
  else if ((b->rc->obj_state)
	   && b->rc->ref_count == 1 && dGeomGetSpace(b->id)==0)
	/* hasn't been destroyed by the space */
    dGeomDestroy (b->id);
}

int compare_geoms (value v1, value v2)
{
  CAMLparam2 (v1, v2);
  CAMLreturn ((long) (*((dGeomID*)(Data_custom_val(v1))))
	       - (long) (*((dGeomID*)(Data_custom_val(v2)))));
}

static long
hash_geom (value v)
{
  CAMLparam1 (v);
  CAMLreturn (*((long*) (Data_custom_val(v))));
}

static struct custom_operations custom_geom = {
  identifier: "ocamlode_geom",
  finalize: finalize_geom,
  compare: compare_geoms,
  hash: hash_geom,
  serialize: custom_serialize_default,
  deserialize: custom_deserialize_default
};

#define Val_GeomID(rv,v) \
  rv = caml_alloc_custom (&custom_geom, sizeof (CustomGeom), 0, 1); \
  CustomGeom *b = ((CustomGeom *) Data_custom_val (rv)); \
  b->id = v; b->rc = RefCountCreate_geom (v);

#define Val_GeomID_OPT(rv,v) Val_OPTION(GeomID,rv,v)
#define dGeomID_OPT dGeomID
#define GeomID_prepare_copy(v) dGeomID v##_C = GeomID_val(v);
#define GeomID_val_copy(v) v##_C

CAMLprim value
ml_dGeom_eq (value g1, value g2)
{
  return Val_bool ((*((dGeomID*)(Data_custom_val(g1))))
		   == (*((dGeomID*)(Data_custom_val(g2)))));
}

CAMLprim value
ml_dGeom_compare (value g1, value g2)
{
  return Val_int ((long) (*((dGeomID*)(Data_custom_val(g1))))
		   - (long) (*((dGeomID*)(Data_custom_val(g2)))));
}

ML_1 (dGeomDestroy, GeomID);

ML_2 (dGeomSetBody, GeomID, BodyID_OPT);
ML_1_ (dGeomGetBody, GeomID, BodyID_OPT);

ML_4 (dGeomSetPosition, GeomID, Real, Real, Real);
ML_2 (dGeomSetRotation, GeomID, Matrix3);
ML_2 (dGeomSetQuaternion, GeomID, Quaternion);
ML_1_r (dGeomGetPosition, GeomID, Vector3);
ML_1_r (dGeomGetRotation, GeomID, Matrix3);
ML_1_1s (dGeomGetQuaternion, GeomID, Quaternion);
ML_1_1s (dGeomGetAABB, GeomID, AABB);
ML_1_ (dGeomIsSpace, GeomID, Integer);



/** Spaces are represented as geoms,
    enough that size(dGeomID)= size(dSpaceID) */

#define SpaceID_val(v) ((dSpaceID)(GeomID_val(v)))
#define Val_SpaceID(rv,v) Val_GeomID(rv,((dGeomID)v))
#define Val_SpaceID_OPT(rv,v) Val_OPTION(SpaceID,rv,v)
#define dSpaceID_OPT dSpaceID

ML_1_ (dGeomGetSpace, GeomID, SpaceID_OPT);
ML_1_ (dGeomGetClass, GeomID, Integer);
ML_2 (dGeomSetCategoryBits, GeomID, NativeInt);
ML_2 (dGeomSetCollideBits, GeomID, NativeInt);
ML_1_ (dGeomGetCategoryBits, GeomID, NativeInt);
ML_1_ (dGeomGetCollideBits, GeomID, NativeInt);
ML_1 (dGeomEnable, GeomID);
ML_1 (dGeomDisable, GeomID);
ML_1_ (dGeomIsEnabled, GeomID, Integer);


CAMLprim value
ml_dCollide (value geom1v, value geom2v, value maxv)
{
  CAMLparam3 (geom1v, geom2v, maxv);
  CAMLlocal2 (rv, r);
  dGeomID geom1 = GeomID_val (geom1v);
  dGeomID geom2 = GeomID_val (geom2v);
  int max = Int_val (maxv);
  unsigned flags = ((unsigned) max) & 0xffff;
  int maxsize = max * sizeof (dContactGeom);
  dContactGeom *contacts = malloc (maxsize);
  int n = dCollide (geom1, geom2, flags, contacts, sizeof (dContactGeom));
  if (n > 0) {
    int size = n * sizeof (dContactGeom);
    rv = caml_alloc_custom (&custom_contactGeomArray,
			    size+sizeof (int), 0, 1);
    *((int*)Data_custom_val (rv)) = n;
    if (size) memcpy (Data_custom_val (rv)+sizeof (int), contacts, size);
    r = caml_alloc (1, 0);
    Store_field (r, 0, rv);
  }
  else r = Val_int (0);
  free (contacts);
  CAMLreturn (r);
}

CAMLprim value
ml_dCollideAppend (value geom1v, value geom2v, value maxv,
			 value arr)
{
  CAMLparam4 (geom1v, geom2v, maxv, arr);
  CAMLlocal1 (rv);
  dGeomID geom1 = GeomID_val (geom1v);
  dGeomID geom2 = GeomID_val (geom2v);
  int max = Int_val (maxv);
  unsigned flags = ((unsigned) max) & 0xffff;
  int maxsize = max * sizeof (dContactGeom);
  dContactGeom *contacts = malloc (maxsize);
  int n = dCollide (geom1, geom2, flags, contacts, sizeof (dContactGeom));
  int oldn = (*(int*)Data_custom_val (arr));
  int oldsize = oldn * sizeof (dContactGeom);
  if (n) {
    int newsize =  n * sizeof (dContactGeom);
    int size = oldsize + newsize;
    rv = caml_alloc_custom (&custom_contactGeomArray,
			    size+sizeof (int), 0, 1);
    *((int*)Data_custom_val (rv)) = oldn + n;
    if (size)
      memcpy (Data_custom_val (rv)+sizeof (int)+oldsize,
	      contacts, newsize);
  } else rv = arr;
  free (contacts);
  CAMLreturn (rv);
}

static void
dSpaceCollide_callback (void *fvpv, dGeomID geom1, dGeomID geom2)
{
  CAMLparam0 ();
  CAMLlocal5 (geom1v, geom2v, rv, rv1, res);
  value *fvp = (value *) fvpv;
  assert (geom1 != geom2);
  {Val_GeomID (rv1, geom1);}
  {Val_GeomID (rv, geom2);}
  res = caml_callback2_exn (*fvp, rv1, rv);
  if (Is_exception_result (res))
    // XXX Can we do better than this?
    fprintf (stderr, "dSpaceCollide: callback raised exception: %s\n",
	     caml_format_exception (Extract_exception (res)));
  CAMLreturn0;
}

CAMLprim value
ml_dSpaceCollide (value idv, value fv)
{
  CAMLparam2 (idv, fv);
  value *fvp = &fv;
  dSpaceID id = SpaceID_val (idv);
  dSpaceCollide (id, fvp, dSpaceCollide_callback);
  CAMLreturn (Val_unit);
}
CAMLprim value
ml_dSpaceCollide2 (value o1, value o2, value fv)
{
  CAMLparam3 (o1, o2, fv);
  value *fvp = &fv;
  dSpaceCollide2 (GeomID_val(o1), GeomID_val(o2), fvp, dSpaceCollide_callback);
  CAMLreturn (Val_unit);
}

#define SpaceID_OPT_prepare(v) 
#define SpaceID_OPT_val(v)  ((dSpaceID) (((Int_val(v) == 0) ? 0 : \
		       SpaceID_val(Field ((v), 0)))))
ML_1u_ (dSimpleSpaceCreate, SpaceID_OPT, SpaceID);
ML_1u_ (dHashSpaceCreate, SpaceID_OPT, SpaceID);
ML_4u_ (dQuadTreeSpaceCreate, SpaceID_OPT, Vector3, Vector3, Integer, \
	   SpaceID);

#define SpaceID_prepare(v)
ML_1 (dSpaceDestroy, SpaceID);


ML_3 (dHashSpaceSetLevels, SpaceID, Integer, Integer);
ML_1_2 (dHashSpaceGetLevels, SpaceID, Integer, Integer);
ML_2 (dSpaceSetCleanup, SpaceID, Integer);
ML_1_ (dSpaceGetCleanup, SpaceID, Integer);
ML_2 (dSpaceAdd, SpaceID, GeomID);
ML_2 (dSpaceRemove, SpaceID, GeomID);
ML_2_ (dSpaceQuery, SpaceID, GeomID, Integer);
ML_1_ (dSpaceGetNumGeoms, SpaceID, Integer);
ML_2_ (dSpaceGetGeom, SpaceID, Integer, GeomID);

ML_2u_ (dCreateSphere, SpaceID_OPT, Real, GeomID);

ML_2 (dGeomSphereSetRadius, GeomID, Real);
ML_1_ (dGeomSphereGetRadius, GeomID, Real);
ML_4_ (dGeomSpherePointDepth, GeomID, Real, Real, Real, Real);


ML_4u_ (dCreateBox, SpaceID_OPT, Real, Real, Real, GeomID);

ML_4 (dGeomBoxSetLengths, GeomID,  Real, Real, Real);
ML_1_1 (dGeomBoxGetLengths, GeomID, Vector3);
ML_4_ (dGeomBoxPointDepth, GeomID, Real, Real, Real, Real);

ML_5u_ (dCreatePlane, SpaceID_OPT, Real_OPT, Real_OPT, Real_OPT, \
	Real_OPT, GeomID);
ML_bc6 (ml_dCreatePlane);

ML_5 (dGeomPlaneSetParams, GeomID,  Real, Real, Real, Real);
ML_1_1s (dGeomPlaneGetParams, GeomID, Vector4);
ML_4_ (dGeomPlanePointDepth, GeomID, Real, Real, Real, Real);


ML_3u_ (dCreateCCylinder, SpaceID_OPT, Real, Real, GeomID);

ML_3 (dGeomCCylinderSetParams, GeomID,  Real, Real);
ML_1_2 (dGeomCCylinderGetParams, GeomID, Real, Real);
ML_4_ (dGeomCCylinderPointDepth, GeomID, Real, Real, Real, Real);

ML_2u_ (dCreateRay, SpaceID_OPT, Real, GeomID);

ML_2 (dGeomRaySetLength, GeomID, Real);
ML_1_ (dGeomRayGetLength, GeomID, Real);
ML_7 (dGeomRaySet, GeomID, Real, Real, Real, Real, Real, Real);
ML_bc7 (ml_dGeomRaySet);
ML_1_2 (dGeomRayGet, GeomID, Vector3, Vector3);

     /***********************************
TriMesh collisions omited for now
     ************************************/


     // GeomTransform

ML_1u_ (dCreateGeomTransform, SpaceID_OPT, GeomID);

CAMLprim value
ml_dGeomTransformSetGeom (value gv, value objv)
{
  dGeomID obj = GeomID_val (objv);
#ifdef ML_DEBUG
  if (dGeomGetSpace(obj) || dGeomGetBody (obj))
    caml_failwith ("Transformed object inside space or body");
#endif
  dGeomTransformSetGeom (GeomID_val (gv), obj);
  return Val_unit;
}
ML_1_ (dGeomTransformGetGeom, GeomID, GeomID);
ML_2 (dGeomTransformSetCleanup, GeomID, Integer);
ML_1_ (dGeomTransformGetCleanup, GeomID, Integer);
ML_2 (dGeomTransformSetInfo, GeomID, Integer);
ML_1_ (dGeomTransformGetInfo, GeomID, Integer);


     /***************************
User-defined collision classes are not supported yet.
     ***********************/

ML_4_2 (dClosestLineSegmentPoints, Vector3, Vector3, Vector3, Vector3, \
	   Vector3, Vector3);
ML_6_ (dBoxTouchesBox, Vector3, Matrix3, Vector3, Vector3, Matrix3, \
	  Vector3, Integer);
ML_bc6 (ml_dBoxTouchesBox);

ML_1_1 (dInfiniteAABB, GeomID, AABB);

/** Math functions: <rotation.h> */

ML_0_1 (dRSetIdentity, Matrix3);
ML_4u_b1 (dRFromAxisAndAngle, Real_OPT, Real_OPT, Real_OPT, Real, Matrix3);
ML_3_b1 (dRFromEulerAngles, Real, Real, Real, Matrix3);
ML_6u_b1 (dRFrom2Axes, Real_OPT, Real_OPT, Real_OPT, Real_OPT, Real_OPT, \
	 Real_OPT, Matrix3);
ML_bc7 (ml_dRFrom2Axes);
ML_3u_b1 (dRFromZAxis, Real_OPT, Real_OPT, Real_OPT, Real);
ML_0_1 (dQSetIdentity, Quaternion);
ML_4u_b1 (dQFromAxisAndAngle, Real_OPT, Real_OPT, Real_OPT, Real, Quaternion);
ML_2_b1 (dQMultiply0, Quaternion, Quaternion, Quaternion);
ML_2_b1 (dQMultiply1, Quaternion, Quaternion, Quaternion);
ML_2_b1 (dQMultiply2, Quaternion, Quaternion, Quaternion);
ML_2_b1 (dQMultiply3, Quaternion, Quaternion, Quaternion);
ML_1_b1 (dRfromQ, Matrix3, Quaternion);
ML_1_b1 (dQfromR, Quaternion, Matrix3);
ML_2_b1 (dDQfromW, Vector3, Quaternion, Vector4);

inline void dM3Multiply0 (dReal *A, const dReal *B, const dReal *C)
{
  dMultiply0 (A, B, C, 3, 3, 3);
}

inline void dM3Multiply1 (dReal *A, const dReal *B, const dReal *C)
{
  dMultiply1 (A, B, C, 3, 3, 3);
}

inline void dM3Multiply2 (dReal *A, const dReal *B, const dReal *C)
{
  dMultiply2 (A, B, C, 3, 3, 3);
}

ML_2_b1 (dM3Multiply0, Matrix3, Matrix3, Matrix3);
ML_2_b1 (dM3Multiply1, Matrix3, Matrix3, Matrix3);
ML_2_b1 (dM3Multiply2, Matrix3, Matrix3, Matrix3);
