package settlers;
import java.util.*;
import java.io.*;

class SelectSettlement extends JDialog {
    
    public MyDialog(JFrame parent) {
        super(parent, "Select settlement party", true);
        setLayout(new FlowLayout());
        add(new JLabel("Here is my dialog"));
        JButton ok = new JButton("OK");
        ok.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    dispose(); // Closes the dialog
                }
            });
        add(ok);
        setSize(150,125);
    }
}


/** Set-up and run a simulation. Either create simulation from scratch
 * or deserialize from a file.
 *
 * Arguments: (create | restore | load | GUI) file-name. */
public class Main {
    static Castle loadSettlers (Scheduler scheduler, Reader file) {
        Scanner setup = new Scanner (file);
        Castle castle;
        Settlement sttl;
        Waypoint[][] board = new Waypoint[Entity.MAX_X][Entity.MAX_Y];
        if (setup.hasNext ()) {
            String what = setup.next ();
            if (what.equals ("RED"))
                sttl = Settlement.RED;
            else if (what.equals ("GREEN"))
                sttl = Settlement.GREEN;
            else if (what.equals ("BLUE"))
                sttl = Settlement.BLUE;
            else if (what.equals ("YELLOW"))
                sttl = Settlement.YELLOW;
            else {
                System.out.println ("Castle color expected.");
                return null;
            }
            int x, y;
            if (setup.hasNextInt ())
                x = setup.nextInt ();
            else {
                System.out.println ("Castle x position expected.");
                return null;
            }
            if (setup.hasNextInt ())
                y = setup.nextInt ();
            else {
                System.out.println ("Castle y position expected.");
                return null;
            }
            castle = Castle.buildCastle (scheduler, sttl, x, y);
            board[x][y] = castle;
        } else {
            System.out.println ("Castle color expected.");
            return null;
        }
        while (setup.hasNext ()) {
            String what = setup.next ();
            if (what.equals ("Flag") || what.equals ("Warehouse")) {
                int x, y;
                if (setup.hasNextInt ())
                    x = setup.nextInt ();
                else {
                    System.out.println (what+" x position expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    y = setup.nextInt ();
                else {
                    System.out.println (what+" y position expected.");
                    return null;
                }
                if (!(setup.hasNext () && setup.next().equals ("origin"))) {
                    System.out.println ("Origin of "+what+" expected.");
                    return null;
                }
                int ox, oy;
                if (setup.hasNextInt ())
                    ox = setup.nextInt ();
                else {
                    System.out.println (what+" origin x position expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    oy = setup.nextInt ();
                else {
                    System.out.println (what+" origin y position expected.");
                    return null;
                }
                if (what.equals ("Flag"))
                    board[x][y] = new Flag (board[ox][oy], sttl, x, y);
                if (what.equals ("Warehouse"))
                    board[x][y] = new Warehouse
                        (scheduler, board[ox][oy], sttl, x, y);
                
            } else if (what.equals ("RoadSegment")) {
                int x, y;
                if (setup.hasNextInt ())
                    x = setup.nextInt ();
                else {
                    System.out.println (what+" x position expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    y = setup.nextInt ();
                else {
                    System.out.println (what+" y position expected.");
                    return null;
                }
                if (!(setup.hasNext () && setup.next().equals ("to"))) {
                    System.out.println
                        ("<to> after <RoadSegment "+x+" "+y+"> expected.");
                    return null;
                }
                int ox, oy;
                if (setup.hasNextInt ())
                    ox = setup.nextInt ();
                else {
                    System.out.println (what+" <to> x position expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    oy = setup.nextInt ();
                else {
                    System.out.println (what+" <to> y position expected.");
                    return null;
                }
                board[x][y].roadSegment (board[ox][oy]);
            } else if (what.equals ("Redistribute")) {
                int x, y;
                if (setup.hasNextInt ())
                    x = setup.nextInt ();
                else {
                    System.out.println (what+" x position expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    y = setup.nextInt ();
                else {
                    System.out.println (what+" y position expected.");
                    return null;
                }
                if (!(setup.hasNext () && setup.next().equals ("delays"))) {
                    System.out.println
                        ("<delays> after <Redistribute "+x+" "+y+"> expected.");
                    return null;
                }
                int sDelay, lDelay;
                if (setup.hasNextInt ())
                    sDelay = setup.nextInt ();
                else {
                    System.out.println (what+" short delay expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    lDelay = setup.nextInt ();
                else {
                    System.out.println (what+" long delay expected.");
                    return null;
                }
                ((Warehouse)board[x][y]).redistributeAll (sDelay, lDelay);
            } else if (what.equals ("Carriers")) {
                int num;
                if (setup.hasNextInt ())
                    num = setup.nextInt ();
                else {
                    System.out.println (what+" number expected.");
                    return null;
                }
                for (int i = 0; i < num; i++)
                    castle.createCarrier ();
                
            } else {
                System.out.println
                    ("Unknown command "+what+
                     ", expected one of: "+
                     "Flag, Warehouse, RoadSegment, Redistribute, Carriers");
            }
        }
        return castle;
    }
    static Castle guiCreateSettlers (Scheduler scheduler, Reader file) {
        Scanner setup = new Scanner (file);
        Castle castle;
        Settlement sttl;
        Waypoint[][] board = new Waypoint[Entity.MAX_X][Entity.MAX_Y];
        
        if (setup.hasNext ()) {
            String what = setup.next ();
            if (what.equals ("RED"))
                sttl = Settlement.RED;
            else if (what.equals ("GREEN"))
                sttl = Settlement.GREEN;
            else if (what.equals ("BLUE"))
                sttl = Settlement.BLUE;
            else if (what.equals ("YELLOW"))
                sttl = Settlement.YELLOW;
            else {
                System.out.println ("Castle color expected.");
                return null;
            }
            int x, y;
            if (setup.hasNextInt ())
                x = setup.nextInt ();
            else {
                System.out.println ("Castle x position expected.");
                return null;
            }
            if (setup.hasNextInt ())
                y = setup.nextInt ();
            else {
                System.out.println ("Castle y position expected.");
                return null;
            }
            castle = Castle.buildCastle (scheduler, sttl, x, y);
            board[x][y] = castle;
        } else {
            System.out.println ("Castle color expected.");
            return null;
        }
        while (setup.hasNext ()) {
            String what = setup.next ();
            if (what.equals ("Flag") || what.equals ("Warehouse")) {
                int x, y;
                if (setup.hasNextInt ())
                    x = setup.nextInt ();
                else {
                    System.out.println (what+" x position expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    y = setup.nextInt ();
                else {
                    System.out.println (what+" y position expected.");
                    return null;
                }
                if (!(setup.hasNext () && setup.next().equals ("origin"))) {
                    System.out.println ("Origin of "+what+" expected.");
                    return null;
                }
                int ox, oy;
                if (setup.hasNextInt ())
                    ox = setup.nextInt ();
                else {
                    System.out.println (what+" origin x position expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    oy = setup.nextInt ();
                else {
                    System.out.println (what+" origin y position expected.");
                    return null;
                }
                if (what.equals ("Flag"))
                    board[x][y] = new Flag (board[ox][oy], sttl, x, y);
                if (what.equals ("Warehouse"))
                    board[x][y] = new Warehouse
                        (scheduler, board[ox][oy], sttl, x, y);
                
            } else if (what.equals ("RoadSegment")) {
                int x, y;
                if (setup.hasNextInt ())
                    x = setup.nextInt ();
                else {
                    System.out.println (what+" x position expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    y = setup.nextInt ();
                else {
                    System.out.println (what+" y position expected.");
                    return null;
                }
                if (!(setup.hasNext () && setup.next().equals ("to"))) {
                    System.out.println
                        ("<to> after <RoadSegment "+x+" "+y+"> expected.");
                    return null;
                }
                int ox, oy;
                if (setup.hasNextInt ())
                    ox = setup.nextInt ();
                else {
                    System.out.println (what+" <to> x position expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    oy = setup.nextInt ();
                else {
                    System.out.println (what+" <to> y position expected.");
                    return null;
                }
                board[x][y].roadSegment (board[ox][oy]);
            } else if (what.equals ("Redistribute")) {
                int x, y;
                if (setup.hasNextInt ())
                    x = setup.nextInt ();
                else {
                    System.out.println (what+" x position expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    y = setup.nextInt ();
                else {
                    System.out.println (what+" y position expected.");
                    return null;
                }
                if (!(setup.hasNext () && setup.next().equals ("delays"))) {
                    System.out.println
                        ("<delays> after <Redistribute "+x+" "+y+"> expected.");
                    return null;
                }
                int sDelay, lDelay;
                if (setup.hasNextInt ())
                    sDelay = setup.nextInt ();
                else {
                    System.out.println (what+" short delay expected.");
                    return null;
                }
                if (setup.hasNextInt ())
                    lDelay = setup.nextInt ();
                else {
                    System.out.println (what+" long delay expected.");
                    return null;
                }
                ((Warehouse)board[x][y]).redistributeAll (sDelay, lDelay);
            } else if (what.equals ("Carriers")) {
                int num;
                if (setup.hasNextInt ())
                    num = setup.nextInt ();
                else {
                    System.out.println (what+" number expected.");
                    return null;
                }
                for (int i = 0; i < num; i++)
                    castle.createCarrier ();
                
            } else {
                System.out.println
                    ("Unknown command "+what+
                     ", expected one of: "+
                     "Flag, Warehouse, RoadSegment, Redistribute, Carriers");
            }
        }
        return castle;
    }
    public static void main (String[] args) {

        Castle castle;
        if (args[0].equals("create")) {
            System.out.println ("Creating file "+args[1]+"...");
            Scheduler scheduler = new Scheduler ();

            // Here we set up the simulation, something that should be
            // done with a user interface.
            // A shorthand for the settlement we'll build.
            Settlement sttl = Settlement.RED;
            // The main building -- castle;
            castle = Castle.buildCastle (scheduler, sttl, 20, 20);
            // Put in some settlers
            for (int i = 0; i < 12; i++)
                castle.createCarrier ();
            // Now create some flags and two warehouses.
            Flag wp1 = new Flag (castle, sttl, 20, 25);
            Flag wp2 = new Flag (wp1, sttl, 15, 30);
            Flag wp3 = new Flag (wp1, sttl, 25, 30);
            // wp2.roadSegment (wp3);
            Warehouse wh1 = new Warehouse (scheduler, wp2, sttl, 15, 35);
            Warehouse wh2 = new Warehouse (scheduler, wp3, sttl, 25, 35);
            wh1.roadSegment (wh2);
            // set up some action -- just redistribution for now
            castle.redistributeAll (5, 30);
            wh1.redistributeAll (5, 50);

            try {
                ObjectOutputStream out = new ObjectOutputStream
                    (new FileOutputStream(args[1]));
                out.writeObject(castle);
                out.close(); // Also flushes output
            } catch (IOException e) {
                System.out.println
                    ("ERROR: Could not write simulation state.");
                e.printStackTrace();
                return;
            }
        } else if (args[0].equals("restore")) {
            System.out.println ("Restoring from file "+args[1]+"...");
            try {
                ObjectInputStream in = new ObjectInputStream
                    (new FileInputStream(args[1]));
                castle = (Castle)in.readObject();
            } catch (IOException e) {
                System.out.println
                    ("ERROR: Could not read simulation state.");
                e.printStackTrace();
                return;
            } catch (ClassNotFoundException e) {
                System.out.println
                    ("ERROR: Could not restore simulation state.");
                return;
            }
        } else if (args[0].equals("load")) {
            System.out.println ("Loading from readable file "+args[1]+"...");
            BufferedReader file;
            try {
                file = new BufferedReader
                    (new FileReader(new File(args[1]).getAbsoluteFile()));
            } catch(IOException e) {
                System.out.println ("ERROR: Could not open setup file.");
                return;
            }
            Scheduler scheduler = new Scheduler ();
            castle = loadSettlers (scheduler, file);
            if (castle == null) {
                System.out.println ("ERROR: Error in setup file.");
                return;
            }
        } else if (args[0].equals("GUI")) {

        } else {
            System.out.println ("Unknown command "+args[0]);
            return;
        }
        castle.scheduler.run ();
    }
}