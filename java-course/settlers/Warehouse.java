package settlers;
import java.io.*;

/** A warehouse stores and redistributes resources. */
public class Warehouse extends Building implements Serializable {

    /** Distribute resources to nearest buildings that require
     * them. Return whether the attempt to send a resource was
     * successful. */
    public boolean distribute () {
        if (stored.sum () <= 0 || notFunctional ()) {
            scheduler.displayMessage
                ("Warehouse "+toString ()+
                 " cannot distribute more; stored.sum = "+stored.sum ()+
                 ", required.sum = "+required.sum ());
            return false;
        }
        LookFor need = new LookFor () {
                public boolean is (Waypoint wp) {
                    if (!(wp instanceof Building)) return false;
                    Building b = (Building)wp;
                    return b.required.sum () > 0;
                }
            };
        Road distributeTo = breadthFirstSearch (need);
        if (distributeTo == null) {
            scheduler.displayMessage
                ("Warehouse "+toString ()+
                 " cannot distribute more bc. need not found.");
            return false;
        }
        Building dst = (Building) distributeTo.getLast ();
        Resources possibleOffer = dst.required.upTo (stored);
        if (possibleOffer.sum () <= 0) {
            scheduler.displayMessage
                ("Warehouse "+toString ()+
                 " cannot distribute more bc. does not have needed resource.");
            return false;
        }
        Carrier carrier = settlers.poll (Carrier.class);
        if (carrier == null) {
            scheduler.displayMessage
                ("Warehouse "+toString ()+
                 " cannot distribute more bc. does not have a carrier.");
            return false;
        }
        Resources.Resource offerKind = possibleOffer.maximal ();
        int offerAmount = Math.min
            (offerKind.get (possibleOffer),
             offerKind.get (Carrier.MAX_CARRIED));
        scheduler.displayMessage
            ("Warehouse "+toString ()+
             " distributes "+offerAmount+" out of possible "+possibleOffer);
        // the carry action deduces the amount from warehouse.stored
        carrier.carry (offerKind, offerAmount, this, dst, distributeTo);
        return true;
    }

    /** Distribution strategy: redistribute all resources at speed
     * provided by the short delay, or until there's no need for
     * resources. If the warehouse itself requires resources, wait
     * long delay. */
    public void redistributeAll (final int shortDelay, final int longDelay) {
        Scheduler.Action redistribute = scheduler.new // Scheduler.
            Action (0) {
                void run () {
                    if (required.sum () > 0)
                        reschedule ("redistributer construction", longDelay);
                    else if (distribute ())
                        reschedule ("redistributer working", shortDelay);
                    else if (settlers.poll (Carrier.class) == null)
                        reschedule ("redistributer waits for carriers",
                                    longDelay);
                    // else finish redistributing -- no need or no resources
                }
            };
        scheduler.schedule (redistribute);
    }

    /** The maximal total amount of resources stored. */
    int storeCapacity () { return 64; }
    Resources resourcesToBuild () { return new Resources (16, 3); }

    public Warehouse (Scheduler scheduler,
                      Waypoint origin, Settlement settlement, int x, int y) {
        super (scheduler, origin, settlement, x, y);
    }
}
