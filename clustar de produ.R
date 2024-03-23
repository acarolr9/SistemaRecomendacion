library(readxl)
library(dplyr)

library("cluster")
library(Hmisc)
library(corrplot)
library(xlsx)
library(psych)

base<-read.csv("order_products__prior.csv")
base_ordenes<-read.csv("orders.csv")
products<-read.csv("products.csv")
aisles<-read.csv("aisles.csv")

colnames(base)
ordenes_1 <- base %>% select(order_id,product_id) %>% mutate(cuenta=1)

ordenes_1<-ordenes_1 %>% group_by(order_id) %>% summarise(cuenta=sum(cuenta))
ordenes_2<-ordenes_1

ordenes_2$cuenta<-log1p(ordenes_1$cuenta)
ordenes_2$cuenta<-scale(ordenes_1$cuenta)

cuenta_1<-ordenes_1

wss <- (nrow(cuenta_1)-1)*sum(apply(cuenta_1,2,var))

for (i in 2:30) wss[i] <- sum(kmeans(ordenes_2,
                                     centers=i, nstart=10)$withinss)
plot(1:30, wss, type="b", xlab="Numero de Clusters",
     ylab="Suma de cuadrados within") 

set.seed(5935)

base_cluster<-kmeans(ordenes_2$cuenta,centers = 12,nstart = 10,iter.max = 20)
base_cluster$size
base_cluster$iter
base_cluster$centers %>% View()
base_cluster$cluster


ordenes_1$grupos<-base_cluster$cluster

ResultadosCl<-ordenes_1 %>%mutate(n=1) %>%  group_by(grupos) %>% summarise(TamaClus=sum(n),MaxCantPro=max(cuenta),MintCantPro=min(cuenta),mean(cuenta))

ordenesFin<-ordenes_1
ordenesFin$grupos<-as.factor(ordenesFin$grupos)

ordenesFin<-ordenesFin %>% filter(grupos %nin% c(2,3,5))
describe(ordenesFin)
write.csv(., 'Resulta.csv')
