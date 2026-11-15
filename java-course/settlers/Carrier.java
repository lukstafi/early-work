package settlers;
import java.io.*;

/** Carriers carry resources between waypoints. */
public class Carrier extends Settler implements Serializable {
    /** Amount of a resource currently carried. */
    int carrying = 0;
    /** Kind of resource carried. */
    Resources.Resource kind;
    
    /** Maximal amount of a resource carried. */
    final static Resources MAX_CARRIED = new Resources (3, 1);

    public Carrier (Scheduler scheduler, Settlement settlement, int x, int y) {
        super (scheduler, settlement, x, y);
    }
    
    public void carry (final Resources.Resource kind, final int amount,
                       final Building src, final Building dst,
                       final Waypoint.Road road) {
        if (!(src == road.getFirst () && dst == road.getLast () &&
              amount > 0 && amount <= kind.get (MAX_CARRIED))) {
            scheduler.signalMessage
                ("Carrier "+toString ()+": invalid carry request.");
            return;
        }
        kind.add (src.stored, -amount);
        final Waypoint.Road returnRoad = road.reverse ();
        Scheduler.Action onArrival = scheduler.new // Scheduler.
            Action (0) {
                void run () {
                    int required = kind.get (dst.required);
                    if (required > 0) {
                        // if required gets full, store what's remaining
                        int remaining = Math.max (0, amount - required);
                        kind.add (dst.required, remaining - amount);
                        kind.add (dst.stored, remaining);
                    } else
                        kind.add (dst.stored, amount);
                    if (dst.stored.sum () > dst.storeCapacity ())
                    {
                        // the deposit will be immediately subtracted
                        scheduler.displayMessage
                            ("Carrier "+toString()+
                             " cannot unload -- returning to "+src.toString ());
                        carry (kind, amount, dst, src, returnRoad);
                        return;
                    }
                    carrying = 0; Carrier.this.kind = null;
                    scheduler.displayMessage
                        ("Carrier "+Carrier.this.toString()+
                         " arrived; building "+dst+" results in: required="+
                         dst.required+", stored="+dst.stored);
                    if (dst.settlers.numberOf (Carrier.class) < 2)
                        dst.settlers.add (Carrier.class, Carrier.this);
                    else
                        returnWalk (Carrier.this, Carrier.class,
                                    src, returnRoad);
                }
            };
        walk (road, onArrival);
    }
                    
}