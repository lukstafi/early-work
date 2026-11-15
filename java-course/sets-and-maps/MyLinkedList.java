public class MyLinkedList<E extends Comparable<E>> {

    protected class Node {
        public E elem;
        public Node tail;
        public Node () { }
        public Node (E elem, Node tail) {
            this.elem = elem;
            this.tail = tail;
        }
        public Node (E elem) {
            this.elem = elem;
        }
        public Node clone () {
            Node result = new Node (elem);
            if (tail != null) result.tail = tail.clone ();
            return result;
        }
    }

    protected Node list = new Node();

    /** Create an empty list. */
    public MyLinkedList () { }

    /** Create a list with one element. */
    public MyLinkedList (E elem) {
        list.elem = elem;
    }

    /** Create a list with one or more elements. */
    public MyLinkedList (E elem, MyLinkedList<E> tail) {
        list.elem = elem;
        list.tail = tail.list;
    }

    /** Insert an element into the current list, before the
     * first greater or equal element. */
    public void insertReplace (E single) {
        if (list.elem == null) {
            list.elem = single;
        } else if (single.compareTo (list.elem) < 0) {
            list = new Node (single, list);
        } else if (single.compareTo (list.elem) == 0) {
            list = new Node (single, list.tail);
        } else {
            Node l = list;
            while (l.tail != null && single.compareTo (l.tail.elem) > 0) {
                l = l.tail;
            }
            if (l.tail != null && single.compareTo (l.tail.elem) == 0)
                l.tail = l.tail.tail;
            l.tail = new Node (single, l.tail);
        }
    }

    /** Merge another ordered linked list into current list.
     * Current list is modified, the other list is preserved. */
    public void merge (MyLinkedList<E> list2) {

        if (list.elem == null) {
            list = list2.list.clone();
            return;
        }
        if (list2.list.elem == null) return;
            
        Node l1 = list;
        Node l2 = list2.list;
        Node first = new Node (null, list);
        Node previous = first;

        do {
            if (l1.elem.compareTo (l2.elem) < 0) {
                previous = l1;
                l1 = l1.tail;
            } else {
                previous.tail = new Node (l2.elem, l1);
                l2 = l2.tail;
            }
        } while (l1 != null && l2 != null);

        if (l1 == null && l2 != null) {
            previous.tail = l2.clone ();
        }

        list = first.tail;        
    }

    /** Return the first element that is equivalent to the given
     * element, return null if no such repeating elements exist. */
    public E findElem (E elem2) {
        Node l = list;
        while (l != null && l.elem.compareTo (elem2) != 0)
            l = l.tail;

        return (l == null ? null : l.elem);
    }

    /** Return the first cell such that the next cell has an
     * equivalent element, return null if no such repeating elements
     * exist. */
    protected Node findRepeating () {
        Node l = list;
        while (l != null &&
               (l.tail == null ||
                l.elem.compareTo (l.tail.elem) != 0))
            l = l.tail;

        /* If we have run to the end, then no repeating elements exist. */
        if (l != null && l.tail == null) return null;

        return l;
    }
}
