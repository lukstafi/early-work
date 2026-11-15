package settlers;

import java.util.*;
import java.io.*;

/** A scheduler manages the progress of a simulation by keeping a
 * queue of actions to be performed at given times. */
public class Scheduler implements Serializable {
    /** Scheduled actions ordered by their completion time. */
    PriorityQueue<Action> tasks = new PriorityQueue<Action> ();

    private int numOfSettlers = 0;
    public int getNextSettler () {
        return numOfSettlers++;
    }

    private int clockTime = 0;

    /** The time is read-only from the outside. */
    public int getTime () { return clockTime; }

    /** Opportunity to match simulated time with real time. */
    public void wait (int delay) { }

    public void schedule (Action a) {
        tasks.add (a);
    }

    /** An action is performed at its scheduled time, according to the
     * scheduler's simulated clock time. Action is an inner class so
     * that it can use delay times in its API. */
    public abstract class Action implements Comparable<Action>, Serializable {
        private int atTime;
        public int compareTo (Action a) { return atTime - a.atTime; }
        
        Action (int delay) {
            atTime = clockTime + delay;
        }
        void reschedule (String reason, int delay) {
            System.out.println ("At "+clockTime+
                                ": rescheduling because "+reason);
            atTime = clockTime + delay;
            schedule (this);
        }
        /** The action performed at scheduled time. */
        abstract void run ();
    }

    public void run () {
        while (!tasks.isEmpty ()) {
            Action action = tasks.poll ();
            int delay = action.atTime - clockTime;
            if (delay < 0) {
                signalMessage
                    ("Action "+action+" scheduled in the past -- ignoring.");
                continue;
            }
            if (delay > 0) wait (delay);
            clockTime = action.atTime;
            action.run ();
        }
    }

    /** Display a message prominently. */
    void signalMessage (String message) {
        // for now, just print it
        System.out.println ("!!! " + message);
    }

    /** Display a message non-intrusively. */
    void displayMessage (String message) {
        // for now, just print it
        System.out.println (message);
    }
}
            