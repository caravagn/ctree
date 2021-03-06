# =-=-=-=-=-=-=-=-=-=-=-=-=-
# These function compute the information transfer from ctree trees.
# This terminology is first introduced in REVOLVER.
# =-=-=-=-=-=-=-=-=-=-=-=-=-

# This function takes the list of drivers in x and traverses backward the tree
# to determine the transitive closure used by REVOLVER's algorithm. 
information_transfer = function(x)
{
  # Reverse the matrix is a good way to easily traverse bottom up the graph
  model = x$adj_mat
  reverse_model = MatrixToDataFrame(model) %>%
    mutate(
      A = from,
      from = to,
      to = A
    ) %>%
    select(-A) %>%
    DataFrameToMatrix()
  
  # Then we need all drivers nodes
  nodes.drivers = x$CCF %>%
    filter(is.driver) %>%
    pull(cluster)
  
  # Like MJ we go backward ..
  moon_walker = function(reverse_model,
                         nodes.drivers,
                         n)
  {
    from = n
    
    repeat {
      nxt = children(reverse_model, n)
      
      # Stopping conditions: GL or driver
      if (length(nxt) == 0) { n = 'GL'; break }
      if (nxt %in% nodes.drivers) { n = nxt; break }
      
      n = nxt
    }
    
    # reverse the ordering
    data.frame(from = n,
               to = from,
               stringsAsFactors = FALSE)
  }
  
  # Clones are just these then ..
  clones = Reduce(
    rbind,
    lapply(
      nodes.drivers,
      moon_walker,
      reverse_model = reverse_model,
      nodes.drivers = nodes.drivers)
  )
  
  # And we expand everything for the drivers, via dplyr
  drivers = x$drivers %>%
    bind_rows(as_tibble(
      data.frame(
        variantID = 'GL',
        cluster = "GL",
        stringsAsFactors = FALSE
      )
    )) %>%
    mutate(from = cluster,
           to = cluster)
  
  # Actual expansion
  drivers = clones %>%
    left_join(drivers %>% select(variantID, from),
              by = 'from') %>%
    mutate(from = variantID) %>%
    select(-variantID) %>%
    left_join(drivers %>% select(variantID, to),
              by = 'to') %>%
    mutate(to = variantID) %>%
    select(-variantID)
  
  return(list(clones = clones %>% as_tibble(), drivers = drivers %>% as_tibble()))
}