/** Yet Another C to OCaml INTerFace headers
    Copyright Lukasz Stafiniak 2005 */

#ifndef YACINTF
#define YACINTF

/** Types have the following conversion macros:

    ##_prepare(v) - if needed, define the C equivalent ##v##_C and
      copy v into it;

    ##_val(v) - get the C value (directly from Caml value) or pass the C
    equivalent ##v##_C

    ##_prepare_copy(v) - define the C equivalent ##v##_C and
      copy v into it;

    ##_val_copy(v) - get the C value: pass the C equivalent ##v##_C

    Val_##(rv,v) - allocate the Caml value into rv and copy v into it

    ##_byptr_prepare(v) - if needed, define the C equivalent ##v##_C
    to store the result, otherwise, allocate the Caml block

    ##_byptr(v) - get the pointer to the place to store the result
    (either directly in the Caml block or pass the ##v##_C)

    ##_byptr_store(v) - if needed, allocate the Caml value and copy
      from the C value into it

    Val_##_fromptr(rv,v) - as Val_## for values returned by pointer

    d##_ptr - pointer to type ##

    ##_ptrof(v) - address of the C value v

    The ODE type argument given (represented above by ##) must be the
    ODE type without the prefixing d. The types implemented are:
    integer, IncrInt (only IncrInt_val, converted to int + 1),
    nativeint (that is, long), Real, Vector3, Vector4, Matrix3,
    Quaternion, AABB (that is, dReal[6]), WorldID, BodyID, JointID,
    JointGroupID, Mass, Contact (only Contact_val), GeomID, SpaceID
    (implemented as GeomID).
*/

typedef int dInteger;
typedef long dNativeInt;
//typedef int dIncrInt;
typedef dReal dAABB[6];

#define OPTION_val(v) (Int_val(v)==0 ? 0 : Field (v,0))

#define Integer_val(v)  (Int_val (v))
#define Integer_val_copy(v) v##_C
#define IncrInt_val(v)  (Int_val (v)+1)
#define IncrInt_prepare(v)
#define Val_Integer(rv,v) rv = Val_int (v);
#define Integer_prepare(v)
#define Integer_prepare_copy(v) int v##_C = Int_val(v);
#define Integer_byptr_prepare(v) int v##_C;
#define Integer_byptr(v) (&v##_C)
#define Integer_byptr_store(v) v = Val_int(v##_C);
#define Val_Integer_fromptr(rv,v) Val_Integer(rv,*v)
#define dInteger_ptr int *
#define Integer_ptrof(v) (&v)

#define Real_val(v)  ((dReal) Double_val (v))
#define NativeInt_val(v)  (*(long*) Data_custom_val (v))
#define Real_OPT_val(v)  ((dReal) (((Int_val(v) == 0) ? 0. : \
		       Double_val(Field ((v), 0)))))
#define NativeInt_OPT_val(v)  ((Int_val(v) == 0) ? 0 : \
		       *(long*) Data_custom_val(Field ((v), 0)))
#define Val_Real(rv,v) rv = caml_copy_double (v);
#define Val_NativeInt(rv,v) rv = caml_copy_nativeint (v);
#define Val_Real_fromptr(rv,v) Val_Real(rv,*v)
#define Val_NativeInt_fromptr(rv,v) Val_NativeInt(rv,*v)
#define Real_prepare(v)
#define Real_OPT_prepare(v)
#define dReal_ptr dReal *
#define Real_ptrof(v) (&v)
#define NativeInt_prepare(v)
#define NativeInt_OPT_prepare(v)
#define dNativeInt_ptr long *
#define NativeInt_ptrof(v) (&v)

#define String_prepare(v)

/** If I am sure, that OCaml implements float records and arrays as C
    double arrays, then use them directly, */
#ifndef ARCH_ALIGN_DOUBLE

#define Vector3_val(v) ( ((double *) (v)))
#define Vector4_val(v) ( ((double *) (v)))
#define Matrix3_val(v) ( ((double *) (v)))
#define Quaternion_val(v) ( ((double *) (v)))
#define AABB_val(v) ( ((double *) (v)))

/* what to do to ignore ; ? */
#define Vector3_prepare(v) 	
#define Vector4_prepare(v)
#define Matrix3_prepare(v)
#define Quaternion_prepare(v)
#define AABB_prepare(v)

/* rv must have been registered;
   what is faster: memcpy or unfolded assignment? */
#define Val_Vector3(rv,v) \
  rv = caml_alloc (4 * Double_wosize, Double_array_tag); \
  memcpy ((double*)rv, v, 3 * sizeof(double)); \
  Store_double_field(rv, 3, 0.0);
