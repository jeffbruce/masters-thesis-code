#ggplot2 tutorial
#install.packages("ggplot2")
library(ggplot2)

####################
#scatter plot example with iris data
#geom = "point" by default, but can be "bar", "line"
qplot(Sepal.Length,Petal.Length,data=iris,color=Species,size=Petal.Width,alpha=I(0.7),
  xlab="Sepal Length", ylab="Petal Length",
  main="Sepal vs. Petal Length in Fisher's Iris data"
)

####################
#bar plot example with movie data
movies = data.frame(
  director = c("spielberg", "spielberg", "spielberg", "jackson", "jackson"),
  movie = c("jaws", "avatar", "schindler's list", "lotr", "king kong"),
  minutes = c(124, 163, 195, 600, 187)
)
qplot(director, data = movies, geom = "bar", ylab = "# movies")
qplot(director, weight = minutes, data = movies, geom = "bar", ylab = "total length (min.)")

####################
#line graph example with iris data
qplot(Sepal.Length, Petal.Length, data = iris, geom = "line", color = Species)

####################
#line AND point graph example with Orange data set
qplot(age, circumference, data = Orange, geom = c("point", "line"), colour = Tree)

####################
#there are also geoms for boxplots and histograms
