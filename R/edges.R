## unique-fy vertices and create edges with unjoin, or with vctrs
## stealing from Dewey ..., thinking about refactor for silicate ...

edges_unjoin <- function(handleable) {
  crs <- wk_crs(handleable)

  coords <- wk_coords(handleable)

  ## we want topology so first separate the geometry
  uj <- unjoin::unjoin(coords, x, y)  ## FIXME: might need xyz

  verts <- uj$.idx0
  segs <- uj$data %>%
    group_by(feature_id, part_id, ring_id) %>%
    reframe(
      edge = data.frame(
        x0 = .idx0[-n()],
        x1= .idx0[-1])
    )
  list(verts = verts, edge = segs, crs = NA)
}

edges_vctrs <- function(handleable) {
  crs <- wk_crs(handleable)

  coords <- wk_coords(handleable)

  ## we want topology so first separate the geometry
  #uj <- unjoin::unjoin(coords, x, y)  ## FIXME: might need xyz
  coords$.idx0 <- vctrs::vec_duplicate_id(coords[c("x", "y")])

  #browser()
  #coords$.idx0 <- as.integer(factor(coords$.idx0))

  verts <- coords[match(unique(coords$.idx0), coords$.idx0), c("x", "y", ".idx0")]

  segs <- coords %>%
    group_by(feature_id, part_id, ring_id) %>%
    reframe(
      edge = data.frame(
        x0 = .idx0[-n()],
        x1= .idx0[-1])
    )

  list(verts = verts, edge = segs, crs = NA)
}

## materialize as wk

edge_linestring <- function(x) {
  n_xy <- nrow(x$edge) * 2
  xy_all <- xy(
    double(n_xy),
    double(n_xy),
    crs = x$crs
  )

  xy_all[seq(1, n_xy, by = 2)] <- xy(x$verts$x, x$verts$y, crs = x$crs)[match(x$edge$edge$x0, x$verts$.idx0)]
  xy_all[seq(2, n_xy, by = 2)] <- xy(x$verts$x, x$verts$y, crs = x$crs)[match(x$edge$edge$x1, x$verts$.idx0)]
  wk_linestring(xy_all, feature_id = rep(1:nrow(x$edge), each = 2))
}


