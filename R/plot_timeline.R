#' plot timeline of algorithm output
#' 
#' plot timeline of algorithm output
#' @param pr probGLS algorithm output
#' @param degElevation sun elevation angle for comparison threshold method, if NULL no threshold positions are plotted
#' @param center.longitude around which longitude should the plot be centered? Only 0 and 180 implemented
#' @export



plot_timeline <- function(pr,degElevation=NULL,center.longitude = 0){
  
  if(as.character(pr[[4]]$chosen[pr[[4]]$parameter=="sensor.data"])=="TRUE") SST=T else SST=F
  if(!is.null(degElevation)){
    ho2 <- data.frame(pr[[2]])
    ho2$tFirst  <- ho2$tFirst  + ho2$tFirst.err
    ho2$tSecond <- ho2$tSecond + ho2$tSecond.err
    ho2$lons <- coord(tFirst=ho2$tFirst,tSecond=ho2$tSecond,type=ho2$type,degElevation = degElevation,note=F)[,1]
    ho2$lats <- coord(tFirst=ho2$tFirst,tSecond=ho2$tSecond,type=ho2$type,degElevation = degElevation,note=F)[,2]
  }
  se <- as.numeric(unlist(strsplit(as.character(pr[[4]][14,2]),'[ ]')))
  fe <- as.numeric(unlist(strsplit(as.character(pr[[4]][15,2]),'[ ]')))
  
  # doy 79  = 20 March
  # doy 265 = 22 September
  se <- c(79  - se[1], 79  + se[2])
  fe <- c(265 - fe[1], 265 + fe[2])
  
  years <- unique(pr[[1]]$year)
  
  jday  <- floor(as.numeric(julian(ISOdate(years,1,1))))
  
  jse1 <- jday+se[1]
  jse2 <- jday+se[2]
  jfe1 <- jday+fe[1]
  jfe2 <- jday+fe[2]
  
  poly.frame<-function(data1,data2,prob1,prob2){
    polyf<-data.frame(c(unique(data1[order(data1)]),unique(data1[order(data1,decreasing=T)])),c(tapply(data2,data1,quantile, probs = prob1,na.rm=T),tapply(data2,data1,quantile, probs = prob2,na.rm=T)[order(as.numeric(names(tapply(data2,data1,quantile, probs = prob2,na.rm=T))),decreasing=T)]))
    return(polyf)
  }
  
  if(center.longitude==180){
    x1 <- data.frame(pr[[1]])
    x1$lon[x1$lon<0] <- x1$lon[x1$lon<0]+360
    x2 <- data.frame(pr[[2]])
    x2$lon[x2$lon<0] <- x2$lon[x2$lon<0]+360
    if(!is.null(degElevation)) {
      x3 <-ho2
      x3$lons[x3$lons<0] <- x3$lons[x3$lons<0]+360
    }
    long.label = "Longitude [0 to 360]"
  } else {
    x1 <- pr[[1]]
    x2 <- pr[[2]]
    if(!is.null(degElevation)) x3 <-ho2
    long.label = "Longitude [-180 to 180]"
  }
  
  
  if(SST==T){
    
    opar <- par(mfrow=c(3,1),mar=c(0,4,0,0),oma=c(2,0,0,0))
    
    plot(pr[[1]]$jday,pr[[1]]$lat,col='white',xaxt="n",ylab="Latitude")
    polygon(poly.frame(pr[[1]]$jday,pr[[1]]$lat,0.75,0.25),col=rgb(1,0,0,alpha=0.3) ,border=NA)
    polygon(poly.frame(pr[[1]]$jday,pr[[1]]$lat,0.95,0.05),col=rgb(1,0,0,alpha=0.3) ,border=NA)
    lines(pr[[2]]$jday,pr[[2]]$lat,col='darkred',lwd=1,type="o",cex=1)
    if(!is.null(degElevation)) lines(ho2$jday,ho2$lats,lwd=1,type="o",cex=1)
    abline(v=c(jse1,jse2),lty=3,col="green")
    abline(v=c(jfe1,jfe2),lty=3,col="blue")
    
    plot(x1$jday,x1$lon,col='white',xaxt="n",ylab=long.label)
    polygon(poly.frame(x1$jday,x1$lon,0.75,0.25),col=rgb(1,0,0,alpha=0.3) ,border=NA)
    polygon(poly.frame(x1$jday,x1$lon,0.95,0.05),col=rgb(1,0,0,alpha=0.3) ,border=NA)
    lines(x2$jday,x2$lon,col='darkred',lwd=1,type="o",cex=1)
    if(!is.null(degElevation)) lines(x3$jday,x3$lons,lwd=1,type="o",cex=1)
    
    
    plot  (pr[[1]]$jday,pr[[1]]$sat.sst,col="white",ylab="SST",xaxt="n")
    polygon(poly.frame(pr[[1]]$jday,pr[[1]]$sat.sst,0.75,0.25),col=rgb(1,0,0,alpha=0.3) ,border=NA)
    polygon(poly.frame(pr[[1]]$jday,pr[[1]]$sat.sst,0.95,0.05),col=rgb(1,0,0,alpha=0.3) ,border=NA)
    points(pr[[2]]$jday,pr[[2]]$median.sat.sst,type='o',lwd=1,col="darkred",cex=1)
    points(pr[[2]]$jday,pr[[2]]$tag.sst,type='o',lwd=1,cex=1)
    axis(1,at=floor(pr[[2]]$jday),labels=as.Date(floor(pr[[2]]$jday),origin="1970-01-01"))
  }
  if(SST==F){
    opar <- par(mfrow=c(2,1),mar=c(0,4,0,0),oma=c(2,0,0,0))
    
    plot(pr[[1]]$jday,pr[[1]]$lat,col='white',xaxt="n",ylab="Latitude")
    polygon(poly.frame(pr[[1]]$jday,pr[[1]]$lat,0.75,0.25),col=rgb(1,0,0,alpha=0.3) ,border=NA)
    polygon(poly.frame(pr[[1]]$jday,pr[[1]]$lat,0.95,0.05),col=rgb(1,0,0,alpha=0.3) ,border=NA)
    lines(pr[[2]]$jday,pr[[2]]$lat,col='darkred',lwd=1,type="o",cex=1)
    if(!is.null(degElevation)) lines(ho2$jday,ho2$lats,lwd=1,type="o",cex=1)
    abline(v=c(jse1,jse2),lty=3,col="green")
    abline(v=c(jfe1,jfe2),lty=3,col="blue")
    
    par(mar=c(2,4,0,0))
    plot(x1$jday,x1$lon,col='white',xaxt="n",ylab=long.label)
    polygon(poly.frame(x1$jday,x1$lon,0.75,0.25),col=rgb(1,0,0,alpha=0.3) ,border=NA)
    polygon(poly.frame(x1$jday,x1$lon,0.95,0.05),col=rgb(1,0,0,alpha=0.3) ,border=NA)
    lines(x2$jday,x2$lon,col='darkred',lwd=1,type="o",cex=1)
    if(!is.null(degElevation)) lines(x3$jday,x3$lons,lwd=1,type="o",cex=1)
    axis(1,at=floor(pr[[2]]$jday),labels=as.Date(floor(pr[[2]]$jday),origin="1970-01-01"))
  }
  par(opar) 
  
}