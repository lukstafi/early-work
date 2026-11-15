require(graphics)
require(lattice)
library("sg")

### wczytanie danych
# znaczenie zmiennych:
#
##    Population
##    Exchange Rate
##    Purchasing Power Parity over GDP
##    Real Gross Domestic Product per Capita
##    Consumption Share of CGPD
##    Government Share of CGDP
##    Investment Share of CGDP
##    Price Level of Gross Domestic Product
##    Price Level of Consumption
##    Price Level of Government
##    Price Level of Investment
##    Openness in Current Prices
##    Ratio of GNP to GDP
##    CGDP Relative to the United States
##    Real GDP per capita (Constant Prices: Laspeyres)
##    Real GDP per capita (Constant Prices: Chain series)
##    Real GDP Chain per equivalent adult
##    Real GDP Chain per worker
##    Real Gross Domestic Income (RGDPL adjusted for Terms of Trade changes)
##    Openness in Constant Prices
##    Consumption Share of RGDPL
##    Government Share of RGDPL
##    Investment Share of RGDPL
##    growth rate of Real GDP per capita (Constant Prices: Chain series) 


Penn2004 <- read.csv ("PennWorldTable2004_noquot.csv", header=TRUE,
                      colClasses=c ('character', 'character',
                        rep('numeric', 25)), na.string="na")
Wikipedia <- scan ("WikipediaALPHANUM.txt", what='character', sep="\n")

### Eksperyment: szacowanie wspóczynnika wzrostu dla danych z roku 2004
Penn2004$grgdpch
# najłatwiej będzie usunąć obserwacje z brakującymi danymi
Penn1 <- Penn2004
# usuwamy zmienną której brakuje
Penn1[["rgdpwok"]] <- NULL
# i obserwacje dla których ciągle czegoś brakuje
Penn1 <- na.omit(Penn1)
n <- dim(Penn1)[1]
#...pozostało tylko 80 krajów
Wiki1 <- Wikipedia [as.integer(row.names (Penn1))]
PennMat <- Penn1
PennMat$country <- NULL
PennMat$country.isocode <- NULL
PennMat$year <- NULL
PennMat$grgdpch <- NULL
PennMat <- as.matrix (PennMat)

# SVMy klasyfikują na -1 i +1: kwantyzacja
threshold <- median (Penn1$grgdpch)
Labels <- ifelse (Penn1$grgdpch < threshold, -1, 1)

# normalizacja zmiennych
for (i in 1:dim(PennMat)[2]) {
  PennMat[,i] <- PennMat[,i] - mean (PennMat[,i])
  PennMat[,i] <- PennMat[,i] / sd (PennMat[,i])
}

# zbiór uczący i testowy
trn <- 60
train = PennMat[1:trn,]
test = PennMat[-(1:trn),]
trainLabs = Labels[1:trn]
testLabs = Labels[-(1:trn)]
trainWiki = Wiki1[1:trn]
testWiki = Wiki1[-(1:trn)]

# W swoim rozwiązaniu dokonaj (przynajmniej zgrubnej) selekcji parametrów
# jak opisano w "A practical guide to SVM classification" (np. na podzbiorze
# obserwacji jeśli na wszystkich byłoby zbyt czasochłonnie). Trzeba dokonać
# selekcji przynajmniej parametru C, natomiast różne wartości gamma
# (szerokość RBFa) można przetestować wprowadzając odpowiednie jądra do
# wielojądrowego algorytmu uczenia. Kros-walidacji dokonuję na zbiorze uczącym,
# żeby zachować obiektywność testu.

cache <- 5       # 5MB of cache per kernel
svmeps <- 1e-3   # svm epsilon
mkleps <- 1e-3   # mkl epsilon
cross <- 3       # ilość testów kros-walidacji
gammas <- 2^(seq (-5,5,by=2))
order <- 10      # długość podciągów w spektrum
useSign <- 1
normalization <- 'FULL'

sg('send_command','loglevel ERROR')
sg('send_command','echo OFF')


