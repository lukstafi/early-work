public class Stack<E> {
    public Stack() { /* ... */ }
    public void push(E e) { /* ... */ }
    public E pop() { /* ... */ }
    public boolean isEmpty() { /* ... */ }

    // Wildcard type for parameter that serves as an E producer
    public void pushAll(Iterable<? extends E> src) {
        for (E e : src)
            push(e);
    }
}

// ...

Stack<Number> numberStack = new Stack<Number>();
Iterable<Integer> integers = ... ;
numberStack.pushAll(integers);


public class Stack<E> {
    public Stack() { /* ... */ }
    public void push(E e) { /* ... */ }
    public E pop() { /* ... */ }
    public boolean isEmpty() { /* ... */ }

    // Wildcard type for parameter that serves as an E consumer
    public void popAll(Collection<? super E> dst) {
        while (!isEmpty())
            dst.add(pop());
    }
}

// ...

Stack<Number> numberStack = new Stack<Number>();
Collection<Object> objects = ... ;
numberStack.popAll(objects);

