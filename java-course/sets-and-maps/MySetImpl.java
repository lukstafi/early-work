public class MySetImpl<E extends Comparable<E>>
    extends MyLinkedList<E> implements MySet<E> {


    /** Default constructor creates an empty set. */
    public MySetImpl () {
    }

    /** Protected constructor to be used in the head method and to
     * create the argument for calls to insertSingle. */
    protected MySetImpl (E elem) {
        list.elem = elem;
    }

    /** Create a new empty set. */
    public MySetImpl<E> empty () {
        return new MySetImpl<E> ();
    }

    /** Add an element to the current set. */
    public void add (E elem) {
        insertReplace (elem);
    }

    /** Check if the current set is empty. */
    public boolean isEmpty () {
        return (list.elem == null);
    }

    /** Check if the current set has the given element. */
    public boolean hasElement (E element) {
        return (findElem (element) != null);
    }

    /** Add the contents of the other set to the current set. */
    public void union (MySet<E> setImpl) {
        MySetImpl<E> set2 = (MySetImpl<E>)setImpl;

        // Merge the contents.
        merge (set2);

        // Remove repeating elements.
        MyLinkedList<E>.Node repeating = findRepeating ();
        while (repeating != null) {
             repeating.tail = repeating.tail.tail;
             repeating = findRepeating();
        }
    }

    /** Remove the contents not belonging to the other set from the
     * current set. */
    public void intersect (MySet<E> setImpl) {
        MySetImpl<E> set2 = (MySetImpl<E>)setImpl;
        //... TODO
    }
}    