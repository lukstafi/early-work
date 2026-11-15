public interface MySet<E extends Comparable<E>> {

    /** Create a new empty set. */
    MySet<E> empty ();

    /** Add an element to the current set. */
    void add (E elem);

    /** Check if the current set is empty. */
    boolean isEmpty ();

    /** Check if the current set has the given element. */
    boolean hasElement (E elem);

    /** Add the contents of the other set to the current set. */
    void union (MySet<E> set2);

    /** Remove the contents not belonging to the other set from the
     * current set. */
    void intersect (MySet<E> set2);
}