#define Val_Vector4(rv,v) \
  rv = caml_alloc (4 * Double_wosize, Double_array_tag); \
  memcpy ((double*)rv, v, 4 * sizeof(double));
#define Val_Matrix3(rv,v) \
  rv = caml_alloc (12 * Double_wosize, Double_array_tag); \
  memcpy ((double*)rv, v, 12 * sizeof(double));
#define Val_Quaternion(rv,v) \
  rv = caml_alloc (4 * Double_wosize, Double_array_tag); \
  memcpy ((double*)rv, v, 4 * sizeof(double));
#define Val_AABB(rv,v) \
  rv = caml_alloc (6 * Double_wosize, Double_array_tag); \
  memcpy ((double*)rv, v, 6 * sizeof(double));

#define Real_byptr_prepare(v) v = caml_copy_double(0.0);
#define Vector3_byptr_prepare(v) \
  v = caml_alloc (4 * Double_wosize, Double_array_tag);
#define Vector4_byptr_prepare(v) \
  v = caml_alloc (4 * Double_wosize, Double_array_tag);
#define Matrix3_byptr_prepare(v) \
  v = caml_alloc (12 * Double_wosize, Double_array_tag);
#define Quaternion_byptr_prepare(v) \
  v = caml_alloc (4 * Double_wosize, Double_array_tag);
#define AABB_byptr_prepare(v) \
  v = caml_alloc (6 * Double_wosize, Double_array_tag);

#define Real_byptr(v) ((double *) (v))
#define Vector3_byptr(v) ( ((double *) (v)))
#define Vector4_byptr(v) ( ((double *) (v)))
#define Matrix3_byptr(v) ( ((double *) (v)))
#define Quaternion_byptr(v) ( ((double *) (v)))
#define AABB_byptr(v) ( ((double *) (v)))

#define Real_byptr_store(v)
#define Vector3_byptr_store(v) 	
#define Vector4_byptr_store(v)
#define Matrix3_byptr_store(v)
#define Quaternion_byptr_store(v)
#define AABB_byptr_store(v)

#else

#define Vector3_val(v) v##_C
#define Vector4_val(v) v##_C
#define Matrix3_val(v) v##_C
#define Quaternion_val(v) v##_C
#define AABB_val(v) v##_C

#define Vector3_prepare(v) double v##_C[4]; \
  v##_C[0] = Double_field(v,0); \
  v##_C[1] = Double_field(v,1); \
  v##_C[2] = Double_field(v,2); \
  v##_C[3] = 0.0;
#define Vector4_prepare(v) double v##_C[4]; \
  v##_C[0] = Double_field(v,0); \
  v##_C[1] = Double_field(v,1); \
  v##_C[2] = Double_field(v,2); \
  v##_C[3] = Double_field(v,3);
#define Matrix3_prepare(v) double v##_C[12]; \
  v##_C[0] = Double_field(v,0); \
  v##_C[1] = Double_field(v,1); \
  v##_C[2] = Double_field(v,2); \
  v##_C[3] = Double_field(v,3); \
  v##_C[4] = Double_field(v,4); \
  v##_C[5] = Double_field(v,5); \
  v##_C[6] = Double_field(v,6); \
  v##_C[7] = Double_field(v,7); \
  v##_C[8] = Double_field(v,8); \
  v##_C[9] = Double_field(v,9); \
  v##_C[10] = Double_field(v,10); \
  v##_C[11] = Double_field(v,11);
#define Quaternion_prepare(v) Vector4_prepare(v)
#define AABB_prepare(v) double v##_C[6]; \
  v##_C[0] = Double_field(v,0); \
  v##_C[1] = Double_field(v,1); \
  v##_C[2] = Double_field(v,2); \
  v##_C[3] = Double_field(v,3); \
  v##_C[4] = Double_field(v,4); \
  v##_C[5] = Double_field(v,5);

/* rv must have been registered;
   what is faster: memcpy or unfolded assignment? */
#define Val_Vector3(rv,v) \
  rv = caml_alloc (4 * Double_wosize, Double_array_tag); \
  Store_double_field(rv, 0, v[0]); \
  Store_double_field(rv, 1, v[1]); \
  Store_double_field(rv, 2, v[2]); \
  Store_double_field(rv, 3, 0.0);
#define Val_Vector4(rv,v) \
  rv = caml_alloc (4 * Double_wosize, Double_array_tag); \
  Store_double_field(rv, 0, v[0]); \
  Store_double_field(rv, 1, v[1]); \
  Store_double_field(rv, 2, v[2]); \
  Store_double_field(rv, 3, v[3]);
