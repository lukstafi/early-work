# punkt 1 w pakiecie "Deal"
install.packages("deal")
library(deal)
# zbiór danych wykorzystany w artykule "Learning BNs with R"
data(ksl)
help(ksl)
# reszta bezpośrednio z przykłądu w artykule
ksl.nw <- network(ksl) # specify prior network
ksl.prior <- jointprior(ksl.nw) # make joint prior distribution
## ban arrows towards Sex and Year
banlist <- matrix(c(5,5,6,6,7,7,9,
                    8,9,8,9,8,9,8),ncol=2)
ksl.nw$banlist <- banlist
ksl.nw   <- learn(ksl.nw,ksl,ksl.prior)$nw
result   <- heuristic(ksl.nw,ksl,ksl.prior,restart=2,degree=10,trace=TRUE)
thebest <- result$nw[[1]]
savenet(thebest, "ksl.net")
# niestety, "deal" nie ma propagowania prawdopodobieństw: nie możemy
# obliczać prawdopodobieństw w danym węźle przy danych dowolnych innych
# węzłach, i nie ma "węzłów ukrytych" - zmiennych nieobserwowalnych
# Nie wiem, w jakim pakiecie R-a można to znaleźć

# punkt 1 w pakiecie "BNLearn"


# punkt 3

install.packages("arules",repos="http://R-Forge.R-project.org")
