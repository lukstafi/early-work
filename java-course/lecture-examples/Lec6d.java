
    class FishOrVegs {

        public void plate () {

            System.out.println ("Fish on a plate.");

        }

    }

    class Vegetables extends FishOrVegs {

        public void plate () {

            System.out.println ("Plate of vegetables.");

        }

    }

    class Vegetarian {

        public void eat (Vegetables vegs) {

            System.out.print ("Vegetarian: ");

            vegs.plate();

        }

    }

    class Pescatarian extends Vegetarian {

        public void eat (FishOrVegs fish) {

            System.out.print ("Pescatarian: ");

            fish.plate();

        }

        public void eat (Vegetables vegs) {

            eat ((FishOrVegs)vegs);

        }

    }


public class Lec6d {

    public static void main (String[] args) {

        Vegetarian client = new Pescatarian();

        client.eat (new Vegetables ());

    }}