#define Val_Matrix3(rv,v) \
  rv = caml_alloc (12 * Double_wosize, Double_array_tag); \
  Store_double_field(rv, 0, v[0]); \
  Store_double_field(rv, 1, v[1]); \
  Store_double_field(rv, 2, v[2]); \
  Store_double_field(rv, 3, v[3]); \
  Store_double_field(rv, 4, v[4]); \
  Store_double_field(rv, 5, v[5]); \
  Store_double_field(rv, 6, v[6]); \
  Store_double_field(rv, 7, v[7]); \
  Store_double_field(rv, 8, v[8]); \
  Store_double_field(rv, 9, v[9]); \
  Store_double_field(rv, 10, v[10]); \
  Store_double_field(rv, 11, v[11]);
#define Val_Quaternion(rv,v) Val_Vector4(rv,v)
#define Val_AABB(rv,v) \
  rv = caml_alloc (6 * Double_wosize, Double_array_tag); \
  Store_double_field(rv, 0, v[0]); \
  Store_double_field(rv, 1, v[1]); \
  Store_double_field(rv, 2, v[2]); \
  Store_double_field(rv, 3, v[3]); \
  Store_double_field(rv, 4, v[4]); \
  Store_double_field(rv, 5, v[5]);

#define Real_byptr_prepare(v) double v##_C;
#define Vector3_byptr_prepare(v) double v##_C[4];
#define Vector4_byptr_prepare(v) double v##_C[4];
#define Matrix3_byptr_prepare(v) double v##_C[12];
#define Quaternion_byptr_prepare(v) double v##_C[4];
#define AABB_byptr_prepare(v) double v##_C[6];

#define Real_byptr(v) &v##_C
#define Vector3_byptr(v) v##_C
#define Vector4_byptr(v) v##_C
#define Matrix3_byptr(v) v##_C
#define Quaternion_byptr(v) v##_C
#define AABB_byptr(v) v##_C

#define Real_byptr_store(v) v = caml_copy_double(v##_C);
#define Vector3_byptr_store(v) Val_Vector3(v,v##_C)
#define Vector4_byptr_store(v) Val_Vector4(v,v##_C)
#define Matrix3_byptr_store(v) Val_Matrix3(v,v##_C)
#define Quaternion_byptr_store(v) Val_Quaternion(v,v##_C)
#define AABB_byptr_store(v) Val_AABB(v,v##_C)

#endif

#define Val_Vector3_fromptr(rv,v) Val_Vector3(rv,v)
#define Val_Vector4_fromptr(rv,v) Val_Vector4(rv,v)
#define Val_Matrix3_fromptr(rv,v) Val_Matrix3(rv,v)
#define Val_Quaternion_fromptr(rv,v) Val_Quaternion(rv,v)
#define Val_AABB_fromptr(rv,v) Val_AABB(rv,v)

#define dVector3_ptr dReal *
#define dVector4_ptr dReal *
#define dMatrix3_ptr dReal *
#define dQuaternion_ptr dReal *
#define dAABB_ptr dReal *
#define Vector3_ptrof(v) v
#define Vector4_ptrof(v) v
#define Matrix3_ptrof(v) v
#define Quaternion_ptrof(v) v
#define AABB_ptrof(v) v

#define Vector3F_val(v) v##_C
#define Vector3F_prepare(v) float v##_C[4]; \
  v##_C[0] = (float) Double_field(v,0); \
  v##_C[1] = (float) Double_field(v,1); \
  v##_C[2] = (float) Double_field(v,2); \
  v##_C[3] = 0.0;
#define Val_Vector3F(rv,v) \
  rv = caml_alloc (4 * Double_wosize, Double_array_tag); \
  Store_double_field(rv, 0, (double) v[0]); \
  Store_double_field(rv, 1, (double) v[1]); \
  Store_double_field(rv, 2, (double) v[2]); \
  Store_double_field(rv, 3, 0.0);
#define Vector3F_byptr_prepare(v) float v##_C[4];
#define Vector3F_byptr(v) v##_C
#define Vector3F_byptr_store(v) Val_Vector3F(v,v##_C)
#define Val_Vector3F_fromptr(rv,v) Val_Vector3F(rv,v)
#define dVector3F_ptr float *
#define Vector3F_ptrof(v) v

/** If number of arguments is followed by u, Caml function takes additional
    unit argument. */

/** Functions returning unit. */

