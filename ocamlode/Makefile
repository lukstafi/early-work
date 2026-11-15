# OCamlODE by Lukasz Stafiniak 10.2005

ODELIB=../ode-0.5/lib/libode.a
DRAWSTUFFLIB= ../ode-0.5/lib/libdrawstuff.a
CCLIBS=-cclib -lstdc++
OCAMLC=ocamlc
OCAMLOPT=ocamlopt
OCAMLDEP=ocamldep
DEBUG= -g -ccopt -g -dtypes
OPTDEBUG= -ccopt -g -dtypes
INCLUDES= -I +lablGL -I +site-lib/extlib -I +sdl
PP= -pp "camlp4o ./pa_ode.cmo"
OCAMLFLAGS= $(DEBUG) $(PP) $(INCLUDES)
OCAMLOPTFLAGS= $(OPTDEBUG) $(PP) $(INCLUDES)
LIBOBJS= ode.cmo world.cmo body.cmo jointGroup.cmo joint.cmo \
	contact.cmo mass.cmo geom.cmo space.cmo math.cmo
OPTOBJS = $(LIBOBJS:.cmo=.cmx)

all: ocamlode.cma ocamlode-opt.cmxa drawstuff-opt.cmxa \
	ocamlode-test drawstuff-test
	@echo SUCCESS

ocamlode.cma: ode_c.o $(LIBOBJS)
	$(OCAMLC) $(OCAMLFLAGS) -a -o ocamlode.cma -custom ode_c.o $(LIBOBJS) \
	$(ODELIB) $(CCLIBS)

ode_c.o: ode_c.c yacintf.h
	ocamlc $(OCAMLCFLAGS) -c ode_c.c

pa_ode.cmo: pa_ode.ml
	$(OCAMLC) $(OCAMLFLAGS) -pp "camlp4o pa_extend.cmo q_MLast.cmo" \
	-I +camlp4 -c pa_ode.ml

#drawstuff-byte: drawstuff_c.o drawstuff.cmo
#	ocamlc -a -o drawstuff.cma -custom drawstuff_c.o drawstuff.cmo
#	../ode-0.5/lib/libdrawstuff.a -cclib -lstdc++

drawstuff_c.o: drawstuff_c.c yacintf.h
	$(OCAMLC) $(OCAMLOPTS) -c drawstuff_c.c

ocamlode-opt.cmxa: ode_c.o $(OPTOBJS)
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -a -o ocamlode-opt.cmxa ode_c.o \
	$(OPTOBJS) $(ODELIB) $(CCLIBS)

drawstuff-opt.cmxa: drawstuff_c.o drawstuff.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -a -o drawstuff-opt.cmxa drawstuff_c.o \
	drawstuff.cmx $(DRAWSTUFFLIB) $(CCLIB)

ocamlode-test: katamari

katamari: ocamlode-opt.cmxa katamari.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o katamari $(INCLUDES) \
	lablgl.cmxa lablglut.cmxa sdl.cmxa unix.cmxa bigarray.cmxa \
	extLib.cmxa ocamlode-opt.cmxa katamari.cmx

katamari.cmx: katamari.ml pa_ode.cmo $(OPTOBJS)
	$(OCAMLOPT) $(OCAMLOPTFLAGS) $(PP) $(INCLUDES) -c katamari.ml

test_crash.cmx: test_crash.ml pa_ode.cmo $(OPTOBJS)
	$(OCAMLOPT) $(OCAMLOPTFLAGS) $(PP) $(INCLUDES) -c test_crash.ml

ragdoll.cmx: ragdoll.ml pa_ode.cmo $(OPTOBJS)
	$(OCAMLOPT) $(OCAMLOPTFLAGS) $(PP) $(INCLUDES) -c ragdoll.ml

drawstuff-test: test_crash ragdoll

test_crash: ocamlode-opt.cmxa drawstuff-opt.cmxa test_crash.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o test_crash $(INCLUDES) \
	lablgl.cmxa lablglut.cmxa sdl.cmxa unix.cmxa bigarray.cmxa \
	extLib.cmxa ocamlode-opt.cmxa drawstuff-opt.cmxa test_crash.cmx

ragdoll: ocamlode-opt.cmxa drawstuff-opt.cmxa ragdoll.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o ragdoll $(INCLUDES) \
	lablgl.cmxa lablglut.cmxa sdl.cmxa unix.cmxa bigarray.cmxa \
	extLib.cmxa ocamlode-opt.cmxa drawstuff-opt.cmxa ragdoll.cmx

.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	$(OCAMLC) $(PP) $(OCAMLFLAGS) -c $<

.mli.cmi:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

.ml.cmx:
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<

.depend:
	$(OCAMLDEP) $(INCLUDES) $(LIBOBJS:.cmo=.ml) > .depend

include .depend