package settlers;

import java.util.*;
import java.io.*;

/** A type-indexed storage class for objects of different subclasses
 * of the Settler class. See "Effective Java" by Joshua Bloch, "Item
 * 29". Put elements by, for example,
 * {@code settlers.add(Carrier.class, carrier)}, and retrieve by
 * {@code settlers.poll(Carrier.class)}. */
public class Settlers implements Serializable {
    private
        Map<Class<? extends Settler>,
                            LinkedList<Settler>> settlers =
                            new HashMap<Class<? extends Settler>,
                                                        LinkedList<Settler>>();
    public <T extends Settler> void add(Class<T> type, T settler) {
        if (type == null)
            throw new NullPointerException("Type is null");
        if (settlers.containsKey (type)) {
            LinkedList<Settler> settlersOfType = settlers.get (type);
            settlersOfType.add(settler);
        } else {
            LinkedList<Settler> settlersOfType =
                new LinkedList<Settler> ();
            settlersOfType.add(settler);
            settlers.put (type, settlersOfType);
        }
    }
    public <T extends Settler> T poll(Class<T> type) {
        if (type == null)
            throw new NullPointerException("Type is null");
        if (!settlers.containsKey (type)) return null;
        LinkedList<Settler> settlersOfType = settlers.get (type);
        if (settlersOfType.isEmpty ()) return null;
        return type.cast(settlersOfType.poll());
    }
    public int numberOf(Class<? extends Settler> type) {
        if (type == null)
            throw new NullPointerException("Type is null");
        if (!settlers.containsKey (type)) return 0;
        LinkedList<Settler> settlersOfType = settlers.get (type);
        return settlersOfType.size ();
    }
}