#define ML_0(cname) \
CAMLprim value ml_##cname (value unit) \
{ cname (); return Val_unit; }
#define ML_1(cname, typ1) \
CAMLprim value ml_##cname (value arg1) \
{ typ1##_prepare(arg1) \
  cname (typ1##_val(arg1)); return Val_unit; }
#define ML_2(cname, typ1, typ2) \
CAMLprim value ml_##cname (value arg1, value arg2) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) \
  cname (typ1##_val(arg1),typ2##_val(arg2)); \
  return Val_unit; }
#define ML_3(cname, typ1, typ2, typ3) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  cname (typ1##_val(arg1),typ2##_val(arg2),typ3##_val(arg3)); \
  return Val_unit; }

#define ML_3u(cname, typ1, typ2, typ3) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
   value unit) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  cname (typ1##_val(arg1),typ2##_val(arg2),typ3##_val(arg3)); \
  return Val_unit; }

#define ML_4(cname, typ1, typ2, typ3, typ4) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
   value arg4) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) \
  cname (typ1##_val(arg1),typ2##_val(arg2),typ3##_val(arg3), \
      typ4##_val(arg4)); \
  return Val_unit; }
#define ML_4u(cname, typ1, typ2, typ3, typ4) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
   value arg4, value unit) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) \
  cname (typ1##_val(arg1),typ2##_val(arg2),typ3##_val(arg3), \
      typ4##_val(arg4)); \
  return Val_unit; }

#define ML_5(cname, typ1, typ2, typ3, typ4, typ5) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) typ5##_prepare(arg5) \
  cname (typ1##_val(arg1),typ2##_val(arg2),typ3##_val(arg3), \
      typ4##_val(arg4), typ5##_val(arg5)); \
  return Val_unit; }

#define ML_6(cname, typ1, typ2, typ3, typ4, typ5, typ6) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5, value arg6) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) typ5##_prepare(arg5) typ6##_prepare(arg6) \
   cname (typ1##_val(arg1),typ2##_val(arg2),typ3##_val(arg3), \
      typ4##_val(arg4), typ5##_val(arg5), typ6##_val(arg6)); \
   return Val_unit; }

#define ML_7(cname, typ1, typ2, typ3, typ4, typ5, typ6, typ7) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5, value arg6, value arg7) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) typ5##_prepare(arg5) typ6##_prepare(arg6) \
  typ7##_prepare(arg7) \
   cname (typ1##_val(arg1),typ2##_val(arg2),typ3##_val(arg3), \
      typ4##_val(arg4), typ5##_val(arg5), typ6##_val(arg6), \
      typ7##_val(arg7)); \
   return Val_unit; }

#define ML_8(cname,typ1,typ2,typ3,typ4,typ5,typ6,typ7,typ8) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5, value arg6, value arg7, value arg8) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) typ5##_prepare(arg5) typ6##_prepare(arg6) \
  typ7##_prepare(arg7) typ8##_prepare(arg8) \
   cname (typ1##_val(arg1),typ2##_val(arg2),typ3##_val(arg3), \
      typ4##_val(arg4), typ5##_val(arg5), typ6##_val(arg6), \
      typ7##_val(arg7), typ8##_val(arg8)); \
   return Val_unit; }



/** Functions computing and returning single value. */

/* it is not needed to register global roots, when allocating when
   everything is already computed */

#define ML_0_(cname, typ) \
CAMLprim value ml_##cname (value unit) \
{ d##typ retv = cname (); \
  value rv = Val_int(0); Val_##typ (rv, retv); \
  return rv; }
#define ML_1_(cname, typ1, typ) \
CAMLprim value ml_##cname (value arg1) \
{ typ1##_prepare(arg1) \
  d##typ retv = cname (typ1##_val(arg1)); \
  value rv = Val_int(0); Val_##typ (rv, retv); \
  return rv; }
#define ML_1u_(cname, typ1, typ) \
CAMLprim value ml_##cname (value arg1, value unit) \
{ typ1##_prepare(arg1) \
  d##typ retv = cname (typ1##_val(arg1)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_2_(cname, typ1, typ2, typ) \
CAMLprim value ml_##cname (value arg1, value arg2) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_2u_(cname, typ1, typ2, typ) \
CAMLprim value ml_##cname (value arg1, value arg2, value unit) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_3_(cname, typ1, typ2, typ3, typ) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_3u_(cname, typ1, typ2, typ3, typ) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value unit) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_4_(cname, typ1, typ2, typ3, typ4, typ) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
      typ4##_val(arg4)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_4u_(cname, typ1, typ2, typ3, typ4, typ) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value unit) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
      typ4##_val(arg4)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_5_(cname, typ1, typ2, typ3, typ4, typ5, typ) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
				 value arg4, value arg5) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) typ5##_prepare(arg5) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
      typ4##_val(arg4), typ5##_val(arg5)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_5u_(cname, typ1, typ2, typ3, typ4, typ5, typ) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5, value unit) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) typ5##_prepare(arg5) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
      typ4##_val(arg4), typ5##_val(arg5)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_6_(cname, typ1, typ2, typ3, typ4, typ5, typ6, typ) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5, value arg6) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) typ5##_prepare(arg5) typ6##_prepare(arg6) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
      typ4##_val(arg4), typ5##_val(arg5), typ6##_val(arg6)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_7_(cname, typ1, typ2, typ3, typ4, typ5, typ6, typ7, typ) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5, value arg6, value arg7) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) typ5##_prepare(arg5) typ6##_prepare(arg6) \
  typ7##_prepare(arg7) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
    typ4##_val(arg4), typ5##_val(arg5), typ6##_val(arg6), typ6##_val(arg6), \
    typ7##_val(arg7)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }
