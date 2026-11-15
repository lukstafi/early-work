public class MyMapImpl<K extends Comparable<K>, V>
    extends MyLinkedList<Pair<K,V>> implements MyMap<K,V> {

    public MyMapImpl () { }

    protected MyMapImpl (K elem, V value) {
        list.elem = new Pair<K,V> (elem, value);
    }

    /** Default constructor creates an empty map. */
    public MyMap<K,V> empty () {
        return new MyMapImpl<K,V> ();
    }

    /** Add a key to value mapping to the current map. */
    public void add (K key, V value) {
        insertReplace (new Pair<K,V> (key, value));
    }

    /** Find a value assigned to the given key, return null if key is
     * not present in the map. */
    public V lookup (K key) {
        Pair<K,V> res = findElem (new Pair<K,V>(key, null));
        if (res == null) return null;
        return res.value;
    }

    /** Check if the current map is empty. */
    public boolean isEmpty () {
        return (list.elem == null);
    }

    /** Check if the current map has a given key. */
    public boolean hasKey (K key) {
        return (findElem (new Pair<K,V>(key, null)) != null);
    }

    // public class DomainClash extends Exception {};

    /** Union of two maps stored in the current map, throws
     * DomainClash when a single key is assigned to different values
     * in the maps. */
    public void union (MyMap<K,V> map2) throws DomainClash {
        // TO-DO
    }


}

class Pair<K extends Comparable<K>, V> implements Comparable<Pair<K,V>> {
    K key;
    V value;

    public Pair (K key, V value) {
        this.key = key;
        this.value = value;
    }
    public int compareTo (Pair<K,V> p2) {
        return key.compareTo (p2.key);
    }
}
