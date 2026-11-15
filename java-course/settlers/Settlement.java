package settlers;

import java.util.*;
import java.io.*;

public enum Settlement implements Serializable {
    RED {
        Resources initialResources () { return new Resources (50, 10); }
    }, GREEN {
        Resources initialResources () { return new Resources (60, 8); }
    }, BLUE {
        Resources initialResources () { return new Resources (45, 15); }
    }, YELLOW {
        Resources initialResources () { return new Resources (55, 11); }
    };
    /** The initial resources available to a castle of a settlement. */
    abstract Resources initialResources ();
    
    /** The settlements that are in the game, together with their
     * castles. There should be exactly one castle per settlement in
     * the game. */
    public static Map<Settlement, Castle> castles =
        new HashMap<Settlement, Castle> ();
}