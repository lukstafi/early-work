/* OCaml bindings for the Open Dynamics Engine (ODE) DrawStuff library.
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
#include <drawstuff/drawstuff.h>
#include <drawstuff/version.h>

#define MLODE_DEBUG

//debug test only:
//#define ARCH_ALIGN_DOUBLE

#include "yacintf.h"

// String_val is defined in <caml/mlvalues.h>

#define START_CALLBACK(N) static void \
dsFunctions_start_callback_##N () \
{ \
  if (!start_callback_value[N] || start_callback_value[N]==Val_int(0)) \
    return; \
  value res = caml_callback_exn (start_callback_value[N], Val_unit); \
  if (Is_exception_result (res)) \
    dsError ("dsFunctions_start: callback raised exception: %s", \
	     caml_format_exception (Extract_exception (res))); \
  return; \
}

#define STEP_CALLBACK(N) static void \
dsFunctions_step_callback_##N (int pause) \
{ \
  if (!step_callback_value[N] || step_callback_value[N]==Val_int(0)) \
    return; \
  CAMLparam0 (); \
  CAMLlocal2 (res,pv); \
  pv = Val_int(pause); \
  res = caml_callback_exn (step_callback_value[N], pv); \
  if (Is_exception_result (res)) \
    dsError ("dsFunctions_step: callback raised exception: %s", \
	     caml_format_exception (Extract_exception (res))); \
  CAMLreturn0; \
}

#define COMMAND_CALLBACK(N) static void \
dsFunctions_command_callback_##N (int cmd) \
{ \
  if (!command_callback_value[N] || command_callback_value[N]==Val_int(0)) \
    return; \
  CAMLparam0 (); \
  CAMLlocal2 (res,cmdv); \
  cmdv = Val_int(cmd); \
  res = caml_callback_exn (command_callback_value[N], cmdv); \
  if (Is_exception_result (res)) \
    dsError ("dsFunctions_command: callback raised exception: %s", \
	     caml_format_exception (Extract_exception (res))); \
  CAMLreturn0; \
}

#define STOP_CALLBACK(N) static void \
dsFunctions_stop_callback_##N () \
{ \
  if (!stop_callback_value[N] || stop_callback_value[N]==Val_int(0)) \
    return; \
  value res = caml_callback_exn (stop_callback_value[N], Val_unit); \
  if (Is_exception_result (res)) \
    dsError ("dsFunctions_stop: callback raised exception: %s", \
	     caml_format_exception (Extract_exception (res))); \
  start_callback_value[N] = 0; \
  step_callback_value[N] = 0; \
  command_callback_value[N] = 0; \
  stop_callback_value[N] = 0; \
  return; \
}

dsFunctions fn[8];
dsFunctions fn[8];
dsFunctions fn[8];
dsFunctions fn[8];
dsFunctions fn[8];

#define FILL_FN(N) \
  (fn[N]).start = dsFunctions_start_callback_##N; \
  (fn[N]).step = dsFunctions_step_callback_##N; \
  (fn[N]).command = dsFunctions_command_callback_##N; \
  (fn[N]).stop = dsFunctions_stop_callback_##N

#define CALLBACKS(N) \
 START_CALLBACK(N); \
 STEP_CALLBACK(N); \
 COMMAND_CALLBACK(N); \
 STOP_CALLBACK(N)


value start_callback_value[8] = {0,0,0,0,0,0,0,0};
value step_callback_value[8] = {0,0,0,0,0,0,0,0};
value command_callback_value[8] = {0,0,0,0,0,0,0,0};
value stop_callback_value[8] = {0,0,0,0,0,0,0,0};

CALLBACKS(0);
CALLBACKS(1);
CALLBACKS(2);
CALLBACKS(3);
CALLBACKS(4);
CALLBACKS(5);
CALLBACKS(6);
CALLBACKS(7);

CAMLprim value
ml_InitDrawstuff (value unit) {
  FILL_FN(0);
  FILL_FN(1);
  FILL_FN(2);
  FILL_FN(3);
  FILL_FN(4);
  FILL_FN(5);
  FILL_FN(6);
  FILL_FN(7);
  return Val_unit;
}

CAMLprim value
ml_dsSimulationLoop (value w, value h, value start, value step,
				 value command, value stop, value path,
				 value unit) {
  CAMLparam5 (w, h, start, step, command);
  CAMLxparam2 (stop, path);

  int i = 0;
  while (i < 8 && start_callback_value[i]) i++;
  if (i >= 8)
    caml_failwith ("dsSimulationLoop: Too many simultaneous simulations.");
  start_callback_value[i] = OPTION_val(start);
  step_callback_value[i] = OPTION_val(step);
  command_callback_value[i] = OPTION_val(command);
  stop_callback_value[i] = OPTION_val(stop);
  fn[i].path_to_textures = String_val (OPTION_val(path));
  fn[i].version = DS_VERSION;
  dsSimulationLoop (0, NULL, Int_val (w), Int_val (h), &(fn[i]));
  CAMLreturn (Val_unit);
}

ML_bc8 (ml_dsSimulationLoop);

ML_1 (dsError, String);
ML_1 (dsDebug, String);
ML_1 (dsPrint, String);

ML_2 (dsSetViewpoint, Vector3F, Vector3F);
ML_0_2 (dsGetViewpoint, Vector3F, Vector3F);
ML_0 (dsStop);
ML_1 (dsSetTexture, Integer);
ML_3 (dsSetColor, Real, Real, Real);
ML_4 (dsSetColorAlpha, Real, Real, Real, Real);

ML_3 (dsDrawBoxD, Vector3, Matrix3, Vector3);
ML_3 (dsDrawSphereD, Vector3, Matrix3, Real);

/*******************************
 * Trimeshes not supported yet
ML_6 (dsDrawTriangleD, Vector3, Matrix3,);
*******************************/

ML_4 (dsDrawCylinderD, Vector3, Matrix3, Real, Real);
ML_4 (dsDrawCappedCylinderD, Vector3, Matrix3, Real, Real);
ML_2 (dsDrawLineD, Vector3, Vector3);

ML_1 (dsSetSphereQuality, Integer);
ML_1 (dsSetCappedCylinderQuality, Integer);
