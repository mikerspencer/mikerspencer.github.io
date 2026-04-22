library(leaflet)

make_map <- function() {
  leaflet(height = 400) %>%
    addProviderTiles("OpenStreetMap.Mapnik") %>%
    addMarkers(
      icon = icons(
        iconUrl = "asset/map.svg",
        iconWidth = c(40, 40),
        iconHeight = c(40, 40)
      ),
      lng = 112.617894,
      lat = -7.552141,
      popup = "<b>Ngoro, Mojokerto</b><br>East Java, Indonesia"
    )
}
