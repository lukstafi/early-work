<TeXmacs|1.0.7.10>

<style|exam>

<\body>
  <class|Course of Programming in Java><title-date|due Nov 4, 2011>

  <\title>
    Sets and Maps
  </title>

  Write a set interface with:

  <\itemize>
    <item>creating an empty set,

    <item>adding an element to a set,

    <item>checking if a set is non-empty,

    <item>checking if an element is in a set,

    <item>set union,

    <item>set intersection
  </itemize>

  and a key-value map interface with:

  <\itemize>
    <item>creating an empty map,

    <item>adding a key-value pair to a map,

    <item>finding a value of a key,

    <item>checking if a map is non-empty,

    <item>checking if a key is in a map,

    <item>union of two maps that throws an exception when a key occurs in
    both maps but with different values.
  </itemize>

  Provide an ordered linked list based implementations for both interfaces
  (i.e. write a class implementing sets and a class implementing maps). Use a
  common abstract superclass for ordered linked lists. Also, provide the
  <verbatim|clone()> method for the implementations. Write as much common
  code as reasonably possible in the superclass.

  For bonus points, do one of the following exercises. It would be better if
  different people select different exercises.

  <\exercise>
    For both the set and the map class, implement the iterator pattern using
    an inner class. (Could it be implemented in the abstract superclass?)
  </exercise>

  <\exercise>
    Write set and map implementations using binary search trees (built out of
    nodes with links to other nodes), also with a common binary search tree
    superclass. You do not need to write the linked list implementations if
    you choose this exercise.
  </exercise>

  <\exercise>
    Write an adapter that takes any map implementation and turns it into a
    set implementation (actually, turns a map object into a set object).
  </exercise>

  <\exercise>
    Write your favorite (nontrivial) algorithm that uses sets and/or maps;
    use the set/map interfaces.
  </exercise>

  \;
</body>

<\initial>
  <\collection>
    <associate|language|american>
    <associate|page-screen-height|990208tmpt>
    <associate|page-screen-width|976896tmpt>
    <associate|par-hyphen|normal>
    <associate|sfactor|4>
  </collection>
</initial>