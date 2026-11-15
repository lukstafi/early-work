package settlers;
import java.io.*;

/** A record of possible resources. */
public class Resources implements Serializable {
    public static enum Resource implements Serializable {
        WOOD {
            void set (Resources r, int v) {
                r.wood = v;
            }
            void add (Resources r, int v) {
                r.wood += v;
            }
            int get (Resources r) {
                return r.wood;
            }
        }, STONE {
            void set (Resources r, int v) {
                r.stone = v;
            }
            void add (Resources r, int v) {
                r.stone += v;
            }
            int get (Resources r) {
                return r.stone;
            }
        };
        abstract void set (Resources r, int v);
        abstract void add (Resources r, int v);
        abstract int get (Resources r);
    }
        
    public static final Resources ZERO = new Resources (0, 0);
    
    public int wood = 0, stone = 0;

    public int sum () {
        return wood + stone;
    }

    public void add (Resources r) {
        wood += r.wood;
        stone += r.stone;
    }

    public void subtract (Resources r) {
        wood -= r.wood;
        stone -= r.stone;
     }

    public Resources difference (Resources r) {
        return new Resources (wood - r.wood, stone - r.stone);
    }

    /** Return a new resources bundle that is a resource-wise minimum
     * of current resources and given resources. */
    public Resources upTo (Resources r) {
        return new Resources (Math.min (wood, r.wood),
                              Math.min (stone, r.stone));
    }

    public void dropNegative () {
        wood = Math.max (wood, 0);
        stone = Math.max (stone, 0);
    }

    public boolean isNegative () {
        return wood < 0; // && stone < 0; etc.
    }

    public boolean lessThan (Resources r) {
        return wood < r.wood && stone < r.stone;
    }

    public Resource maximal () {
        if (wood >= stone)
            return Resource.WOOD;
        else
            return Resource.STONE;
    }

    public Resources (int wood, int stone) {
        this.wood = wood;
        this.stone = stone;
    }

    public String toString () {
        return "{wood="+wood+ "; stone="+stone+
            "}";
    }
}