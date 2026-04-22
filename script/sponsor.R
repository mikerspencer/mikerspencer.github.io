library(magick)

make_logo_grid <- function(logos,
                           max_per_row,
                           height = 200,
                           hgap = 80,
                           vgap = 50) {
  imgs <- lapply(logos, image_read)
  imgs <- lapply(imgs, function(img) image_scale(img, paste0("x", height)))

  rows <- split(imgs, ceiling(seq_along(imgs) / max_per_row))

  row_images <- lapply(rows, function(row) {
    row <- lapply(row, function(img) {
      image_border(
        img,
        "none",
        geometry = paste0(floor(hgap / 2), "x0+", ceiling(hgap / 2), "x0")
      )
    })
    image_append(image_join(row))
  })

  widths <- sapply(row_images, function(img) image_info(img)$width)
  max_width <- max(widths)

  row_images_centered <- mapply(function(img, w) {
    pad <- max_width - w
    image_border(
      img,
      "none",
      geometry = paste0(floor(pad / 2), "x0+", ceiling(pad / 2), "x0")
    )
  }, row_images, widths, SIMPLIFY = FALSE)

  final <- image_append(
    image_join(
      lapply(row_images_centered, function(img) {
        image_border(img,
                     "none",
                     geometry = paste0("0x", vgap))
      })
    ),
    stack = TRUE
  )

  info <- image_info(final)
  final <- image_crop(
    final,
    geometry = paste0(info$width - 1, "x", info$height, "+0+0")
  )

  final
}
