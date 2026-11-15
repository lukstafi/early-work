public class Lec6a {

    static class Fruit { }

    static class Apple extends Fruit {
        public void bite () {
            System.out.println ("Apple.bite");
        }
    }

    static class Farmer {
        public Fruit sell () {
            return new Fruit();
        }
    }

    static class Gardener extends Farmer {
        public Apple sell () {
            return new Apple();
        }
    }

    static void tasteFrom (Farmer f) {
        Fruit a = f.sell ();
        // a.bite ();
    }

    public static void main (String[] args) {
        tasteFrom (new Gardener ());
    }
}