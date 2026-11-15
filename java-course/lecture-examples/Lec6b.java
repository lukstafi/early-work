public class Lec6b {

    static class Vegetables {

        public void plate () {

            System.out.println ("Plate of vegetables.");

        }

    }

    static class FishWithVegs extends Vegetables {

        public void plate () {

            System.out.println ("Fish on a plate.");

        }

    }

    static class Vegetarian {

        public void eat (Vegetables vegs) {

            vegs.plate();

        }

    }

    static class Pescatarian extends Vegetarian {

        public void eat (FishWithVegs fish) {

            fish.plate();

        }

    }

    public static void main (String[] args) {
        
        (new Vegetarian ()).eat (new FishWithVegs ());

    }}
