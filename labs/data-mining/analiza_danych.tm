<TeXmacs|1.0.6.10>

<style|seminar>

<\body>
  <doc-data|<doc-title|Elementy analizy danych>|<doc-subtitle|w programach
  Octave i R>>

  <section|Wprowadzenie do j¦zyków Octave i R>

  <subsection|Pomoc>

  <\itemize>
    <item>Pomoc na temat funkcji / zagadnienia

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    help nazwa>>|<row|<cell|>>>>>>>|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    help ("nazwa")>>|<row|<cell|\<gtr\> help (nazwa)>>|<row|<cell|\<gtr\>
    ?nazwa>>>>>>>>>>>

    <item>Kategorie pomocy (lista pakietów i funkcji)

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|\<gtr\>
    help>>|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    library() #dost¦pne pakiety>>|<row|<cell|\<gtr\> search() \ #zaªadowane
    pakiety>>|<row|<cell|\<gtr\> help(package="nazwa")>>>>>>>>>>>

    <item>Przeszukiwanie pomocy

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<tabular|<tformat|<table|<row|<cell|tylko
    nagªówki pomocy:>>|<row|<cell|<verbatim|\<gtr\> lookfor
    "klucz">>>|<row|<cell|caªa pomoc:>>|<row|<cell|<verbatim|\<gtr\> lookfor
    -all "klucz">>>>>>>|<cell|<verbatim|\<gtr\> help.search("klucz")>>>>>>

    <item><block|<tformat|<twith|table-width|200>|<twith|table-hmode|exact>|<table|<row|<cell|Octave:
    znajd¹ w podr¦czniku>|<cell|R: przekieruj pomoc do
    przegl¡darki>>|<row|<cell|<verbatim|\<gtr\> doc
    "nazwa">>|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    options(browser="firefox")>>|<row|<cell|\<gtr\> help.start()>>>>>>>>>>>

    <item>Przykªadowe zastosowanie funkcji

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    example nazwa>>|<row|<cell|\<gtr\> example
    ('nazwa')>>>>>>>|<cell|<verbatim|\<gtr\> example(nazwa)>>>>>>

    <item>Dost¦pne zmienne/obiekty

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<tabular|<tformat|<table|<row|<cell|krótko:>>|<row|<cell|<verbatim|\<gtr\>
    who>>>|<row|<cell|z opisem:>>|<row|<cell|<verbatim|\<gtr\>
    whos>>>>>>>|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    objects()>>|<row|<cell|\<gtr\> ls()>>>>>>>>>>>

    <item>W <strong|Octave> dodaj¡c ±rednik blokujemy wydrukowanie rezultatu
    operacji. (Pisz¡c skrypt lub funkcj¦ mo»emy monitorowa¢ ich dziaªanie, a
    gdy wszystko jest OK, doda¢ wsz¦dzie ±redniki.)

    <item>Komentarz rozpoczyna si¦ od znaku <verbatim|#> (w Octave te» od
    znaku <verbatim|%>).<new-page>
  </itemize>

  <subsection|Podstawowe typy warto±ci>

  <\itemize>
    <item>W <strong|Octave> mamy trzy podstawowe struktury danych: macierze,
    tablice dowolnych elementów (cell arrays) i struktury z notacj¡ kropkow¡.
    Liczby, wektory i stringi funkcjonuj¡ jako macierze odpowiedniego
    wymiaru.

    <\itemize>
      <item>Warto±ci logiczne, znaki alfanum., liczby rzeczywiste i zespolone
      tworz¡ jeden typ danych. (Wektor ze znakiem alfanum. jest wy±wietlany
      jako string.)
    </itemize>

    <item><strong|R> jest mocno typizowanym j¦zykiem. Posiada wektory,
    macierze, typ grupuj¡cy ``factors'', listy (odpowiednik cell arrays),
    ``ramki danych'' data frames: macierze, których kolumny mog¡ by¢ ró»nych
    typów (np. ª¡cz¡c typy wyliczeniowe i liczbowe), funkcje (jako warto±ci,
    jak w programowaniu funkcyjnym). Stringi s¡ wektorami.

    <\itemize>
      <item>R rozró»nia typy, tzw. ``mody'': liczbowy, liczb zespolonych,
      logiczny, znaków alfanum., ``raw'' (danych binarnych);
      <verbatim|mode(x)> zwraca mod danej warto±ci, np. <verbatim|complex>
      dla wektora liczb zespolonych

      <item>obiekty w R maj¡ te» swoje klasy (<verbatim|class(x)>) (niektóre
      funkcje dziaªaj¡ odpowiednio do klasy obiektu)
    </itemize>

    <item>W Octave i R stringi ograniczamy b¡d¹ znakiem <verbatim|">, b¡d¹
    <verbatim|'>

    <item>Specjalna warto±¢ <verbatim|NA> (not available) oznacza brakuj¡ce
    warto±ci. W Octave dost¦pna jest tylko dla typu liczbowego.

    <item>W <strong|R>, <verbatim|is.typ(x)> sprawdza czy <verbatim|x> jest
    typu <verbatim|typ>, <verbatim|as.typ(x)> konwertuje <verbatim|x> do typu
    <verbatim|typ>

    <item>W <strong|R> argumenty funkcji maj¡ nazwy, których mo»emy u»y¢ w
    czasie wywoªywania: <verbatim|f(nazwa=warto±¢)>
  </itemize>

  <new-page>

  <subsection|Podstawowe konstrukcje steruj¡ce>

  <\itemize>
    <item>W <strong|Octave> niektóre konstrukcje wymagaj¡ umieszczenia w
    jednej linii (np. przy wprowadzaniu macierzy koniec linii jest
    równoznaczny z <verbatim|;>), mo»emy kontynuowa¢ lini¦ dalej ko«cz¡c j¡
    znakiem <math|\<setminus\>>

    <item>Octave zaleca u»ywa¢ sªów kluczowych <verbatim|endif>,
    <verbatim|endwhile>, <verbatim|endfor> etc., ale akceptuje te»
    <verbatim|end>, jedyne akceptowane przez Matlaba.\ 

    <item><block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<tabular|<tformat|<table|<row|<cell|if-else-end
    w osobnych liniach<em|>>>|<row|<cell|statements mog¡ by¢
    wieloliniowe>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|if
    cond>>|<row|<cell| \ statements1>>|<row|<cell|else>>|<row|<cell|
    \ statements2>>|<row|<cell|endif>>>>>>>>|<row|<cell|wersja
    jednolinijkowa>>|<row|<cell|<verbatim|if cond, statm1; else statm2;
    end>>>>>>>|<cell|<tabular|<tformat|<table|<row|<cell|skªadnia jak w
    C:>>|<row|<cell|aby zgrupowa¢ instrukcje>>|<row|<cell|u»yj
    <verbatim|{...}>>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|if
    (cond) statement1>>|<row|<cell|else statement2>>>>>>>>>>>>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|while
    cond>>|<row|<cell| \ statements>>|<row|<cell|endwhile>>>>>>>|<cell|<verbatim|while
    (cond) statement>>>>>>

    <item>W Octave p¦tla <verbatim|for> przebiega po kolumnach macierzy, a w
    R po kolejnych elementach wektora/macierzy.

    Standardowa p¦tla to <verbatim|for i=1:n>/<verbatim|for (i in 1:n)>.

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<cwith|2|2|1|1|cell-valign|c>|<table|<row|<cell|\<gtr\>
    s = 0;>>|<row|<cell|\<gtr\> for i = [1,3;2,4]>>|<row|<cell| \ \ s = s +
    i;>>|<row|<cell| \ endfor>>|<row|<cell|\<gtr\> s>>|<row|<cell|s
    =>>|<row|<cell| \ \ 4>>|<row|<cell| \ \ 6>>>>>>>|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    s \<less\>- 0>>|<row|<cell|\<gtr\> y \<less\>- matrix (1:4, ncol=2,
    nrow=2)>>|<row|<cell|\<gtr\> for (i in y) s \<less\>-
    s+i>>|<row|<cell|\<gtr\> s>>|<row|<cell|[1] 10>>>>>>>>>>>
  </itemize>

  <new-page>

  <subsection|Funkcje, biblioteki, zapisywanie>

  <\itemize>
    <item>W <strong|Octave> wystarczy doda¢ ±cie»k¦ katalogu z plikami
    <verbatim|.m> aby odpowiadaj¡ce im funkcje lub skrypty byªy widoczne:
    <verbatim|addpath('/do/katalogu')>. Widoczne s¡ te» pliki z katalogu
    bie»¡cego.

    <item>W <strong|R> ªadujemy zainstalowany pakiet poprzez
    <verbatim|library('nazwa')>.

    <block|<tformat|<table|<row|<cell|Octave: instalowanie pakietu np. z
    Octave-forge>>|<row|<cell|<verbatim|\<gtr\> pkg install
    ~/Desktop/statistics-1.0.5.tar.gz>>>|<row|<cell|R: downloadowanie i
    instalowanie pakietu z CRAN>>|<row|<cell|<verbatim|\<gtr\>
    install.packages('UsingR')>>>>>>

    <item>W <strong|Octave> aby u»y¢ zmiennej wewn¡trz funkcji nie
    przekazuj¡c jej jako argumentu, musimy <em|zarówno na zewn¡trz, jak i w
    ±rodku funkcji> zadeklarowa¢ j¡ jako globaln¡: <verbatim|global
    x>.<new-page>

    <item>W <strong|Octave> mamy pliki skryptowe i pliki funkcyjne, obydwa z
    rozszerzeniem <verbatim|.m>. Pierwszy blok komentarzy w pliku jest
    udost¦pniany przez komend¦ <verbatim|help>. Plik skryptowy to dowolny
    ci¡g polece« Octave, odpalany jak komenda. Plik funkcyjny zaczyna si¦ od
    polecenia <verbatim|function> (OK te» w trybie interakt.):

    <block|<tformat|<table|<row|<cell|Octave: plik
    <verbatim|dotprod.m>>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|function
    xydot = dotprod (x, y)>>|<row|<cell|>>|<row|<cell|# usage: f (x,
    t)>>|<row|<cell|#>>|<row|<cell|# This function computes the dot
    product>>|<row|<cell|# of vectors x and
    y.>>|<row|<cell|>>|<row|<cell|xydot = x * y'
    ;>>|<row|<cell|>>|<row|<cell|endfunction>>>>>>>>>>>

    W Octave zaleca si¦ ko«czy¢ funkcje przez <verbatim|endfunction>, w
    Matlabie nie ko«czy si¦ funkcji. Nazwa pierwszej funkcji w pliku musi
    pokrywa¢ si¦ z nazw¡ pliku, pozostaªe funkcje s¡ lokalne (widoczne tylko
    w danym pliku).

    <item>W <strong|R> plikom skryptowym dajemy rozszerzenie <verbatim|.R> i
    uruchamiamy funkcj¡ <verbatim|source>. (Stan ±rodowiska o rozszerzeniu
    <strong|.RData> wczytuje <verbatim|load>.)

    <item>W <strong|R> funkcje, jak wszystkie inne warto±ci, przypisujemy
    nazwom:

    <block|<tformat|<table|<row|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    bslash \<less\>- function(X, y) {>>|<row|<cell| \ \ X \<less\>-
    qr(X)>>|<row|<cell| \ \ qr.coef(X, y)>>|<row|<cell| \ }>>>>>>>>>>>

    Nazwy uj¦te w <verbatim|%> s¡ operatorami infiksowymi, np.
    <verbatim|'%!%' \<less\>- function (X, y) {...}> i potem u»ycie
    <verbatim|X %!% y>.

    <item>Przed rozpocz¦ciem pracy, stwórz katalog dla projektu. Uruchom
    <strong|R> w tym katalogu. Zako«cz prac¦ komend¡ <verbatim|q()>, pozwala
    zapisa¢ stan sesji w bie»¡cym katalogu.

    <item>W <strong|Octave> mamy do dyspozycji uchwyty funkcji:

    <block|<tformat|<table|<row|<cell|Octave>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    f = @sin;>>|<row|<cell|\<gtr\> feval (f, pi/4)>>>>>>>>>>>

    oraz funkcje anonimowe (w R mamy je ``za darmo'' bo funkcje to warto±ci):

    <block|<tformat|<table|<row|<cell|Octave>>|<row|<cell|<verbatim|\<gtr\>
    quad (@(x) x.^2, 0, 10)>>>>>>
  </itemize>

  <new-page>

  <subsection|Wektory, macierze, struktury>

  <\itemize>
    <item>W <strong|Octave> macierze wprowadzamy w nawiasach kwadratowych
    <verbatim|[1,2,3;4,5,6]> oddzielaj¡c elementy wiersza przecinkiem a
    wiersze ±rednikiem. W <strong|R> polecenie <verbatim|c> tworzy wektor
    konkatenuj¡c podane elementy, <verbatim|matrix> wypeªnia tworzon¡ macierz
    elementami z (np. wektora) danych kolumna po kolumnie (lub dla
    <verbatim|byrow=TRUE>, wiersz po wierszu). W Octave skªadnia
    <verbatim|[a:b]> jest zawsze dopuszczalnym wariantem skªadni
    <verbatim|a:b>. Sprawd¹ nast¦puj¡ce przykªady:

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|\<gtr\>
    x = [0.1, 0.2, 0.3];>>|<cell|<verbatim|\<gtr\> x \<less\>- c(0.1, 0.2,
    0.3)>>>|<row|<cell|<verbatim|\<gtr\> [x, x]>>|<cell|<verbatim|\<gtr\>
    c(x, x)>>>|<row|<cell|<verbatim|\<gtr\> [x; x]>>|<cell|<verbatim|\<gtr\>
    matrix(c(x,x), 2, 3, byrow=TRUE)>>>|<row|<cell|<verbatim|\<gtr\>
    1:5>>|<cell|<verbatim|\<gtr\> 1:5>>>|<row|<cell|<verbatim|\<gtr\>
    1:pi:9>>|<cell|<verbatim|\<gtr\> seq(1, 9,
    by=pi)>>>|<row|<cell|<verbatim|\<gtr\> linspace(0, 5,
    9)>>|<cell|<verbatim|\<gtr\> seq(0, 5, length=9)>>>>>>

    <item>W Octave macierze (w R tylko wektory) maj¡ automatycznie
    dostosowywany rozmiar; wektory i macierze s¡ indeksowane od 1.

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    x = 5;>>|<row|<cell|\<gtr\> x(2) = 7;>>|<row|<cell|\<gtr\> x(2,2) =
    3>>|<row|<cell|x =>>|<row|<cell| \ 5 7>>|<row|<cell| \ 0
    3>>>>>>>|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\> x
    \<less\>- 5>>|<row|<cell|\<gtr\> x[3] \<less\>- 7>>|<row|<cell|\<gtr\>
    x>>|<row|<cell|[1] \ 5 NA \ 7>>>>>>>>>>>

    <item>Przewymiarowywanie i konkatenacja macierzy. W R macierzami
    (matrices) nazywa si¦ tylko tablice (arrays) dwuwymiarowe.
    <verbatim|matrix> i <verbatim|array> w R ``recykluje'' warto±ci je±li ich
    brakuje w wektorze.

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    A = reshape (1:12, [2,2,3])>>|<row|<cell|\<gtr\>
    A(2,1,3)>>|<row|<cell|ans =>>|<row|<cell|
    \ 10>>>>>>>|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\> A
    \<less\>- array(1:7,c(2,2,3))>>|<row|<cell|\<gtr\>
    A(2,1,3)>>|<row|<cell|[1] 3>>>>>>>>|<row|<cell|<verbatim|\<gtr\>
    [1,2,3;4,5,6]'>>|<cell|<verbatim|\<gtr\>
    t(matrix(1:6,2,3))>>>|<row|<cell|<verbatim|\<gtr\> B =
    ((1:5)+1)'>>|<cell|<verbatim|\<gtr\> B \<less\>-
    as.matrix(1:5+1)>>>|<row|<cell|<verbatim|\<gtr\>
    [B-1,B]>>|<cell|<verbatim|\<gtr\> cbind(B-1,B)>>>|<row|<cell|<verbatim|\<gtr\>
    [B'-1; B']>>|<cell|<verbatim|\<gtr\> rbind(t(B)-1,t(B))>>>|<row|<cell|<verbatim|\<gtr\>
    A(:) \ #spªaszczenie macierzy>>|<cell|<verbatim|\<gtr\> c(A)>>>>>>

    <item>Funkcje/operacje liczbowe i logiczne na wektorach i macierzach w R
    s¡ zazwyczaj dokonywane skªadowa-po-skªadowej.

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|\<gtr\>
    sin(B)>>|<cell|<verbatim|\<gtr\> sin(B)>>>|<row|<cell|<verbatim|\<gtr\> B
    .* B>>|<cell|<verbatim|\<gtr\> B * B>>>|<row|<cell|<verbatim|\<gtr\> B' *
    B>>|<cell|<verbatim|\<gtr\> t(B) %*% B>>>|<row|<cell|<verbatim|\<gtr\> B
    ./ B>>|<cell|<verbatim|\<gtr\> B / B>>>|<row|<cell|<verbatim|\<gtr\> (B *
    B') / B'>>|<cell|>>|<row|<cell|<verbatim|\<gtr\>
    A<math|\<setminus\>>b>>|<cell|<verbatim|\<gtr\>
    solve(A,b)>>>|<row|<cell|<verbatim|(1:5)' *
    (1:5)>>|<cell|<verbatim|\<gtr\> 1:5 %o% 1:5>>>>>>

    <item>Przykªady generowania stringów

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    B(1:10,1)='X'>>|<row|<cell|\<gtr\> B(1:10,2)=char([1:10]+96)>>>>>>>|<cell|<verbatim|paste(c('X','Y'),1:10,sep='')>>>>>><new-page>

    <item>Octave i R pozwalaj¡ na <strong|indeksowanie wektorów i macierzy>
    przy pomocy:

    <\itemize>
      <item>wektora/macierzy z warto±ciami logicznymi: prawda oznacza
      ``doª¡cz element z tej pozycji'', faªsz oznacza ``omi«''

      <item>wektora liczb caªkowitych dodatnich oznaczaj¡cych pozycje,
      oznacza ``doª¡cz elementy z wymienionych pozycji, w tym porz¡dku''

      <item>''operatora'' selekcji caªego wymiaru (wiersza, kolumny)

      <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|\<gtr\>
      B(:,1)>>|<cell|<verbatim|\<gtr\> B[,1]>>>|<row|<cell|<verbatim|\<gtr\>
      B(2,:)>>|<cell|<verbatim|\<gtr\> B[2,]>>>>>>
    </itemize>

    <strong|R> pozwala:

    <\itemize>
      <item>u»y¢ ujemnych liczb caªkowitych na oznaczenie pozycji, które
      chcemy wykluczy¢ (np. <verbatim|x[-(1:5)]> -- z pomini¦ciem poz. 1-5)

      <item>u»y¢ stringów, je±li pozycje wektora/macierzy s¡ nazwane, np.

      <block|<tformat|<table|<row|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
      fruit \<less\>- c(5, 10, 1, 20)>>|<row|<cell|\<gtr\> names(fruit)
      \<less\>- c('orange','banana','apple','peach')>>|<row|<cell|\<gtr\>
      lunch \<less\>- fruit[c('apple','orange')]>>>>>>>>>>>

      <item>specjalny mechanizm grupowania pozwala podzieli¢ elementy wektora
      na klasy i dziaªa¢ osobno na tych klasach: gdy <verbatim|x> to wektor
      klas przyporz¡dkowuj¡cy pozycje klasom, a <verbatim|y> to warto±ci
      liczbowe poszczególnych pozycji,

      <block|<tformat|<table|<row|<cell|R: <verbatim|x> -- klasy obserwacji,
      <verbatim|z> -- warto±ci obserwacji>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
      fx = factor(x)>>|<row|<cell|\<gtr\> m = tapply (z, fx,
      mean)>>>>>>±rednie warto±ci dla klas>>>>>

      <verbatim|levels(fx)> zwraca wektor klas. <verbatim|by> dziaªa na
      caªych data.frames. <verbatim|tapply> i <verbatim|by> zwracaj¡ list¦
      wyników indeksowan¡ klasami.
    </itemize>

    <item>Wektory i macierze mo»na modyfikowa¢ na zaindeksowanych pozycjach
    przy pomocy operatora przypisania, np.

    <verbatim|y(y\<less\>0) = 0>, odpow. <verbatim|y[y\<less\>0] \<less\>- 0>

    <\itemize>
      <item>praw¡ stron¡ mo»e by¢ wektor/macierz odpowiadaj¡cy rozmiarem
      wektorowi/macierzy powstaªemu przez wybranie wskazanych pozycji, np.
      <verbatim|y[y\<less\>0] \<less\>- -y[y\<less\>0]> albo
      <verbatim|A(2:2:6,:)=y(1:2:5,:)>
    </itemize>

    <new-page>

    <item>W Octave s¡ ``tablice komórkowe'' cell arrays, w R s¡ listy. P¦tla
    <verbatim|for> iteruje je tak samo jak macierze (Octave) / wektory (R).

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    A = {1,'alfa';'beta',2}>>|<row|<cell|A =>>|<row|<cell|{>>|<row|<cell|
    \ [1,1] = 1>>|<row|<cell| \ [2,1] = beta>>|<row|<cell| \ [1,2] =
    alfa>>|<row|<cell| \ [2,2] = 2>>|<row|<cell|}>>|<row|<cell|\<gtr\>
    A{1,2}>>|<row|<cell|ans = alfa>>|<row|<cell|\<gtr\> A{3,3} = 3
    \ #A{3,1}=[]>>>>>>>|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    A \<less\>- list(1,'alfa','beta',2)>>|<row|<cell|[[1]]>>|<row|<cell|[1]
    1>>|<row|<cell|>>|<row|<cell|[[2]]>>|<row|<cell|[1]
    'alfa'>>|<row|<cell|...>>|<row|<cell|\<gtr\> A[[3]]>>|<row|<cell|[1]
    'beta'>>|<row|<cell|\<gtr\> A[[6]] \<less\>- 3
    \ #A[[5]]=NULL>>>>>>>>>>><new-page>

    <item>Octave ma obiekty typu ``data structure'', ró»ne od
    macierzy/tablic. W R elementy list mog¡ mie¢ nazwy (ale ci¡gle s¡
    pozycyjne); indeksowanie ``wektorowe'' zwraca list¦ jedno-elementow¡.
    (<em|Kropka jest cz¦±ci¡ nazw (jak litery) w <strong|R>> -- zamiast niej
    u»ywa si¦ <verbatim|$>.)

    <block|<tformat|<table|<row|<cell|Octave>|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    x.a = 1>>|<row|<cell|\<gtr\> x.b = [1,3;2,4]>>|<row|<cell|\<gtr\> x.c =
    'string'>>|<row|<cell|x =>>|<row|<cell|{>>|<row|<cell| \ a =
    1>>|<row|<cell| \ b =>>|<row|<cell| \ \ \ 1 \ 3>>|<row|<cell| \ \ \ 2
    \ 4>>|<row|<cell| \ c = string>>|<row|<cell|}>>>>>>>|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    x \<less\>- list(a=1,b=matrix(1:4,2,2))>>|<row|<cell|\<gtr\> x$c
    \<less\>- 'string'>>|<row|<cell|\<gtr\>
    x>>|<row|<cell|$a>>|<row|<cell|[1] 1>>|<row|<cell|$b>>|<row|<cell|
    \ \ \ \ [,1] [,2]>>|<row|<cell|[1,] \ \ \ 1
    \ \ \ 3>>|<row|<cell|...>>|<row|<cell|\<gtr\> x[[3]]>>|<row|<cell|[1]
    'string'>>|<row|<cell|\<gtr\> x[3]>>|<row|<cell|$c>>|<row|<cell|[1]
    'string'>>>>>>>>>>><new-page>

    <item>W <strong|R> mo»na skraca¢ nazw¦ pozycji tak dªugo, dopóki jest
    jednoznaczna, np. <verbatim|x$covariance> do <verbatim|x$cov>.

    <item>Konkatenacja ``wektorowa'' <verbatim|c> skleja listy (równie» z
    nazwami; przy indeksowaniu brane jest pierwsze wyst¡pienie danej nazwy).

    <item>W <strong|R> mo»na ``przyczepi¢'' list¦ z nazwami, udost¦pniaj¡c te
    nazwy w ±rodowisku: <verbatim|attach(x)>/<verbatim|detach(x)>.

    <item>W <strong|Octave> <verbatim|for> mo»e iterowa¢ po parach
    klucz-warto±¢:

    <block|<tformat|<table|<row|<cell|Octave>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|for
    [val, key] = expression>>|<row|<cell|
    \ statements>>|<row|<cell|endfor>>>>>>>>>>>

    <item>Specjaln¡ klas¡ list w <strong|R> s¡ ``ramki danych'' (data frames)
    (tworzenie: <verbatim|data.frame(nazwa=warto±¢,...)>), np. dodanie do
    ramki kolumny ze stringami skonwertuje j¡ automatycznie do typu
    kategorycznego ``factors''.
  </itemize>

  <new-page>

  <subsection|Wczytywanie danych>

  <\itemize>
    <item>W <strong|Octave> funkcje <verbatim|load> i <verbatim|save>
    pozwalaj¡ przechowywa¢ dane w ró»nych formatach. Standardowo u»ywamy
    rozszerzenia <verbatim|.mat>. Nazwy zmiennych te» zostan¡ zapami¦tane i
    odtworzone.

    <block|<tformat|<table|<row|<cell|Octave>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    A = [1:3; 4:6; 7:9];>>|<row|<cell|\<gtr\> save myfile.mat
    A>>>>>>>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    load myfile.mat>>|<row|<cell|\<gtr\> A>>|<row|<cell|A = ...>>>>>>>>>>>

    Skªadnia: <verbatim|save [opcje] plik v1 v2 ...> gdzie opcje to:

    <\itemize>
      <item><verbatim|-ascii>: zapisz pojedyncz¡ macierz 2d ``czystym
      tekstem'' bez »adnych meta-danych

      <item><verbatim|-binary>: zapisz w binarnym formacie Octave

      <item><verbatim|-text>: zapisz w tekstowym formacie Octave (czytelny,
      rozwlekªy)

      <item><verbatim|-mat7-binary>, <verbatim|-mat-binary>,
      <verbatim|-mat4-bin>: format binarny Matlaba 7, 6, 4

      <item><verbatim|-hdf5>: binarny format HDF5
    </itemize>

    <item>Octave ma znane z C funkcje <verbatim|fprintf> i <verbatim|fscanf>
    do ``r¦cznej'' obsªugi plików

    <item><strong|R> ma <verbatim|read.table> do wczytywania danych
    stablicowanych

    <\itemize>
      <item>domy±lny separator rozdziela pola biaªymi znakami, argument
      <verbatim|sep> podaje zbiór separatorów, warianty <verbatim|read.csv>
      (<verbatim|sep=',')> rozdziela przecinkiem, <verbatim|read.csv2>
      rozdziela ±rednikiem (przecinek w roli ``kropki dziesi¦tnej'')

      <item>pierwszy wiersz zawiera nazwy zmiennych (kolumn)

      <item>pierwszy wiersz jest o jeden krótszy od pozostaªych, których
      pierwsza kolumna zawiera nazwy wierszy, chyba »e podamy
      <verbatim|header=TRUE>, wtedy nazwy wierszy s¡ domy±lne

      <item>mo»emy poda¢ <verbatim|header=FALSE> i r¦cznie okre±li¢ nazwy
      zmiennych/kolumn w <verbatim|col.names>

      <item>podaj¡c wektor <verbatim|colClasses> mo»emy wymusi¢ typ
      zmiennej/kolumny; <verbatim|NA> daje domy±lny typ, wi¦c mo»emy poda¢
      tylko wybrane kolumny (wstaw pola <verbatim|NA>, bo wektor jest
      recyklowany)

      <\itemize>
        <item>ciekawymi ``niedomy±lnymi'' typami s¡ <verbatim|'NULL'> --
        pomi« kolumn¦, <verbatim|'Data'>, <verbatim|'POSIXct'>
      </itemize>

      <item>kolumny znakowe s¡ domy±lnie konwertowane do typu kategorycznego
      ``factors'' (mo»na to zmieni¢ argumentem-wektorem logicznym
      <verbatim|as.is>)

      <item>stringi mog¡ by¢ wydzielane przy pomocy separatorów
      <verbatim|quote> (domy±lnie <verbatim|quote='"'>)

      <item>plik mo»e zawiera¢ komentarze, domy±lnie po znaku
      <verbatim|comment.char='#'>
    </itemize>

    <block|<tformat|<table|<row|<cell|R>>|<row|<cell|<verbatim|\<gtr\>
    HousePrice \<less\>- read.table('house.data', header=TRUE)>>>>>>

    <item><strong|R> jest dystrybuowane z wieloma zbiorami danych, które
    mo»na wczyta¢ komend¡ <verbatim|data>

    <block|<tformat|<table|<row|<cell|R>>|<row|<cell|<verbatim|<tabular|<tformat|<table|<row|<cell|\<gtr\>
    data() \ #wylistuj tylko z pakietu datasets>>|<row|<cell|\<gtr\>
    data(package = .packages(all.available = TRUE))>>|<row|<cell|\<gtr\>
    data('iris')>>|<row|<cell|\<gtr\> attach(iris)>>|<row|<cell|\<gtr\>
    tapply(Sepal.Length, Species, mean)>>|<row|<cell|\<gtr\> iris2 \<less\>-
    iris; iris2$Species \<less\>- NULL>>|<row|<cell|\<gtr\> by(iris2,
    Species, summary)>>>>>>>>>>>

    <\itemize>
      <item>zwykle dane zostan¡ wczytane do jednej zmiennej typu date.frame o
      nazwie takiej jak nazwa zbioru danych

      <item><verbatim|data> rozpoznaje pliki <verbatim|.R>/<verbatim|.r>
      (wczytuje przez <verbatim|source(...)>),
      <verbatim|.RData>/<verbatim|.rda> (wczytuje przez
      <verbatim|load(...)>), <verbatim|.tab>/<verbatim|.txt>/<verbatim|.TXT>
      (wczytuje przez <verbatim|read.table(..., header=TRUE)>),
      <verbatim|.csv>/<verbatim|.CSV> (wczytuje przez
      <verbatim|read.table(..., header=TRUE, sep=';')>)
    </itemize>
  </itemize>

  <new-page>

  <section|Elementy analizy opisowej danych>

  \;

  \;
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
    <associate|page-orientation|landscape>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|2>>
    <associate|auto-2|<tuple|1.1|2>>
    <associate|auto-3|<tuple|1.2|4>>
    <associate|auto-4|<tuple|1.3|6>>
    <associate|auto-5|<tuple|1.4|8>>
    <associate|auto-6|<tuple|1.5|12>>
    <associate|auto-7|<tuple|1.6|21>>
    <associate|auto-8|<tuple|2|25>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|Wprowadzenie
      do j¦zyków Octave i R> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <with|par-left|<quote|1.5fn>|Pomoc <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2>>

      <with|par-left|<quote|1.5fn>|Podstawowe typy warto±ci
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|1.5fn>|Podstawowe konstrukcje steruj¡ce
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <with|par-left|<quote|1.5fn>|Funkcje, biblioteki, zapisywanie
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <with|par-left|<quote|1.5fn>|Wektory, macierze, struktury
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>

      <with|par-left|<quote|1.5fn>|Wczytywanie danych
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-7>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|Elementy
      analizy opisowej danych> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-8><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>