#define ML_8_(cname, typ1, typ2, typ3, typ4, typ5, typ6, typ7, typ8, typ) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5, value arg6, value arg7, value arg8) \
{ typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) typ5##_prepare(arg5) typ6##_prepare(arg6) \
  typ7##_prepare(arg7) typ8##_prepare(arg8) \
  d##typ retv = cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
    typ4##_val(arg4), typ5##_val(arg5), typ6##_val(arg6), typ6##_val(arg6), \
    typ7##_val(arg7), typ8##_val(arg8)); \
  value rv; Val_##typ (rv, retv); \
  return rv; }



/** Functions computing one result into their last argument, passed by
    pointer. */

/* needs not register global roots because only one allocation is done */

/* allocatate always after computing the answer */

#define ML_1_1(cname, typ1, typ1r) \
CAMLprim value ml_##cname (value arg1) { \
  typ1##_prepare(arg1) \
  d##typ1r res; \
  cname (typ1##_val(arg1), typ1r##_ptrof(res)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }
#define ML_2_1(cname, typ1, typ2, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2) { \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  d##typ1r res; \
  cname (typ1##_val(arg1), typ2##_val(arg2), typ1r##_ptrof(res)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }
#define ML_4_1(cname, typ1, typ2, typ3, typ4, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4) { \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  typ3##_prepare(arg3) typ4##_prepare(arg4) \
  d##typ1r res; \
  cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
    typ4##_val(arg4), typ1r##_ptrof(res)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }
#define ML_5_1(cname, typ1, typ2, typ3, typ4, typ5, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5) { \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  typ3##_prepare(arg3) typ4##_prepare(arg4) typ5##_prepare(arg5) \
  d##typ1r res; \
  cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
    typ4##_val(arg4), typ5##_val(arg5), typ1r##_ptrof(res)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }



/** Functions computing one result into their last argument, passed by
    pointer; use this version only when parameters are small (not
    vectors nor matrices) and the result is a vector or matrix. */

/* needs not register global roots because only one allocation is done */

#define ML_0_1(cname, typ1r) \
CAMLprim value ml_##cname (value unit) { \
  value r = Val_int(0); typ1r##_byptr_prepare(r) \
  cname (typ1r##_byptr(r)); \
  typ1r##_byptr_store(r) \
  return r; }

#ifndef ARCH_ALIGN_DOUBLE

/* needs to store parameters because allocation is done before
   computing the answer */

#define ML_1_1s(cname, typ1, typ1r) \
CAMLprim value ml_##cname (value arg1) { \
  typ1##_prepare_copy(arg1) \
  value r = Val_int(0); typ1r##_byptr_prepare(r) \
  cname (typ1##_val_copy(arg1), typ1r##_byptr(r)); \
  typ1r##_byptr_store(r) \
  return r; }
#define ML_2_1s(cname, typ1, typ2, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2) { \
  typ1##_prepare_copy(arg1) typ2##_prepare_copy(arg2) \
  value r = Val_int(0); typ1r##_byptr_prepare(r) \
  cname (typ1##_val_copy(arg1), typ2##_val_copy(arg2), typ1r##_byptr(r)); \
  typ1r##_byptr_store(r) \
  return r; }
#define ML_4_1s(cname, typ1, typ2, typ3, typ4, typ1r) \
CAMLprim value ml_##cname (value arg1) { \
  typ1##_prepare_copy(arg1) typ2##_prepare_copy(arg2) \
  typ3##_prepare_copy(arg3) typ4##_prepare_copy(arg4) \
  value r = Val_int(0); typ1r##_byptr_prepare(r) \
  cname (typ1##_val_copy(arg1), typ2##_val_copy(arg2), typ3##_val_copy(arg3), \
    typ4##_val_copy(arg4), typ1r##_byptr(r)); \
  typ1r##_byptr_store(r) \
  return r; }

#else

/* allocation is done anyway after computing because of the double
   array representation incompatibility */

#define ML_1_1s(cname, typ1, typ1r) ML_1_1(cname, typ1, typ1r)
#define ML_2_1s(cname, typ1, typ2, typ1r) ML_2_1(cname, typ1, typ2, \
  typ1r)
#define ML_4_1s(cname, typ1, typ2, typ3, typ4, typ1r) \
  ML_4_1(cname, typ1, typ2, typ3, typ4, typ1r)

#endif



/** Functions computing one result into their last argument, passed by
    pointer; use this version only when result is large (a matrix). */

#ifndef ARCH_ALIGN_DOUBLE

/* registers global roots, to preallocate the data to store results */

#define ML_1_1l(cname, typ1, typ1r) \
CAMLprim value ml_##cname (value arg1) { \
  CAMLparam1 (arg1); \
  CAMLlocal1 (r); \
  typ1##_prepare(arg1) typ1r##_byptr_prepare(r) \
  cname (typ1##_val(arg1), typ1r##_byptr(r)); \
  typ1r##_byptr_store(r) \
  CAMLreturn (r); }
#define ML_4_1l(cname, typ1, typ2, typ3, typ4, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4) { \
  CAMLparam4 (arg1, arg2, arg3, arg4); \
  CAMLlocal1 (r); \
  typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) \
  typ1r##_byptr_prepare(r) \
  cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
    typ4##_val(arg4), typ1r##_byptr(r)); \
  typ1r##_byptr_store(r) \
  CAMLreturn (r); }

