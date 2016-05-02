# ce script permet à partir d'un bibteX de faire
# un réseau de co-auteurs

# chargement des Librairies
library("networkD3")
library("igraph")
library("RefManageR")

# définition des fonctions
source("~/ALBAN/PROJET NETWORK/functions.R")

# lecture du bibteX
A<-ReadBib(file ="~/ALBAN/PROJET NETWORK/papa.bib", .Encoding ="UTF-8")

# extraction des bibtex vers biblio
biblio<- make_relations(A)

# création des group d'individus
vertices<- make_vertices(biblio)

# on ajoute les index des auteurs pour un tracé plus simple du network
biblio<- update_relations(biblio,vertices)

# sophisticated network graph
d3 = forceNetwork(Links = biblio, Nodes = vertices,
                  Source = "source.index", Target = "target.index",
                  Nodesize="freq",
                  NodeID = "name",
                  Value="Value",
                  Group = "group", # color nodes by betweeness calculated earlier
                  charge = -70, # node repulsion
                  linkDistance = 25,
                  fontSize = 14,
                  zoom = T)

# If you want to show the graph
show(d3)

#If you want to save the graph as an html file (250 Ko pour mon fichier exemple)
saveNetwork(d3,file = '~/ALBAN/PROJET NETWORK/papa_network_V1.html',selfcontained = T)
