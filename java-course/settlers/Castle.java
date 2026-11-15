package settlers;
import java.io.*;

public class Castle extends Warehouse implements Serializable {

    /** The maximal total amount of resources stored. */
    int storeCapacity () { return 128; }
    Resources resourcesToBuild () { return new Resources (0, 0); }

    /** Create a carrier for the castle. */
    public Carrier createCarrier () {
        Carrier carrier = new Carrier (scheduler, settlement, x, y);
        carrier.atWaypoint = this;
        settlers.add (Carrier.class, carrier);
        return carrier;
    }

    /** Introduce a new settlement by building its castle, if the
     * settlement already exists return null. */
    public static Castle buildCastle
        (Scheduler scheduler, Settlement settlement, int x, int y)
    {
        if (Settlement.castles.containsKey (settlement)) return null;
        Castle castle = new Castle (scheduler, settlement, x, y);
        Settlement.castles.put (settlement, castle);
        return castle;
    }

    private void readObject(ObjectInputStream stream)
        throws IOException, ClassNotFoundException {
        stream.defaultReadObject();
        Settlement.castles.put (this.settlement, this);
    }


    private Castle (Scheduler scheduler, Settlement settlement, int x, int y) {
        super (scheduler, null, settlement, x, y);
        // we put current castle as its origin
        stored = settlement.initialResources ();
    }    
}
