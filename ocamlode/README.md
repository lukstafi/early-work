# OCamlODE (2005)

OCaml bindings for the Open Dynamics Engine (ODE) 0.5, a rigid-body physics library. Version 0.1, written August to November 2005. The project was registered on SourceForge on 2 September 2005 (<https://sourceforge.net/projects/ocamlode/>) but no files were released there, so this folder is the only copy.

This is not the OCamlODE maintained by Florent Monnier at <https://github.com/fccm/OCamlODE>, which descends separately from the same low-level bindings by Richard Jones.

## What is here

- `ode.ml`, `body.ml`, `geom.ml`, `joint.ml`, `jointGroup.ml`, `mass.ml`, `math.ml`, `space.ml`, `world.ml`, `contact.ml`: the bindings. The header of `ode.ml` says they are "based on low-level bindings by Richard W. M. Jones" and written "with lessons learned from lablGL by Jacques Garrigue".
- `ode_c.c`, `yacintf.h`: the C stubs.
- `pa_ode.ml`: a camlp4 syntax extension. It extends Alain Frisch's `open ... in` and adds literals for vectors and matrices, for example `{|a; b; c|}`. Marked public domain in the file.
- `ode-0.5.patch` and `ode-0.5/`: a patch to ODE's C++ source, with the patched files. It adds hooks called when a body, joint or geometry is destroyed, so that the engine's objects can be finalised from OCaml.
- `drawstuff.ml`, `drawstuff_c.c`: bindings to ODE's drawing helper.
- Demos: `ragdoll.ml` (November 2005, after a demo by Michael J Mandel), `katamari.ml` (by Richard Jones, adapted to these bindings), `test_crash.ml` (a demo of ODE's QuickStep and StepFast methods, originally by David Whittaker, rewritten in OCaml).

## Licences

The files written by Lukasz Stafiniak are under the MIT licence in `LICENSE`, which lists them: the module files, the C stubs, the drawing bindings and the Makefile.

The other files build on other people's work and keep those terms:

- `ode.ml` is based on Richard Jones's low-level bindings and keeps their terms.
- `katamari.ml` is by Richard Jones, under the GPL, version 2 or later, as its header says.
- `ragdoll.ml` is rewritten from a demo by Michael J Mandel, under the LGPL, as its header says.
- `test_crash.ml` is rewritten from an ODE demo by David Whittaker and follows ODE's terms.
- `ode-0.5/` and `ode-0.5.patch` are ODE's source and a change to it, under the LGPL or a BSD-style licence at the user's choice.
- `pa_ode.ml` is public domain, as its header says.

## Building

It needs ODE 0.5 with the patch applied, and camlp4 as shipped with OCaml in 2005. It has not been built since.
