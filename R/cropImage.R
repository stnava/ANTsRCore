#' crop a sub-image via a mask
#'
#' uses a label image to crop a smaller image from within a larger image
#'
#' @param image antsImage to crop
#' @param labelImage antsImage with label values.
#'  If not supplied, estimated from data.
#' @param label the label value to use
#' @return subimage
#' @author Brian B. Avants, Nicholas J. Tustison
#' @keywords crop, extract sub-image
#' @examples
#'
#' fi <- antsImageRead(getANTsRData("r16"))
#' cropped <- cropImage(fi)
#' cropped <- cropImage(fi, fi, 100 )
#'
#' @export cropImage
cropImage <- function( image, labelImage, label=1 ) {
  image = check_ants(image)

  if(missing(labelImage)) {
    labelImage <- getMask(image)
  }
  labelImage = check_ants(labelImage)
  if ( image@pixeltype != "float" | labelImage@pixeltype != "float" ) {
    stop("input images must have float pixeltype")
  }
  .Call("cropImage",
    image, labelImage, label, 0, NULL, NULL, PACKAGE = "ANTsRCore")
}


#' crop a sub-image by image indices
#'
#' create a proper antsImage sub-image by indexing the image with indices.
#' this is similar to but different from array sub-setting in that the resulting
#' sub-image can be decropped back into its place without having to store its
#' original index locations explicitly.
#'
#' @param image antsImage to crop
#' @param lowerind vector of lower index, should be length image dimensionality
#' @param upperind vector of upper index, should be length image dimensionality
#' @return subimage
#' @author Brian B. Avants, Nicholas J. Tustison
#' @keywords crop, extract sub-image
#' @examples
#'
#' fi <- antsImageRead( getANTsRData("r16"))
#' cropped <- cropIndices( fi, c(10,10), c(100,100) )
#' cropped<-smoothImage( cropped, 5 )
#' decropped<-decropImage( cropped, fi )
#'
#' @export cropIndices
cropIndices <- function( image, lowerind, upperind ) {
  image = check_ants(image)
  if ( image@pixeltype != "float"  ) {
    stop("input images must have float pixeltype")
  }
  if ( image@dimension != length(lowerind) |
       image@dimension != length(upperind)  )
       stop("dimensionality and index length dont match")
  if ( any( lowerind < 1 ) |
       any( upperind > dim( image ) ) )
       stop("lowerind is < 1 or upperind is > dim(image)")
  if ( image@components == 1 )
    return( .Call("cropImage",
      image, image, 1, 2, lowerind, upperind, PACKAGE = "ANTsRCore") )
  ilist = splitChannels( image )
  for ( k in 1:image@components )
    ilist[[k]] = .Call("cropImage",
      ilist[[k]], ilist[[k]], 1, 2, lowerind, upperind, PACKAGE = "ANTsRCore")
  return( mergeChannels( ilist ) )

}


#' decrop a sub-image back into the full image
#'
#' the inverse function for \code{cropImage}
#'
#' @param croppedImage cropped antsImage
#' @param fullImage antsImage to put back into
#' @return decroppedImage
#' @author Brian B. Avants, Nicholas J. Tustison
#' @keywords decrop, extract sub-image
#' @examples
#'
#' fi <- antsImageRead( getANTsRData("r16"))
#' mask <- getMask( fi )
#' cropped <- cropImage( fi, mask, 1 )
#' cropped <- smoothImage( cropped, 1)
#' decropped <- decropImage( cropped , fi )
#'
#' @export decropImage
decropImage <- function( croppedImage, fullImage ) {
  croppedImage = check_ants(croppedImage)
  fullImage = check_ants(fullImage)
  if ( croppedImage@pixeltype != "float" | fullImage@pixeltype != "float" ) {
    stop("input images must have float pixeltype")
  }
  .Call("cropImage",
    croppedImage, fullImage, 1, 1, NULL, NULL, PACKAGE = "ANTsRCore")
}




#' extract a slice from an image
#'
#' extract a slice from an image and return an image of dimensionality, d-1
#'
#' @param image antsImage to crop
#' @param slice which slice, integer
#' @param direction which axis, integer
#' @return antsImage of dimension - 1
#' @author Brian B. Avants, Nicholas J. Tustison
#' @keywords extract
#' @examples
#'
#' fi <- makeImage( c(10,10,10), rnorm(1000) )
#' slice <- extractSlice( fi, 1, 1 )
#'
#' @export extractSlice
extractSlice <- function( image, slice, direction ) {
  image = check_ants(image)
  if ( image@pixeltype != "float"  ) {
    stop("input images must have float pixeltype")
  }
  if ( image@dimension < 3 ) stop("can extract 1-d image")
  if ( direction > image@dimension  )
       stop("dimensionality and index length dont match")
  .Call("extractSlice", image, slice-1, direction-1, PACKAGE = "ANTsRCore")
}
