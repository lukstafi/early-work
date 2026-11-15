## Podaj pochodzenie danych i opisz zmienne
help (iris)
## Przebadaj zmienne i podstawowe zależności między nimi
data (iris)
# scatterplot w tym przypadku jest najczytelniejszym podsumowaniem zaw. danych
# Wybierz odpowiedni format grafiki
help (device)
postscript ('scatterplot.eps',width=5,height=8,horizontal=FALSE,paper='special')
plot (iris)
# wydrukuj wynik (flush device)
dev.off ()
# "rozpakuj" dane
attach (iris)

# Wykres pudełkowy względem gatunków:
postscript ('boxplot.eps',width=5,height=8,horizontal=FALSE,paper='special')
# dwa wykresy na jednym rysunku, 2-linijkowe marginesy na tekst
oldpar <- par (mfrow = c(2,1))
boxplot (Sepal.Length ~ Species, ylab = "Sepal Length")
boxplot (Petal.Length ~ Species, ylab = "Petal Length")
par (oldpar)
dev.off ()


by (Petal.Length, Species, sd)
by (Petal.Length, Species, IQR)
by (Petal.Length, Species, function(x) sd(x)/mean(x))

postscript ('histPetal.eps', width=5,height=9,horizontal=FALSE,paper='special')
# trzy wykresy na jednym rysunku, 2-linijkowy margines od góry na tekst
oldpar <- par (mfrow = c(3,1), oma = c (0,0,2,0))
for (sp in levels (Species))
  hist (Petal.Length[Species==sp], main=sp, xlab="Petal Length")
mtext ('Rozkłady zmiennej "długość płatka"', outer = TRUE)
par (oldpar)
dev.off ()

postscript ('qqplotPetal.eps', width=5,height=9,horizontal=FALSE,paper='special')
# trzy wykresy na jednym rysunku, 2-linijkowy margines od góry na tekst
oldpar <- par (mfrow = c(3,1), oma = c (0,0,2,0))
for (sp in levels (Species)) {
  qqnorm (Petal.Length[Species==sp], main=sp, xlab="Petal Length")
  qqline (Petal.Length[Species==sp])
}
mtext ('Normal Q-Q Plot (Petal Length)', outer = TRUE)
par (oldpar)
dev.off ()

# porównaj zależności zmiennych
irisNums <- iris
irisNums$Species <- NULL
cor(irisNums)
# najbardziej zależne są parametry płatków, potem długości
lm (Petal.Width ~ Petal.Length)
lm (Sepal.Length ~ Petal.Length)
lm (Sepal.Width ~ Petal.Length)

# "czyszczenie" zależności szerokości listków i długości płatków
for (sp in levels (Species)) {
  w <- Sepal.Width[Species==sp];
  l <- Petal.Length[Species==sp];
  print(sp); print (cor (w,l)); print(lm (w ~ l))
}
