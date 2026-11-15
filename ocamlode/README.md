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

As stated in the files: `katamari.ml` is under the GPL, version 2 or later; `ragdoll.ml` is under the LGPL; `pa_ode.ml` is public domain; the files under `ode-0.5/` are ODE's, under the LGPL or a BSD-style licence at the user's choice. The remaining files carry no licence notice.

## Building

It needs ODE 0.5 with the patch applied, and camlp4 as shipped with OCaml in 2005. It has not been built since.
