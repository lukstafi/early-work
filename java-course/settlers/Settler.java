package settlers;
import java.io.*;

/** A worker that gets stuff done, if possible. */
public abstract class Settler extends Entity implements Serializable {
    /** The scheduler of the settlement the settler belongs to. */
    Scheduler scheduler;
    /** The waypoint that the settler is located at, or null if the
     * settler is moving. */
    Waypoint atWaypoint;
    /** Identifier of a settler. */
    final int id;

    Settler (Scheduler scheduler, Settlement settlement, int x, int y) {
        super  (settlement, x, y);
        this.scheduler = scheduler;
        id = scheduler.getNextSettler ();
    }

    /** Schedule walking along a road for the settler. */
    void walk (final Waypoint.Road road, final Scheduler.Action onArrival) {
        if (road.isEmpty ()) return;
        Waypoint start = road.peek ();
        if (start != atWaypoint) {
            scheduler.signalMessage
                ("Settler "+toString ()+" cannot start walking at "+start);
            return;
        }
        ++start.congestion;     // will soon be decreased by the action
        atWaypoint = null;      // when walking, not at a waypoint
        // a bit of additional delay on start
        Scheduler.Action action = scheduler.new Action (1) {
                void run () {
                    Waypoint start = road.remove ();
                    if (road.isEmpty ()) {
                        --start.congestion;
                        atWaypoint = start;
                        // a bit of additional delay on end
                        onArrival.reschedule ("settler arrived", 1);
                        return;
                    }
                    Waypoint next = road.peek ();
                    if (next.congestion >= next.throughput ()) {
                        road.addFirst (start); // restore road
                        displayWaitingFor (2);
                        scheduler.displayMessage
                            ("Settler "+Settler.this.toString () +
                             " stuck before waypoint "+next.toString ());
                        reschedule ("settler stuck", 2);
                    } else {
                        --start.congestion;
                        ++next.congestion;
                        displayWalkingTowards (next);
                        // a bit of additional delay per waypoint
                        reschedule
                            ("settler moving", start.distance (next) + 1);
                    }
                }
            };
        scheduler.schedule (action);
    }

    /** Return walk, walk on a road (already reversed) and put the
     * settler into the building. */
    <T extends Settler> void returnWalk
               (final T settler, final java.lang.Class<T> settlerClass,
                final Building dst, final Waypoint.Road road) {
        if (road.isEmpty ()) return;
        if (dst != road.getLast () ||
            settler != this ||
            settlerClass != settler.getClass()) {
            scheduler.signalMessage
                ("Settler "+toString ()+": invalid return request.");
            return;
        }
        Scheduler.Action onArrival = scheduler.new // Scheduler.
            Action (0) {
                void run () {
                    dst.settlers.add (settlerClass, settler);
                    //(T) Settler.this);
                    scheduler.displayMessage
                        ("Settler "+Settler.this.toString()+
                         " returned to building "+dst);
                }
            };
        walk (road, onArrival);
    }

    /** Non-blockingly display the settler walking towards another
     * entity, modify settler's position along the way. */
    void displayWalkingTowards (Entity p) {
        // for now, just print it
        System.out.println
            ("Settler "+toString ()+" walks towards "+p.toString ());
        setPosition (p);
    }

    /** Non-blockingly display the settler impatiently waiting. */
    void displayWaitingFor (int delay) {
        // for now, just print it
        System.out.println
            ("Settler "+toString ()+" is waiting.");
    }
    public String toString () {
        return (id + "@" + super.toString ());
    }
}