#else

/* local copy is done anyway before computing because of the double
   array representation incompatibility */

#define ML_1_1l(cname, typ1, typ1r) ML_1_1(cname, typ1, typ1r)
#define ML_4_1l(cname, typ1, typ2, typ3, typ4, typ1r) \
  ML_4_1(cname, typ1, typ2, typ3, typ4, typ1r)

#endif



/** Functions computing results into their two last arguments, passed by
    pointers; they return a pair. */

#define ML_0_2(cname, typ1r, typ2r) \
CAMLprim value ml_##cname (value unit) { \
  CAMLparam0 (); \
  CAMLlocal3 (v1,v2,r); \
  typ1r##_byptr_prepare(v1) typ2r##_byptr_prepare(v2) \
  cname (typ1r##_byptr(v1), typ2r##_byptr(v2)); \
  typ1r##_byptr_store(v1) typ2r##_byptr_store(v2) \
  r = caml_alloc_tuple (2); \
  Store_field (r, 0, v1); \
  Store_field (r, 1, v2); \
  CAMLreturn (r); }

#define ML_1_2(cname, typ1, typ1r, typ2r) \
CAMLprim value ml_##cname (value arg1) { \
  CAMLparam1 (arg1); \
  CAMLlocal3 (v1,v2,r); \
  typ1##_prepare(arg1) typ1r##_byptr_prepare(v1) typ2r##_byptr_prepare(v2) \
  cname (typ1##_val(arg1), typ1r##_byptr(v1), typ2r##_byptr(v2)); \
  typ1r##_byptr_store(v1) typ2r##_byptr_store(v2) \
  r = caml_alloc_tuple (2); \
  Store_field (r, 0, v1); \
  Store_field (r, 1, v2); \
  CAMLreturn (r); }
#define ML_4_2(cname, typ1, typ2, typ3, typ4, typ1r, typ2r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4) { \
  CAMLparam4 (arg1, arg2, arg3, arg4); \
  CAMLlocal3 (v1,v2,r); \
  typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) \
  typ1r##_byptr_prepare(v1) typ2r##_byptr_prepare(v2) \
  cname (typ1##_val(arg1), typ2##_val(arg2), typ3##_val(arg3), \
    typ4##_val(arg4), typ1r##_byptr(v1), typ2r##_byptr(v2)); \
  typ1r##_byptr_store(v1) typ2r##_byptr_store(v2) \
  r = caml_alloc_tuple (2); \
  Store_field (r, 0, v1); \
  Store_field (r, 1, v2); \
  CAMLreturn (r); }


/** Functions computing one result into their first argument, passed by
    pointer. */

/* needs not register global roots because only one allocation is done */

/* allocatate always after computing the answer */

