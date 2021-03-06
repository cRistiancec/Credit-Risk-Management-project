###################################################
### lossPrep
###################################################
library("copula")
data("loss")
myLoss <- subset(loss, censored==0, select=c("loss", "alae"))
nrow(myLoss)


###################################################
### breakTies
###################################################
set.seed(123)
pseudoLoss <- sapply(myLoss, rank, ties.method="random") / (nrow(myLoss) + 1)
pseudoLoss.ave <- sapply(myLoss, rank) / (nrow(myLoss) + 1)
par(mfrow=c(1, 2), mgp=c(1.5, 0.5, 0), mar=c(3.5,2.5,0,0))
plot(pseudoLoss, sub="(a) random rank for ties")
plot(pseudoLoss.ave, sub="(b) average rank for ties")


###################################################
### lossPlot
###################################################
par(mfrow=c(1, 2), mgp=c(1.5, 0.5, 0), mar=c(3.5,2.5,0,0))
plot(pseudoLoss, sub="(a) random rank for ties")
plot(pseudoLoss.ave, sub="(b) average rank for ties")


###################################################
### lossIndep
###################################################
system.time(empsamp <- indepTestSim(nrow(pseudoLoss), p = 2, N = 1000, print.every = 0))
indepTest(pseudoLoss, empsamp)


###################################################
### lossGof
###################################################
system.time(lossGof.gumbel.pb <- gofCopula(gumbelCopula(1), pseudoLoss, method="itau", simulation="pb", N = 1000, print.every = 0))
lossGof.gumbel.pb
system.time(lossGof.gumbel.mult <- gofCopula(gumbelCopula(1), pseudoLoss, method="itau", simulation="mult", N = 1000))
lossGof.gumbel.mult


###################################################
### lossFit
###################################################
fitCopula(gumbelCopula(1), pseudoLoss, method="itau")


###################################################
### repeat
###################################################
myAnalysis <- function(myLoss) {
  pseudoLoss <- sapply(myLoss, rank, ties.method="random") / (nrow(myLoss) + 1)
  indTest <- indepTest(pseudoLoss, empsamp)$global.statistic.pvalue
  gof.g <- gofCopula(gumbelCopula(1), pseudoLoss, method="itau", simulation="mult")$pvalue
  gof.c <- gofCopula(claytonCopula(1), pseudoLoss, method="itau", simulation="mult")$pvalue
  gof.f <- gofCopula(frankCopula(1), pseudoLoss, method="itau", simulation="mult")$pvalue
  gof.n <- gofCopula(normalCopula(0), pseudoLoss, method="itau", simulation="mult")$pvalue
  gof.p <- gofCopula(plackettCopula(1), pseudoLoss, method="itau", simulation="mult")$pvalue
  gof.t <- gofCopula(tCopula(0, df = 4, df.fixed = TRUE), pseudoLoss, method="itau", simulation="mult")$pvalue
  fit.g <- fitCopula(gumbelCopula(1), pseudoLoss, method="itau")
  c(indep=indTest, gof.g=gof.g, gof.c=gof.c, gof.f=gof.f, gof.n=gof.n, gof.t=gof.t, gof.p=gof.p, est=fit.g@estimate, se=sqrt(fit.g@var.est))
}
myReps <- t(replicate(100, myAnalysis(myLoss)))
round(apply(myReps, 2, summary),3)


###################################################
### lossGof3
###################################################
gofCopula(gumbelCopula(1), pseudoLoss.ave, method="itau", simulation="mult", N = 1000)


###################################################
### srPrep
###################################################
data("rdj")
nrow(rdj)
apply(rdj[,2:4], 2, function(x) length(unique(x)))


###################################################
### pseudoobs
###################################################
pseudoSR <- apply(rdj[,2:4], 2, rank)/(nrow(rdj) + 1)


###################################################
### srMultSerialIndepTest
###################################################
set.seed(123)
system.time(srMultSerialIndepTest <- multSerialIndepTest(rdj[,2:4]^2, lag.max=4, print.every = 0))
srMultSerialIndepTest
dependogram(srMultSerialIndepTest)


###################################################
### multIndepTest
###################################################
system.time(empsamp <- indepTestSim(nrow(pseudoSR), p = 3, N = 1000, print.every = 0))
srMultIndepTest <- indepTest(pseudoSR, empsamp)
srMultIndepTest
dependogram(srMultIndepTest)


###################################################
### srGof
###################################################
system.time(srGof.t.pb <- gofCopula(tCopula(c(0,0,0), dim=3, dispstr="un", df=5, df.fixed=TRUE), pseudoSR, method="mpl", print.every = 0))
srGof.t.pb
system.time(srGof.t.mult <- gofCopula(tCopula(c(0,0,0), dim=3, dispstr="un", df=5, df.fixed=TRUE), pseudoSR, method="mpl", simulation="mult"))
srGof.t.mult


###################################################
### srFit
###################################################
fitCopula(tCopula(c(0,0,0), dim=3, dispstr="un", df=10, df.fixed=TRUE), pseudoSR, method="mpl")


