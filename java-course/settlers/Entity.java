package settlers;
import java.io.*;

/** An object that should be shown on the territory. */
public abstract class Entity implements Serializable {
    /** Position on the territory. Should be within range
     * (0,0)..(MAX_X,MAX_Y). */
    int x, y;
    /** Maximal range of an entity's position. */
    static final int MAX_X = 100, MAX_Y = 100;
    /** Settlement to which an entity belongs, if any. */
    Settlement settlement;

    /** Create a new entity with position wrapped to within the range. */
    Entity (Settlement settlement, int x, int y) {
        this.settlement = settlement;
        this.x = x % MAX_X;
        this.y = y % MAX_Y;
    }

    /** Distance between two entities, rounded down. */
    int distance (Entity to) {
        int dx = to.x - x, dy = to.y - y;
        return (int) Math.round (Math.sqrt (dx*dx + dy*dy));
    }

    /** Print position. */
    public String toString () {
        return "(" + x + "," + y +")";
    }

    /** Set position to match that of another entity. */
    void setPosition (Entity p) {
        x = p.x; y = p.y;
    }
}
