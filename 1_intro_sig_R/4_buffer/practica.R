# Práctica 4: Contaminación del Río Santiago
# 
# “La Comisión solicita a México que adopte las medidas necesarias para preservar
# la vida, integridad personal y salud de los pobladores de las zonas hasta 5 kilómetros
# del Río Santiago en los municipios de Juanacatlán y El Salto, así como de los
# pobladores de las localidades de San Pedro Itzicán, Agua Caliente, Chalpicote y
# Mezcala en el municipio de Poncitlán, Estado de Jalisco, señalados en la solicitud”,
# señala un comunicado de la Comisión Interamericana de Derechos Humanos (CIDH).
# 
# Enlace de la nota:
# https://www.milenio.com/ciencia-y-salud/medioambiente/rio-santiago-comision-interamericana-otorga-medidas-cautelares
# 
# # Objetivo de la práctica: Construir un mapa que muestre la zona delimitada por
# la CIDH, delimitado a los municipios mencionados en la nota.
library(sf)
library(rgdal)
library(dplyr)
library(tmap)
setwd("1_intro_sig_R/4_buffer/")

# Mapa del país por división política
# Fuente: INEGI
estados <-
  st_as_sf(readOGR(dsn = "ESTADOS",
                   encoding = "UTF-8"))

# Polígono con el estado de Jalisco
jalisco <- estados %>%
  filter(CVE_ENT == 14)

# Mapa con los municipios de Jalisco afectados
# Fuente: INEGI
jalisco_mun <-
  st_as_sf(readOGR(dsn = "MUNICIPIOS",
                   encoding = "UTF-8")) %>%
  filter(CVE_ENT == 14) %>%
  filter(NOM_MUN %in% c("Juanacatlán", "El Salto", "Poncitlán"))

# Mapa del Río Santiago en Jalisco
# Fuente: Carlos Efraín Porto Tapiquén. Orogénesis Soluciones Geográficas. Porlamar, Venezuela, 2015
rio_santiago <- read_sf("México_Hidrografia") %>%
  filter(CUENCA == "Río Grande de Santiago") %>%
  st_transform(crs = st_crs(estados))

# Cálculo del buffer de 5 km alrededor del Río Santiago
rio_santiago_buffer <- rio_santiago %>%
  st_buffer(dist = 5000) %>%
  st_intersection(jalisco_mun)

# Mapa del Lago Chapala en Jalisco
# Fuente: Carlos Efraín Porto Tapiquén. Orogénesis Soluciones Geográficas. Porlamar, Venezuela, 2015
lago_chapala <- read_sf("México_Lagos") %>%
  filter(NOMBRE == "Lago de Chapala") %>%
  st_transform(crs = st_crs(estados))

# Creación del PDF con el buffer
pdf("zona_riesgo_cidh.pdf", width = 7, height = 5.3)
tm_shape(estados, bbox = st_bbox(jalisco)) +
  tm_polygons(col = "grey") +
  tm_shape(jalisco) +
  tm_polygons(col = "green4") +
  tm_shape(rio_santiago) +
  tm_lines(col = "#66FFFF") +
  tm_shape(lago_chapala) +
  tm_polygons(col = "#66FFFF") +
  tm_shape(rio_santiago_buffer) +
  tm_polygons(col = "red", alpha = 0.7) +
  tm_compass(
    type = "4star",
    text.size = 0.8,
    size = 2,
    position = c("right", "top")
  ) +
  tm_credits(
    "Autor: Fernando Gómez Perera\nFuentes:
    Carlos Efraín Porto Tapiquén. Orogénesis Soluciones Geográficas. Porlamar, Venezuela, 2015,
    INEGI, Milenio",
    size = 6,
    align = "left",
    position = c("left", "bottom")
  ) +
  tm_layout(
    frame.double.line = TRUE,
    main.title = "Zona de riesgo CIDH (en rojo)",
    main.title.position = "center",
    main.title.size = 1
  )
dev.off()

setwd("../../")
