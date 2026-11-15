public class Lec6 {

    class Fruit { }

    class Apple extends Fruit {
        public void bite () {
            System.out.println ("Apple.bite");
        }
    }

    class Farmer {
        public Apple foo () {
            return new Apple();
        }
    }

    class Gardener extends Farmer {
        public Fruit foo () {
            return new Fruit();
        }
    }

    static void bar (Farmer a) {
        Apple y = a.foo ();
        y.zoom ();
    }

    public static void main (String[] args) {
        bar (new Gardener ());
    }
}