package settlers;
import java.io.*;

/** Buildings require resources to be built and can provide resources
 * to other buildings. */
public abstract class Building extends Waypoint implements Serializable {
    /** The scheduler of the settlement the building belongs to. */
    Scheduler scheduler;

    /** The amount of resources stored. Always non-negative. */
    Resources stored = new Resources (0, 0);
    /** The amount of resources broadcasted as required. Always
     * non-negative. */
    Resources required = resourcesToBuild ();

    /** A building that is {@code notFunctional()} cannot perform its
     * function. */
    boolean notFunctional () {
        return required.sum () > 0;
    }

    /** The maximal total amount of resources stored. */
    int storeCapacity () { return 16; }

    /** The amount of resources needed for construction. */
    abstract Resources resourcesToBuild ();

    /** The settlers that are in the building -- can be ordered to
     * perform tasks. */
    Settlers settlers = new Settlers ();

    public Building (Scheduler scheduler, Waypoint origin,
                     Settlement settlement, int x, int y) {
        super (origin, settlement, x, y);
        this.scheduler = scheduler;
    }
}