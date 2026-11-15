public class Test {

    static void testSet (MySet<String> urSet) {
        MySet<String> set = urSet.empty();
        System.out.println ("set.isEmpty() = " + set.isEmpty());

        set.add ("Java");
        System.out.println ("set.add(\"Java\");");
        System.out.println ("set.isEmpty() = " + set.isEmpty());
        System.out.println ("set.hasElement(\"Java\") = " +
                            set.hasElement("Java"));
        System.out.println ("set.hasElement(\"beans\") = " +
                            set.hasElement("beans"));

        MySet<String> set2 = set.empty();
        set2.add ("beans");
        System.out.println ("set2.add(\"beans\");");
        set.union (set2);
        System.out.println ("set.union(set2);");
        System.out.println ("set2.hasElement(\"Java\") = " +
                            set2.hasElement("Java"));
        System.out.println ("set.hasElement(\"beans\") = " +
                            set.hasElement("beans"));

        set.add ("rocks");
        System.out.println ("set.add(\"rocks\");");
        System.out.println ("set.hasElement(\"rocks\") = " +
                            set.hasElement("rocks"));

        MySet<String> set3 = set.empty ();
        set3.add ("star");
        System.out.println ("set3.add(\"star\");");
        set3.union (set);
        System.out.println ("set3.union(set);");
        System.out.println ("set3.hasElement(\"beans\") = " +
                            set3.hasElement("beans"));
        System.out.println ("set3.hasElement(\"star\") = " +
                            set3.hasElement("star"));

    }
    static void testMap (MyMap<String,String> urMap) {
        MyMap<String,String> map = urMap.empty ();
        System.out.println ("map.isEmpty() = " + map.isEmpty());

        map.add ("k1", "v1");
        System.out.println ("map.add(\"k1\", \"v1\");");
        System.out.println ("map.isEmpty() = " + map.isEmpty());
        System.out.println ("map.hasKey(\"k1\") = " +
                            map.hasKey("k1"));
        System.out.println ("map.lookup(\"k1\") = " +
                            map.lookup("k1"));
        System.out.println ("map.hasKey(\"k2\") = " +
                            map.hasKey("k2"));
        System.out.println ("map.lookup(\"k2\") = " +
                            map.lookup("k2"));
        map.add ("k2", "v2");
        System.out.println ("map.add(\"k2\", \"v2\");");
        System.out.println ("map.hasKey(\"k2\") = " +
                            map.hasKey("k2"));
        String v2 = map.lookup("k2");
        System.out.println ("map.lookup(\"k2\") = " +
                            v2);

        
    }
        

    public static void main (String[] args) {
        System.out.println ("\nTesting MySetImpl.");
        testSet (new MySetImpl<String>());

        System.out.println ("\nTesting MyMapImpl.");
        testMap (new MyMapImpl<String,String>());
    }
}