# pętla selekcji parametru C
besterr <- 1
bestC <- 1
for (k in seq(-5,7,by=2)) {
  C <- 2^k
  sg('send_command','clean_kernels')
  sg('send_command','clean_features TRAIN')
  # losowanie nie jest konieczne bo kolejność alfabetyczna jest przypadkowa...
  perm.ind <- sample (trn)
  train.ind <-
    tapply(1:n, cut(1:n, breaks = cross), function(x) perm.ind[-x])
  testerr <- 0
  for (sample in train.ind) {
    
    for (g in gammas) 
      sg ('add_features','TRAIN',train[sample])
    sg ('add_features','TRAIN',trainWiki[sample],'ALPHANUM')
    sg ('set_labels','TRAIN', trainLabs[sample])

    sg('send_command', 'new_svm LIGHT')
    sg('send_command', 'use_linadd 0')
    sg('send_command', 'use_mkl 1')
    sg('send_command', 'use_precompute 0')
    sg('send_command', sprintf('mkl_parameters %f 0', mkleps))
    sg('send_command', sprintf('svm_epsilon %f', svmeps))
    sg('send_command', 'set_kernel COMBINED 0')
    
    send_command(sprintf("convert TRAIN STRING CHAR STRING ULONG %i %i", order,order-1)) 
    send_command("add_preproc SORTULONGSTRING") 

    for (g in gammas) 
      sg ('send_command',sprintf('add_kernel 1 GAUSSIAN REAL %d %f', cache, g))
    sg('send_command', sprintf('add_kernel 1 COMMSTRING ULONG %d %d %s',cache,
                               useSign, normalization))

    send_command(sprintf("c %1.2e", C)) 
    send_command("init_kernel TRAIN") 
    send_command("svm_train") 

    # obliczanie błędu, od razu na zbiorze testowym kros-walidacji
    for (g in gammas) 
      sg ('add_features','TEST',train[-sample])
    sg ('add_features','TEST',trainWiki[-sample],'ALPHANUM')
    sg('set_labels','TEST',trainLabs[-sample])
    sg('send_command', 'init_kernel TEST')
    sg('send_command', 'set_threshold 0')
    testout=sg('svm_classify')
    testerr = testerr + mean(trainLabs[-sample] != sign(testout))
  }
  if (testerr < besterr) bestC <- C
}

bestC
# klasyfikacja z ustalonym C = bestC

for (g in gammas) 
  sg ('add_features','TRAIN',train)
sg ('add_features','TRAIN',trainWiki,'ALPHANUM')

sg ('set_labels','TRAIN', trainLabs)

sg('send_command', 'new_svm LIGHT')
sg('send_command', 'use_linadd 0')
sg('send_command', 'use_mkl 1')
sg('send_command', 'use_precompute 0')
sg('send_command', sprintf('mkl_parameters %f 0', mkleps))
sg('send_command', sprintf('svm_epsilon %f', svmeps))
sg('send_command', 'set_kernel COMBINED 0')
    
send_command(sprintf("convert TRAIN STRING CHAR STRING ULONG %i %i", order,order-1)) 
send_command("add_preproc SORTULONGSTRING") 

for (g in gammas) 
  sg ('send_command',sprintf('add_kernel 1 GAUSSIAN REAL %d %f', cache, g))
sg('send_command', sprintf('add_kernel 1 COMMSTRING ULONG %d %d %s',cache,
                           useSign, normalization))

send_command(sprintf("c %1.2e", bestC)) 
send_command("init_kernel TRAIN") 
send_command("svm_train")

# wagi poszczególnych jąder
w = sg('get_subkernel_weights')
w

for (g in gammas) 
  sg ('add_features','TEST',test)
sg ('add_features','TEST',testWiki,'ALPHANUM')
sg('set_labels','TEST',testLabs)
sg('send_command', 'init_kernel TEST')
sg('send_command', 'set_threshold 0')
testout=sg('svm_classify')
# średni błąd na zbiorze testowym
mean(testLabs != sign(testout))
for (i in 1:20)
  printf ("%s -> %s wzrost gdp\n", Penn1$country[i],
          ifelse (testout[i]>0, "wysoki", "niski"))