#define ML_1_b1(cname, typ1, typ1r) \
CAMLprim value ml_##cname (value arg1) { \
  typ1##_prepare(arg1) \
  d##typ1r res; \
  cname (typ1r##_ptrof(res), typ1##_val(arg1)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }
#define ML_2_b1(cname, typ1, typ2, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2) { \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  d##typ1r res; \
  cname (typ1r##_ptrof(res), typ1##_val(arg1), typ2##_val(arg2)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }
#define ML_3_b1(cname, typ1, typ2, typ3, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3) { \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  typ3##_prepare(arg3) \
  d##typ1r res; \
  cname (typ1r##_ptrof(res), typ1##_val(arg1), typ2##_val(arg2), \
    typ3##_val(arg3)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }
#define ML_3u_b1(cname, typ1, typ2, typ3, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, value unit) { \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  typ3##_prepare(arg3) \
  d##typ1r res; \
  cname (typ1r##_ptrof(res), typ1##_val(arg1), typ2##_val(arg2), \
    typ3##_val(arg3)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }
#define ML_4_b1(cname, typ1, typ2, typ3, typ4, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4) { \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  typ3##_prepare(arg3) typ4##_prepare(arg4) \
  d##typ1r res; \
  cname (typ1r##_ptrof(res), typ1##_val(arg1), typ2##_val(arg2), \
    typ3##_val(arg3), typ4##_val(arg4)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }
#define ML_5_b1(cname, typ1, typ2, typ3, typ4, typ5, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5) { \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  typ3##_prepare(arg3) typ4##_prepare(arg4) typ5##_prepare(arg5) \
  d##typ1r res; \
  cname (typ1r##_ptrof(res), typ1##_val(arg1), typ2##_val(arg2), \
    typ3##_val(arg3), typ4##_val(arg4), typ5##_val(arg5)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }

#define ML_6u_b1(cname, typ1, typ2, typ3, typ4, typ5, typ6, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value arg5, value arg6, value unit) { \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  typ3##_prepare(arg3) typ4##_prepare(arg4) \
  typ5##_prepare(arg5) typ6##_prepare(arg6) \
  d##typ1r res; \
  cname (typ1r##_ptrof(res), typ1##_val(arg1), typ2##_val(arg2), \
    typ3##_val(arg3), typ4##_val(arg4), typ5##_val(arg5), typ6##_val(arg6)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }

#define ML_4u_b1(cname, typ1, typ2, typ3, typ4, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4, value unit) { \
  typ1##_prepare(arg1) typ2##_prepare(arg2) \
  typ3##_prepare(arg3) typ4##_prepare(arg4) \
  d##typ1r res; \
  cname (typ1r##_ptrof(res), typ1##_val(arg1), typ2##_val(arg2), \
    typ3##_val(arg3), typ4##_val(arg4)); \
  value r = Val_int(0); Val_##typ1r(r, res) \
  return r; }



/** Functions computing one result into their first argument, passed by
    pointer; use this version only when parameters are small (not
    vectors nor matrices) and the result is a vector or matrix. */

/* needs not register global roots because only one allocation is done */

#ifndef ARCH_ALIGN_DOUBLE

/* needs to store parameters because allocation is done before
   computing the answer */

#define ML_1_b1s(cname, typ1, typ1r) \
CAMLprim value ml_##cname (value arg1) { \
  typ1##_prepare_copy(arg1) \
  value r = Val_int(0); typ1r##_byptr_prepare(r) \
  cname (typ1r##_byptr(r), typ1##_val_copy(arg1)); \
  typ1r##_byptr_store(r) \
  return r; }
#define ML_2_b1s(cname, typ1, typ2, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2) { \
  typ1##_prepare_copy(arg1) typ2##_prepare_copy(arg2) \
  value r = Val_int(0); typ1r##_byptr_prepare(r) \
  cname (typ1r##_byptr(r), typ1##_val_copy(arg1), typ2##_val_copy(arg2)); \
  typ1r##_byptr_store(r) \
  return r; }
#define ML_4_b1s(cname, typ1, typ2, typ3, typ4, typ1r) \
CAMLprim value ml_##cname (value arg1) { \
  typ1##_prepare_copy(arg1) typ2##_prepare_copy(arg2) \
  typ3##_prepare_copy(arg3) typ4##_prepare_copy(arg4) \
  value r = Val_int(0); typ1r##_byptr_prepare(r) \
  cname (typ1r##_byptr(r), typ1##_val_copy(arg1), typ2##_val_copy(arg2), \
    typ3##_val_copy(arg3), typ4##_val_copy(arg4)); \
  typ1r##_byptr_store(r) \
  return r; }

#else

/* allocation is done anyway after computing because of the double
   array representation incompatibility */

#define ML_1_b1s(cname, typ1, typ1r) ML_1_b1(cname, typ1, typ1r)
#define ML_2_b1s(cname, typ1, typ2, typ1r) ML_2_b1(cname, typ1, typ2, \
  typ1r)
#define ML_4_b1s(cname, typ1, typ2, typ3, typ4, typ1r) \
  ML_4_b1(cname, typ1, typ2, typ3, typ4, typ1r)

#endif



/** Functions computing one result into their first argument, passed by
    pointer; use this version only when result is large (a matrix). */

#ifndef ARCH_ALIGN_DOUBLE

/* registers global roots, to preallocate the data to store results */

#define ML_1_b1l(cname, typ1, typ1r) \
CAMLprim value ml_##cname (value arg1) { \
  CAMLparam1 (arg1); \
  CAMLlocal1 (r); \
  typ1##_prepare(arg1) typ1r##_byptr_prepare(r) \
  cname (typ1r##_byptr(r), typ1##_val(arg1)); \
  typ1r##_byptr_store(r) \
  CAMLreturn (r); }
#define ML_4_b1l(cname, typ1, typ2, typ3, typ4, typ1r) \
CAMLprim value ml_##cname (value arg1, value arg2, value arg3, \
    value arg4) { \
  CAMLparam4 (arg1, arg2, arg3, arg4); \
  CAMLlocal1 (r); \
  typ1##_prepare(arg1) typ2##_prepare(arg2) typ3##_prepare(arg3) \
  typ4##_prepare(arg4) \
  typ1r##_byptr_prepare(r) \
  cname (typ1r##_byptr(r), typ1##_val(arg1), typ2##_val(arg2), \
    typ3##_val(arg3), typ4##_val(arg4)); \
  typ1r##_byptr_store(r) \
  CAMLreturn (r); }

#else

/* local copy is done anyway before computing because of the double
   array representation incompatibility */

#define ML_1_b1l(cname, typ1, typ1r) ML_1_b1(cname, typ1, typ1r)
#define ML_4_b1l(cname, typ1, typ2, typ3, typ4, typ1r) \
  ML_4_b1(cname, typ1, typ2, typ3, typ4, typ1r)

#endif

/** Functions returning result by pointer. */

#define ML_1_r(cname, typ1, typ) \
CAMLprim value ml_##cname (value arg1) { \
  typ1##_prepare(arg1) \
  const d##typ##_ptr v = cname (typ1##_val(arg1)); \
  value r = Val_int(0); Val_##typ##_fromptr (r, v); \
  return r; }


/** Create option, encapsulates registering global
    roots so that it can be used with macros that don't do it. */

#define Val_OPTION(x,rv,v) { \
 value r1 = Val_int(0); rv = Val_int(0); Begin_roots2(rv, r1); \
  if (v) { \
    rv = caml_alloc (1, 0); \
    Val_##x (r1, v); \
    Store_field (rv, 0, r1); \
  } \
  End_roots(); }



/** For more than 5 arguments: bytecode version */
#define ML_bc6(cname) \
CAMLprim value cname##_bc (value *argv, int argn) \
{ return cname(argv[0],argv[1],argv[2],argv[3],argv[4],argv[5]); }

#define ML_bc7(cname) \
CAMLprim value cname##_bc (value *argv, int argn) \
{ return cname(argv[0],argv[1],argv[2],argv[3],argv[4],argv[5],argv[6]); }

#define ML_bc8(cname) \
CAMLprim value cname##_bc (value *argv, int argn) \
{ return cname(argv[0],argv[1],argv[2],argv[3],argv[4],argv[5],argv[6], \
               argv[7]); }
#define ML_bc9(cname) \
CAMLprim value cname##_bc (value *argv, int argn) \
{ return cname(argv[0],argv[1],argv[2],argv[3],argv[4],argv[5],argv[6], \
               argv[7], argv[8]); }
#define ML_bc10(cname) \
CAMLprim value cname##_bc (value *argv, int argn) \
{ return cname(argv[0],argv[1],argv[2],argv[3],argv[4],argv[5],argv[6], \
               argv[7], argv[8], argv[9]); }
#define ML_bc11(cname) \
CAMLprim value cname##_bc (value *argv, int argn) \
{ return cname(argv[0],argv[1],argv[2],argv[3],argv[4],argv[5],argv[6], \
               argv[7], argv[8], argv[9], argv[10]); }
#define ML_bc12(cname) \
CAMLprim value cname##_bc (value *argv, int argn) \
{ return cname(argv[0],argv[1],argv[2],argv[3],argv[4],argv[5],argv[6], \
               argv[7], argv[8], argv[9], argv[10], argv[11]); }

#endif
