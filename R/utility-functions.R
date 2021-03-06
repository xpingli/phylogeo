#
# A set of functions used by map and plot functions to test for validity of data
#
#' Data: Projectionlist
projlist <- c("aitoff", "albers", "azequalarea", "azequidistant",
              "bicentric", "bonne", "conic", "cylequalarea", "cylindrical",
              "eisenlohr", "elliptic", "fisheye", "gall", "gilbert",
              "globular","gnomonic","guyou","harrison", "hex", "homing",
              "lagrange", "lambert", "laue", "lune","mercator", "mecca",
              "mollweide", "orthographic", "perspective","polyconic",
              "rectangular", "simpleconic", "sinusoidal", "square",
              "stereographic","tetra","trapezoidal")

#' Create a basemap from the maps() worldmap focusing on a region
#' projection defaults to mercator, but others can be selected
#' http://www.inside-r.org/packages/cran/mapproj/docs/mapproject
#' @import ggplot2
#' @keywords internal
create_basemap <- function(mapdata,
                           region,
                           df,
                           latcol,
                           loncol,
                           projection,
                           orientation,
                           ...){

  #mapdata must be one of the data
  mapdatalist <- c("world","usa","state","county","worldHires","china","japan","nzHires","rivers","world2Hires")
  if (!mapdata %in% mapdatalist) {
    stop(paste0("Mapdata field incorrect. The following values are acceptable: ", mapdatalist))
  }

  # check that the projection is null or is in the projectionlist
  # print out a warning about projections
  if (!(projection %in% projlist)) {
    stop(paste0(projection," is not a valid projection. Please use one of
                the following: aitoff, albers, azequalarea, azequidistant,
                bicentric, bonne, conic, cylequalarea, eisenlohr, elliptic,
                fisheye, gall, gilbert, globular, gnomonic, guyou, harrison,
                hex, homing, lagrange, lambert, laue,  lune, mercator, mecca,
                mollweide, orthographic, perspective, polyconic,
                rectangular,simpleconic, square, sinusoidal, stereographic,
                tetra, trapezoidal"))
  } else if (projection %in% c("bonne","cylindrical","eisenlohr",
                             "gall","harrison","lune","perspective",
                             "stereographic")) {
  #temporary check for projections that are currently not working and
  #will require work to include
  stop("You are using a projection that is not yet supported by phylogeo")

  }else{
  #print("you are using a non-standard projection that may require additional parameters")
  }

  if (is.null(region)) {
    world <- ggplot2::map_data(mapdata)

  } else if (region == "world") {
    world <- ggplot2::map_data(mapdata)
  } else {
    world <- ggplot2::map_data(mapdata, region = region)
  }

  # values passed to this function are from the data itself and are
  # not specified in the parent function.
  worldmap <- ggplot(world, aes(x = long,
                                y = lat,
                                group = group)) +
    geom_polygon(fill = "grey", alpha = 0.6) +
    scale_y_continuous(breaks = (-2:2) * 30) +
    scale_x_continuous(breaks = (-4:4) * 45) +
    theme_classic() +
    theme( axis.text = element_blank(),
           axis.ticks = element_blank(),
           axis.line = element_blank(),
           axis.title = element_blank())

  #check all of the projections and return the projected ggplot
  if (projection == "mercator") {
    return(worldmap)
  } else if (projection %in% c("aitoff", "azequidistant","azequalarea","bonne",
                               "cylindrical","gilbert","eisenlohr","globular","gnomonic",
                               "guyou","hex","laue","lagrange","mollweide","orthographic",
                               "polyconic","sinusoidal","square","tetra",
                               "vandergrinten")) {
    return(worldmap + coord_map(projection = projection,
                                xlim = c(-180,180),
                                ylim = c(-90,90),
                                orientation = c(90,0,0),
                                ...))
  } else if (projection %in% c("cylequalarea","rectangular","conic","mecca","homing")) {
    if (!"lat0" %in% names(list(...))) {
      stop("The bonne,conic,cylequalarea, homing, mecca, and
            rectangular projections require the lat0 argument")
    }
    return(worldmap + coord_map(projection = projection,
                                orientation = orientation,
                                ...,
                                xlim = c(-180,180),
                                ylim = c(-90,90)))
  } else if (projection == "fisheye") {
    if (!"n" %in% names(list(...))) {
      stop("The fisheye projection requires a refractive index, n")
    }
    return(worldmap + coord_map(projection = projection,
                                orientation = orientation,
                                ...,
                                xlim = c(-180,180),
                                ylim = c(-90,90)))
  }else if (projection %in% c("simpleconic","lambert","albers","trapezoidal")) {
    if (!"lat0" %in% names(list(...)) || !"lat1" %in% names(list(...))) {
      stop("The albers,lambert, ,and simpleconic projections require
           a lat0 and lat1 value")
    }
    return(worldmap + coord_map(projection = projection,
                                orientation = orientation,
                                 ... ,
                                xlim = c(-180,180),
                                ylim = c(-90,90)))
  } else if (projection %in% c("bicentric","elliptic")) {
    if (!"lon0" %in% names(list(...))) {
      stop("The bicentric and elliptic projection require a lon0 value")
    }
    return(worldmap +
               coord_map(projection = projection,
                         orientation = orientation,
                         ...,
                         xlim = c(-180,180),
                         ylim = c(-90,90)))
    #need to fix the harrison and lune projections
    #   }else if(projection %in% c("harrison")){
    #           if(is.null(dist) || is.null(angle) ){
    #             stop("The harrison projection require a dist and angle value")
    #           }
    #       return(worldmap + coord_map(projection=projection, orientation=orientation, dist=dist,angle=angle))
    #   }else if(projection  %in% c("lune")){
    #         if(is.null(lat) || is.null(angle) ){
    #           stop("The lune projection require a lat and angle value")
    #         }
    #     return(worldmap + coord_map(projection=projection, orientation=orientation, lat=lat, angle=angle))
  }
}

#Mapproj info from http://www.inside-r.org/packages/cran/mapproj/docs/mapproject
#mercator() equally spaced straight meridians, conformal, straight compass courses
#sinusoidal() equally spaced parallels, equal-area, same as bonne(0)
#cylequalarea(lat0) equally spaced straight meridians, equal-area, true scale on lat0
#cylindrical() central projection on tangent cylinder
#rectangular(lat0) equally spaced parallels, equally spaced straight meridians, true scale on lat0
#gall(lat0) parallels spaced stereographically on prime meridian, equally spaced straight meridians, true scale on lat0
#mollweide() (homalographic) equal-area, hemisphere is a circle
#gilbert() sphere conformally mapped on hemisphere and viewed orthographically

#Azimuthal projections centered on the North Pole. Parallels are concentric circles. Meridians are equally spaced radial lines.
#azequidistant() equally spaced parallels, true distances from pole
#azequalarea() equal-area
#gnomonic() central projection on tangent plane, straight great circles
#perspective(dist) viewed along earth's axis dist earth radii from center of earth
#orthographic() viewed from infinity
#stereographic() conformal, projected from opposite pole
#laue() radius = tan(2 * colatitude) used in xray crystallography
#fisheye(n) stereographic seen through medium with refractive index n
#newyorker(r) radius = log(colatitude/r) map from viewing pedestal of radius r degrees
#Polar conic projections symmetric about the Prime Meridian. Parallels are segments of concentric circles. Except in the Bonne projection, meridians are equally spaced radial lines orthogonal to the parallels.
#conic(lat0) central projection on cone tangent at lat0
#simpleconic(lat0,lat1) equally spaced parallels, true scale on lat0 and lat1
#lambert(lat0,lat1)conformal, true scale on lat0 and lat1
#albers(lat0,lat1)equal-area, true scale on lat0 and lat1
#bonne(lat0)equally spaced parallels, equal-area, parallel lat0 developed from tangent cone

#Projections with bilateral symmetry about the Prime Meridian and the equator.
#polyconic() parallels developed from tangent cones, equally spaced along Prime Meridian
#aitoff() equal-area projection of globe onto 2-to-1 ellipse, based on azequalarea
#lagrange() conformal, maps whole sphere into a circle
#bicentric(lon0) points plotted at true azimuth from two centers on the equator at longitudes +lon0 and -lon0, great circles are straight lines (a stretched gnomonic projection)
#elliptic(lon0) points are plotted at true distance from two centers on the equator at longitudes +lon0 and -lon0
#globular() hemisphere is circle, circular arc meridians equally spaced on equator, circular arc parallels equally spaced on 0- and 90-degree meridians
#vandergrinten() sphere is circle, meridians as in globular, circular arc parallels resemble mercator
#eisenlohr() conformal with no singularities, shaped like polyconic

#Doubly periodic conformal projections.
#guyou W and E hemispheres are square
#square world is square with Poles at diagonally opposite corners
#tetra map on tetrahedron with edge tangent to Prime Meridian at S Pole, unfolded into equilateral triangle
#hex world is hexagon centered on N Pole, N and S hemispheres are equilateral triangles

#Miscellaneous projections.
#harrison(dist,angle) oblique perspective from above the North Pole, dist earth radii from center of earth, looking along the Date Line angle degrees off vertical
#trapezoidal(lat0,lat1) equally spaced parallels, straight meridians equally spaced along parallels, true scale at lat0 and lat1 on Prime Meridian
#lune(lat,angle) conformal, polar cap above latitude lat maps to convex lune with given angle at 90E and 90W

#Retroazimuthal projections. At every point the angle between vertical and a straight line to "Mecca", latitude lat0 on the prime meridian, is the true bearing of Mecca.
#mecca(lat0) equally spaced vertical meridians
#homing(lat0) distances to Mecca are true

#Maps based on the spheroid. Of geodetic quality, these projections do not make sense for tilted orientations.
#sp\_mercator() Mercator on the spheroid.
#sp\_albers(lat0,lat1) Albers on the spheroid.

#' utility function to check the validity of arguments
#' @keywords internal
check_names <- function(member, df, allownumeric=FALSE){
  message <- paste(member, " variable must be a valid column name of a Phyloseq table",sep = "")
  names   <- names(df)
  if (!is.null(member)) {
    if (!allownumeric) {
      if (!member %in% names) {
        stop(message)
      }
    } else {
      if (!is.numeric(member)) {
        if (!member %in% names) {
          stop(message)
        }
      }
    }
  }
}
#' utility function to move the x and y positions of the dataset
#' @keywords internal
jitter_df <- function(df, xcol, ycol, jitter.x, jitter.y, seed){
  set.seed(seed) # setting the seed allows you to repeat your randomness
  df <- data.frame(df)
  dflength <- length(df[,1])
  distx    <- runif(dflength, min = -jitter.x, max = jitter.x)
  disty    <- runif(dflength, min = -jitter.y, max = jitter.y)
  df[xcol] <- df[,xcol] + distx
  df[ycol] <- df[,ycol] + disty
  df
}

#' Transform a three column distance matrix into a five column df for drawing lines.
#'
#' @param distdf outputs from the degree_to_radian function
#' @param phyge a phylogeo object
#'
#' @keywords internal
#'
#' @import dplyr
edgetable_to_linedf <- function(distdf, phygeo) {
    #assertthat::assert_that(names(distdf) == c("Var1","Var2", "distance"))

    # get sample/lat/lon data
    sampledata <- phygeo@sam_data %>%
        data.frame() %>%
        select_( as.name(phygeo@latitude),
                 as.name(phygeo@longitude)) %>%
        add_rownames(var = "samplename")
    names(sampledata) <- c("samplename","lat","lng")


    # merge start and ends with lat/lon data
    distdf <- distdf %>% add_rownames()

    #join the starts and ends (Var1/Var2) from the distdf
    start <- distdf %>% select(rowname, Var1, distance)
    start <- merge(start, sampledata, by.x = "Var1", by.y="samplename") %>%
        rename(samplename = Var1)
    end <- distdf %>% select(rowname, Var2, distance)
    end <- merge(end, sampledata, by.x = "Var2", by.y="samplename") %>%
        rename(samplename = Var2)
    distdf2 <- rbind(start, end)
    return(distdf2)
}
#' Utility Function for Converting Distance Matrices to
#' three column distances while removing all of the duplicates
#' lifted/modified from here:
#' https://github.com/joey711/phyloseq/blob/master/R/plot-methods.R
#' @keywords internal
dist_to_edge_table = function(Dist, MaxDistance=NULL){
  dmat <- as.matrix(Dist)
  # Set duplicate entries and self-links to Inf
  dmat[upper.tri(dmat, diag = TRUE)] <- Inf
  distdf = reshape2::melt(dmat, as.is = TRUE)
  # Eliminate Inf Values (melt's third column is "value")
  distdf <- distdf[is.finite(distdf$value), ]
  names(distdf) <- c("Var1","Var2", "distance")
  # Remove entries above the threshold, MaxDistance
  if (!is.null(MaxDistance)) {
      distdf <- distdf[distdf$distance < MaxDistance, ]
  }
  return(distdf)
}
#' Utility Function for Converting Degrees to Radians
#' @keywords internal
degree_to_radian <- function(degree) {degree * pi / 180}

#' Utility Function for Converting Radians to Degrees
#' @keywords internal
radian_to_degree <- function(radian) { radian * 180 / pi}
