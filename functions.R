# fonctions nécessaires pour lire un bibteX et le transformer en network

#--------------------------------------------------------------------------------
# A partir d'une liste d'auteur, on sort le kième auteur. (+ remplacement de certains caractères spéciaux)
extract_name <- function(author_list,k){
  test<-paste0(unlist(author_list[k],use.names=TRUE))
  author_name<-paste0(substr(as.name(test[1]),0,1),". ",as.name(test[length(test)]))
  # transformation caractère spéciaux
  author_name<-gsub("Ã©","é",author_name)
  author_name<-gsub("Ã§","ç",author_name)
  return(author_name)
}

#--------------------------------------------------------------------------------
# création à partir du bibtex de la liste source/target
make_relations<- function(bibtex){
  
  #initialisiation dégeu...
  relations=data.frame("lol","lol",1)
  names(relations)=c("source","target","Value")
  relations$source<-as.character(relations$source)
  relations$target<-as.character(relations$target)
  relations$Value<-as.numeric(relations$Value)
  
  for (i  in 1:length(bibtex)) {
    author_list<-(bibtex[i]$author)
    n=length(author_list)
    k=1
    # on parcourt les noms d'auteurs
    for (l in 1:n){
      # on ne s'arrête que si les deux noms sont différents.
      if (k != l) {
        a=extract_name(author_list,k);b=extract_name(author_list,l)
        if (paste(a,b) %in% paste(relations$source,relations$target) | paste(a,b) %in% paste(relations$target,relations$source)) {
          relations$Value[paste(relations$source,relations$target) %in% paste(a,b) |paste(relations$target,relations$source) %in% paste(a,b)]<- as.numeric(relations$Value)/2
        } else {
          relations<-rbind(relations,c(a,b,1))
        }
      }
    }
  }
  relations<-relations[-1,]
  return(relations)
}

#------------------------------------------------------------------------------------------
# forme les groupes selon la proximité des individus.
make_vertices<- function(relations){
  # Create vertices :
  temp<-table(unlist(relations[,c("source","target")]))
  vertices<-data.frame(temp) # node names
  names(vertices)<-c("name","freq")
  g = graph.data.frame(relations, directed=F, vertices=vertices) # raw graph
  vertices$group = edge.betweenness.community(g)$membership # betweeness centrality for each node for grouping
   
  return(vertices)
}

#----------------------------------------------------------------------------------------------
# ajoute les index pour les individus.
update_relations<-function(relations,vertices){
  # create indices for each name to fit forceNetwork data format
  relations$source.index = match(relations$source, vertices$name)-1
  relations$target.index = match(relations$target, vertices$name)-1
  return(relations)
}