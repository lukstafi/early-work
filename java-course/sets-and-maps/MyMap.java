public interface MyMap<K extends Comparable<K>, V> {

    /** Create an empty map. */
    MyMap<K,V> empty ();

    /** Add a key to value mapping to the current map. */
    void add (K key, V value);

    /** Find a value assigned to the given key, return null if key is
     * not present in the map. */
    V lookup (K key);

    /** Check if the current map is empty. */
    boolean isEmpty ();

    /** Check if the current map has a given key. */
    boolean hasKey (K key);

    public class DomainClash extends Exception {};

    /** Union of two maps stored in the current map, throws
     * DomainClash when a single key is assigned to different values
     * in the maps. */
    void union (MyMap<K,V> map2) throws DomainClash;
}
