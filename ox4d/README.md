# ox4d

Noughts-and-crosses on a four-dimensional board, in OCaml with a LablTk interface. An OCaml rewrite of a game first written in AMOS BASIC on an Amiga; the AMOS version is lost.

- `ox4d_v2.ml`: the older file, dated March 2003.
- `ox4d.ml`: revived in May 2007. Its first comment reads "I've returned this old baby to life, but I don't remember how it works."

A first window sets the four board dimensions and the length of a winning line on sliders. Each cell is drawn as a slice of a circle, with the slice chosen by the fourth coordinate. There is a computer opponent, undo on any key, and two modes: "First Blood" ends at the first line, "Mortal Combat" counts points.

To run, as the 2007 comment says (LablTk is no longer shipped with OCaml, so this needs an old compiler or the separate `labltk` package):

```
ocamlopt -I +labltk labltk.cmxa ox4d.ml -o ox4d
```

No licence notice in the files.
