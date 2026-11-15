package settlers;

import java.util.*;
import java.io.*;

/** A node of the road system (road graph). Flags and buildings are
 * waypoints. */
public abstract class Waypoint extends Entity implements Serializable {
    /** Number of units passing a waypoint, cannot exceed the throughput. */
    int congestion = 0;
    /** The capacity of a waypoint. */
    int throughput () { return 8; }

    /** The incident nodes of a road graph: the waypoints that connect
     * to the current waypoint by road segments. */
    List<Waypoint> incident = new ArrayList<Waypoint> ();

    public void roadSegment (Waypoint toWp) {
        incident.add (toWp);
        toWp.incident.add (this);
    }

    static class Road extends LinkedList<Waypoint> {
        public Road () { }

        /** A new road starting at a waypoint. */
        public Road (Waypoint wp) {
            super ();
            add (wp);
        }
        /** A road extending an existing road by a waypoint. */
        public Road (Road r, Waypoint wp) {
            super (r);
            add (wp);
        }
        /** Return a return-road (i.e. waypoints in reverse order). */
        public Road reverse () {
            Road r = new Road ();
            for (Waypoint wp : this) {
                r.addFirst (wp);
            }
            return r;
        }
    }

    /** Create a waypoint connected to a given waypoint. */
    protected Waypoint (Waypoint origin, Settlement settlement, int x, int y) {
        super (settlement, x, y);
        if (origin == null) return;
        incident.add (origin);
        origin.incident.add (this);
    }

    /** Search for a waypoint in the road graph. */
    public abstract class LookFor implements Serializable {
        abstract boolean is (Waypoint lookedFor);
    }
    /** Breadth-first search of the road graph starting from (but
     * excluding) the current waypoint. Returns null if no waypoint
     * could be found, otherwise returns the road from the current
     * waypoint to the found waypoint. */
    Road breadthFirstSearch (LookFor lookedFor) {
        Queue<Road> queue = new LinkedList<Road> ();
        Set<Waypoint> visited = new HashSet<Waypoint> ();
        queue.add (new Road(this));
        visited.add (this);
        while (!queue.isEmpty ()) {
            Road current = queue.remove ();
            for (Waypoint wp : current.getLast().incident) {
                Road next = new Road (current, wp);
                if (lookedFor.is (wp)) return next;
                if (!visited.contains (wp)) {
                    queue.add (next); visited.add (wp);
                }
            }
        }
        return null;
    }
    /** Print position and congestion info. */
    public String toString () {
        return super.toString () +
            "~cong=" + congestion + "/" + throughput ();
    }
}
