<TeXmacs|1.0.7.7>

<style|exam>

<\body>
  <class|Course of Programming in Java><title-date|due Oct 14, 2011>

  <\title>
    Classes and Objects
  </title>

  Write a program, which will print on standard output <verbatim|System.out>
  a prime factorization for numbers given as command-line arguments.
  Factorization of each of the numbers should be printed in a separate line:
  first the given number, then the <verbatim|=> sign, then the factors
  separated by <verbatim|*>.

  Command-line parameters of the program invocation should be integer
  numbers. Invalid argument format should be reported on the standard error
  stream <verbatim|System.err>. If the program was called without any
  argument, it should print a help message on the error stream.

  To solve the task, you shuld define a helper class <verbatim|PrimeNumbers>.
  The class should contain only two, static, methods: <verbatim|isPrime()>
  and <verbatim|toPrimeFactors()>. Use the <em|sieve of Eratosthenes>
  algorithm, modified to store the smallest factor of each number (it will be
  helpful when computing the factorization). The functions should work for
  all numbers of the <verbatim|long> type (remember that you cannot create
  such a huge sieve, so find an algorithmic workaround). The
  <verbatim|PrimeNumbers> class should be defined in such a way that its
  instances cannot be built.

  \;

  <\code*>
    public class PrimeNumbers

    {

    \ \ protected final ststic int POWER_OF_2 = 21 ;

    \ \ protected final static long[] SIEVE = new
    long[1\<less\>\<less\>POWER_OF_2] ;

    \ \ // ... initialization block for the sieve needed ...\ 

    \ \ public static boolean isPrime (long x)

    \ \ { /* ... */ }

    \ \ public static long[] toPrimeFactors (long x)

    \ \ { /* ... */ }

    }
  </code*>

  \;

  Factorization of a negative number should start from the factor -1. The
  program should handle the numbers -9223372036854775808 and
  9223372036854775783 correctly. The prime factorization of -1 and 1 should
  be -1 and 1 respectively.

  <em|The program should be compiled and run from the command line.>

  <strong|Hint.> A compound number <math|n> has at least one prime factor,
  which is <math|\<leqslant\><sqrt|n>>.
</body>

<\initial>
  <\collection>
    <associate|language|american>
    <associate|page-screen-height|990208tmpt>
    <associate|page-screen-width|976896tmpt>
    <associate|sfactor|4>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
    <associate|auto-2|<tuple|2|?>>
  </collection>
</references>