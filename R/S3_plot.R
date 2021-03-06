#' Plot a \code{ctree} tree.
#' 
#' @description 
#' 
#' This S3 method plots a \code{ctree} tree, using \code{ggraph} layout
#' functions. The tree is annotated and coloured in each node (i.e.,
#' cluster) that contain a driver event annotated. The driver id is also
#' reported via \code{ggrepel} annotation functions.
#'
#' @param x A \code{ctree} tree.
#' @param node_palette A function that applied to a number will return a set of colors.
#' By default this is a \code{colorRampPalette} applied to 9 colours of the \code{RColorBrewer}
#' palette \code{Set1}. Colors are generated following a topological sort of the information
#' transfer, which is obtained from \code{igraph}.
#' @param tree_layout A layout that can be used by \code{tidygraph}, which wraps \code{igraph}'s
#' layouts. By default this is a `tree` layout.
#' @param ... Extra S3 parameters
#'
#' @return A \code{ggplot} plot of the tree.
#'
#' @export plot.ctree
#' @exportS3Method plot ctree
#'
#' @import tidygraph
#' @import ggraph
#' @import ggrepel
#' @import RColorBrewer
#' @import ggplot2 
#' @importFrom igraph topo_sort graph_from_adjacency_matrix
#' @importFrom grid unit
#'
#' @examples
#' data('ctree_input')
#' 
#' x = ctrees(
#'    ctree_input$CCF_clusters,
#'    ctree_input$drivers,
#'    ctree_input$samples,
#'    ctree_input$patient,
#'    ctree_input$sspace.cutoff,
#'    ctree_input$n.sampling,
#'    ctree_input$store.max
#'    )
#'    
#' plot(x[[1]])
plot.ctree = function(x,
                      node_palette = colorRampPalette(RColorBrewer::brewer.pal(n = 9, "Set1")),
                      tree_layout = 'tree',
                      ...)
{
   # Get the tidygraph
    tree = x
    tb_tree = tree$tb_adj_mat
    
    cex = 1
    
    # TODO Color edges as of information transfer
    #  - get path
    #  - modify edges etc.
    # tree$transfer
    
    # Color the nodes by cluster id, using a topological sort
    # to pick the colors in the order of appeareance in the tree
    clones_orderings = igraph::topo_sort(igraph::graph_from_adjacency_matrix(DataFrameToMatrix(tree$transfer$clones)),
                                         mode = 'out')$name
    
    nDrivers = length(clones_orderings) - 1 # avoid GL
    
    drivers_colors = c('white', node_palette(nDrivers))
    names(drivers_colors) = clones_orderings
    
    # Add non-driver nodes, with the same colour
    non_drivers = tb_tree %>%
      activate(nodes) %>%
      filter(!is.driver) %>%
      pull(cluster) # GL is not selected because is NA for is.driver
    
    non_drivers_colors = rep("gainsboro", length(non_drivers))
    names(non_drivers_colors) = non_drivers
    
    tb_node_colors = c(drivers_colors, non_drivers_colors)
    
    # Plot call
    layout <- create_layout(tb_tree, layout = tree_layout)
    
    mainplot = ggraph(layout) +
      geom_edge_link(
        arrow = arrow(length = unit(2 * cex, 'mm')),
        end_cap = circle(5 * cex, 'mm'),
        start_cap  = circle(5 * cex, 'mm')
      ) +
      geom_label_repel(
        aes(
          label = driver,
          x = x,
          y = y,
          colour = cluster
        ),
        na.rm = TRUE,
        nudge_x = .3,
        nudge_y = .3,
        size = 2.5 * cex
      ) +
      geom_node_point(aes(colour = cluster,
                          size = nMuts),
                      na.rm = TRUE) +
      geom_node_text(aes(label = cluster),
                     colour = 'black',
                     vjust = 0.4) +
      coord_cartesian(clip = 'off') +
      # theme_graph(base_size = 8 * cex, base_family = '') +
      theme_void(base_size = 8 * cex) +
      theme(legend.position = 'bottom',
            legend.key.size = unit(3 * cex, "mm")) +
      scale_color_manual(values = tb_node_colors) +
      scale_size(range = c(3, 10) * cex) +
      guides(color = FALSE,
             size = guide_legend("Clone size", nrow = 1)) +
      labs(title = paste(tree$patient),
           subtitle = paste0('Scores ',
                             format(tree$score, scientific = T),
                             '.'))
    
    return(mainplot)
}

