public class Lec6c {

    static class FishOrVegs {

        public void plate () {

            System.out.println ("Fish on a plate.");

        }

    }

    static class Vegetables extends FishOrVegs {

        public void plate () {

            System.out.println ("Plate of vegetables.");

        }

    }

    static class Vegetarian {

        public void eat (Vegetables vegs) {
            System.out.print ("Vegetarian: ");
            vegs.plate();

            }

    }

    static class Pescatarian extends Vegetarian {

        public void eat (FishOrVegs fish) {
            System.out.print ("Pescatarian: ");
            fish.plate();

        }

    }

    public static void main (String[] args) {
        
        (new Pescatarian ()).eat (new Vegetables ());

    }}
