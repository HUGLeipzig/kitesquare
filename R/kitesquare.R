#' Create a kite-square plot
#'
#' @description
#' Given a data frame or tibble, creates a kite-square plot to visualize the contingency table of two discrete variables.
#'
#' @param df A tibble or data frame of observations.
#' @param x,y Name of the variable in `df` for x (columns) and y (rows), as string or expression.
#' @param obs Name of observation counts in `df`. If a combination of `y` and `x` appears multiple times in `df`, `obs` are added together. If not provided, a value of 1 will be assumed for each line in `df`.
#' @param normalize Should values te normalized to probabilities and expressed in percent?
#' @param full_range If `normalize` is TRUE, should all axes limits be from 0 to 1?
#' @param center_x,center_y,center Should a binary x or y variable be centered (axis reversed) so that the spars meet? `center` overrides both.
#' @param fill_x,fill_y,fill Should the space between x or y bars and the axis be filled? `fill` overrides both.
#' @param kite,square,spars,chi2 Should the kite, square, spars and \eqn{\chi^2} patches be drawn?
#' @param bars_x,bars_y,bars Should the bars for the x and y variables be drawn? `bars` overrides both.
#' @param intersect_x,intersect_y,intersect Should the intersect positions for x and y variables with their axes be drawn? `intersect` overrides both.
#' @param color_x,color_y Colors for x and y.
#' @param kite_color,square_color,spars_color,chi2_color Color of the kite, square, spars and \eqn{\chi^2} patches.
#' @param border_color Color for the border around each cell.
#' @param alpha_fill,alpha_chi2,alpha Transparency for fill and \eqn{\chi^2} patches. `alpha` overrides both.
#' @param pointsize The point size for intersects and spars.
#' @param linewidth The line width for bars and spars.
#' @param whisker_length The length of bar whiskers.
#' @param extend_whiskers Should the bar whiskers be extended to wrap around the \eqn{\chi^2} patches?
#' @param dodge_x The number of levels the x axis labels should dodge.
#' @param ... Further arguments passed to ggplot2::facet_grid().
#'
#' @return A ggplot object, with an extra $table key. The latter contains the tibble of coordinates created internally for plotting.
#' @importFrom dplyr %>%
#' @export
#'
#' @examples
#' df <- dplyr::tibble(
#'   X=c('A', 'A', 'B', 'B', 'B'),
#'   Y=c('U', 'V', 'U', 'V', 'V'),
#'   count=c(30,15,30,70,65))
#' kitesquare(df, X, Y, count)
#' kitesquare(df, X, Y, count, normalize=TRUE, center_x=FALSE)


kitesquare <- function(
    df,
    x,
    y,
    obs,

    # Options affecting overall appearance

    normalize=FALSE,
    full_range=FALSE,

    center_x=TRUE,
    center_y=TRUE,
    center = NULL,

    fill_x=FALSE,
    fill_y=FALSE,
    fill=NULL,

    # Which elements to draw

    kite=TRUE,
    spars=TRUE,
    square=TRUE,
    chi2=TRUE,

    bars_x=TRUE,
    bars_y=TRUE,
    bars=NULL,

    intersect_x=TRUE,
    intersect_y=TRUE,
    intersect=NULL,

    # Element colors

    color_x="#e31a1c",
    color_y="#1f78b4",

    kite_color="black",
    square_color="black",
    spars_color="black",
    chi2_color="#bebebe",

    border_color="black",

    alpha_fill=0.3,
    alpha_chi2=0.3,
    alpha=NULL,


    # Miscellaneous

    pointsize=3,
    linewidth=1,
    whisker_length=0.05,
    extend_whiskers=FALSE,
    dodge_x=2,
    ... #  TODO this does not work properly
){


  # Parameter overrides
  if (!is.null(bars)){
    bars_x <- bars
    bars_y <- bars
  }

  if (!is.null(intersect)){
    intersect_x <- intersect
    intersect_y <- intersect
  }

  if (!is.null(alpha)){
    alpha_fill <- alpha
    alpha_chi2 <- alpha
  }

  if (!is.null(fill)){
    fill_x <- fill
    fill_y <- fill
  }

  # Initialize the internal tibble
  df_ks <-
    df %>%
    dplyr::as_tibble()


  if (missing(obs)){
    df_ks <-
      df_ks %>%
      dplyr::select(
        x={{x}},
        y={{y}}) %>%
      dplyr::mutate(count=1)
  } else {
    df_ks <-
      df_ks %>%
      dplyr::select(
        x={{x}},
        y={{y}},
        count={{obs}})
  }

  df_ks <-
    df_ks %>%
    dplyr::arrange(x,y) %>%
    dplyr::mutate(dplyr::across(c(x,y), as.factor)) %>%
    dplyr::group_by(x,y) %>%
    dplyr::mutate(count=sum(count)) %>%
    dplyr::ungroup() %>%
    dplyr::distinct()

  nr_rows <-
    df_ks %>%
    dplyr::pull(y) %>%
    unique() %>%
    length()

  nr_cols <-
    df_ks %>%
    dplyr::pull(x) %>%
    unique() %>%
    length()


  # Centering parameters
  if (!is.null(center)){
    center_x <- center
    center_y <- center
  }
  center_x <- center_x & nr_cols==2
  center_y <- center_y & nr_rows==2

  # Computations for expectation etc. must be done in probability space., and rescaled by N if unnormalized plots are requested
  if (normalize){
    N <- 1
  } else {
    N <- sum(df_ks$count)
  }

  whisker_length <- whisker_length*N


  # Compute coordinates for internal table
  df_ks <-
    df_ks %>%
    tidyr::expand(x,y) %>%
    dplyr::full_join(df_ks) %>%
    tidyr::replace_na(list(count=0)) %>%

    dplyr::mutate(prop=count/sum(count)) %>%
    dplyr::group_by(x) %>%
    dplyr::mutate(xmarg=sum(count)) %>%
    dplyr::mutate(yprop=count/xmarg) %>%
    dplyr::ungroup() %>%

    dplyr::group_by(y) %>%
    dplyr::mutate(ymarg=sum(count)) %>%
    dplyr::mutate(xprop=count/ymarg) %>%
    dplyr::ungroup() %>%

    dplyr::group_by(y) %>%
    dplyr::mutate(xmarg=xmarg/sum(xmarg)) %>%
    dplyr::ungroup() %>%

    dplyr::group_by(x) %>%
    dplyr::mutate(ymarg=ymarg/sum(ymarg)) %>%
    dplyr::ungroup() %>%

    dplyr::mutate(xykite=xmarg*ymarg) %>%

    dplyr::mutate(
      xmin=pmin(xprop, xmarg),
      ymin=pmin(yprop, ymarg),
      xmax=pmax(xprop, xmarg),
      ymax=pmax(yprop, ymarg)) %>%

    # kite intersects
    dplyr::mutate(
      xkitersect = 2*xykite*(1-xykite/xmarg),
      ykitersect = 2*xykite*(1-xykite/ymarg)) %>%

    dplyr::mutate(dplyr::across(-c(x,y,count),  ~ .*N))

  # setup the plot
  g <- ggplot2::ggplot(data=df_ks)


  if (full_range & normalize){
    xlim=1
    ylim=1
  } else {
    xlim <- min(N, 1.1 * max(df_ks$xmarg, df_ks$xprop, df_ks$prop))
    ylim <- min(N, 1.1 * max(df_ks$ymarg, df_ks$yprop, df_ks$prop))
    xlim=max(xlim,ylim)
    ylim=max(xlim,ylim)
  }

  ### Enforce proper range ###

  g <- g +
    ggplot2::annotate(
      "rect",
      xmin=0,
      xmax=xlim,
      ymin=0,
      ymax=ylim,
      fill=NA,
      color=NA
    )


  ### Fill ###


  if(fill_x){
    g <- g +
      ggplot2::geom_rect(
        ggplot2::aes(
          xmin=0,
          ymin=0,
          xmax=xprop,
          ymax=ymarg,
        ),
        fill=color_x,
        alpha=alpha_fill
      )
  }

  if(fill_y){
    g <- g +
      ggplot2::geom_rect(
        ggplot2::aes(
          xmin=0,
          ymin=0,
          xmax=xmarg,
          ymax=yprop,
        ),
        fill=color_y,
        alpha=alpha_fill
      )
  }

  ### Normalized chi-squared (chi-squared/N) ###
  if (chi2){

    g <- g +
      ggplot2::geom_rect(
        ggplot2::aes(
          xmin=xmin,
          xmax=xmax,
          ymin=ymin,
          ymax=ymax,
        ),
        fill=chi2_color,
        alpha=alpha_chi2
      )
  }


  ### Square ###

  if (square){

    # NOTE we cannot use ggplot2::geom_rect for this...
    g <- g +
      ggplot2::geom_segment(
        ggplot2::aes(
          x=xmarg,
          y=ymarg,
          xend=0,
          yend=ymarg
        ),
        color=square_color,
        linetype="dotted"
      ) +
      ggplot2::geom_segment(
        ggplot2::aes(
          x=xmarg,
          y=ymarg,
          xend=xmarg,
          yend=0
        ),
        color=square_color,
        linetype="dotted"
      )
  }






  ### Bars ###



  ### Bar whiskers ###

  if (extend_whiskers){
    if(bars_y){
      g <- g +
        ggplot2::geom_segment(
          ggplot2::aes(
            y=yprop,
            x=xmarg,
            xend=xprop
          ),
          color=color_y,
          linetype="dotted",
          lineend="square"
        )
    }
    if(bars_x){
      g <- g +
        ggplot2::geom_segment(
          ggplot2::aes(
            x=xprop,
            y=ymarg,
            yend=yprop
          ),
          color=color_x,
          linetype="dotted",
          lineend="square"
        )
    }

  } else {
    if(bars_y){
      g <- g +
        ggplot2::geom_segment(
          ggplot2::aes(
            y=yprop,
            x=xmarg,
            xend=pmax(0, xmarg-whisker_length)
          ),
          color=color_y,
          linewidth=linewidth,
          lineend="square"
        )
    }
    if(bars_x){
      g <- g +

        ggplot2::geom_segment(
          ggplot2::aes(
            x=xprop,
            y=ymarg,
            yend=pmax(0, ymarg-whisker_length)
          ),
          color=color_x,
          linewidth=linewidth,
          lineend="square"
        )
    }
  }


  ### Bar lines ###
  if(bars_x){
    g <- g +
      ggplot2::geom_segment(
        ggplot2::aes(
          x=0,
          xend=xprop,
          y=ymarg
        ),
        color=color_x,
        linewidth=linewidth
      )
  }
  if(bars_y){
    g <- g +
      ggplot2::geom_segment(
        ggplot2::aes(
          y=0,
          yend=yprop,
          x=xmarg
        ),
        color=color_y,
        linewidth=linewidth
      )
  }


  ### Bar intersections with axes ###
  if(intersect_x){
    g <- g +
      ggplot2::geom_point(
        ggplot2::aes(
          x=xmarg,
          y=0),
        color=color_x,
        size=pointsize)
  }
  if(intersect_y){
    g <- g +
      ggplot2::geom_point(
        ggplot2::aes(
          y=ymarg,
          x=0),
        color=color_y,
        size=pointsize)
  }




  ### Kite ###

  if (kite){
    g <- g +

      ggplot2::geom_segment(
        ggplot2::aes(
          x=0,
          y=ykitersect,
          xend=xykite,
          yend=xykite
        ),
        color=kite_color,
        linetype="dotted"
      ) +

      ggplot2::geom_segment(
        ggplot2::aes(
          y=0,
          x=xkitersect,
          xend=xykite,
          yend=xykite
        ),
        color=kite_color,
        linetype="dotted"
      )

  }

  ### Kite spars ###

  if (spars){
    g <- g +
      ggplot2::geom_point(
        ggplot2::aes(
          x=prop,
          y=prop
        ),
        size=pointsize,
        color=spars_color) +
      ggplot2::geom_segment(
        ggplot2::aes(
          x=0,
          y=0,
          xend=prop,
          yend=prop,
        ) ,
        linewidth=linewidth,
        color=spars_color)
  }

  g <- g +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(colour = color_x),
      axis.text.y = ggplot2::element_text(colour = color_y),
      panel.grid.major = ggplot2::element_blank()
    )



  g <- g +
    ggplot2::xlim(0,xlim) +
    ggplot2::ylim(0,ylim)


  g <- g +
    ggplot2::facet_grid(y~x, scales="free",...)

  if (normalize){
    scale_type <- scales::percent
  } else {
    scale_type <- ggplot2::waiver()
  }


  g <- g + ggh4x::facetted_pos_scales(
    x=list(
      (as.integer(x)==min(as.integer(x))) & center_x ~ ggplot2::scale_x_reverse(
        expand = c(0,0),
        labels = scale_type,
        guide = ggplot2::guide_axis(n.dodge = dodge_x)),
      (as.integer(x)!=min(as.integer(x))) | !center_x ~ ggplot2::scale_x_continuous(
        expand = c(0,0),
        labels = scale_type,
        guide = ggplot2::guide_axis(n.dodge = dodge_x)
      )
    ),
    y=list(
      (as.integer(y)==max(as.integer(y))) & center_y ~ ggplot2::scale_y_reverse(
        expand = c(0,0),
        labels = scale_type
      ),
      (as.integer(y)!=max(as.integer(y))) | !center_y ~ ggplot2::scale_y_continuous(
        expand = c(0,0),
        labels = scale_type
      )
    )
  )


  g$table <- df_ks

  quantity <- ifelse(normalize, "Probabilities", "Counts")

  g <- g +
    ggplot2::theme(aspect.ratio = 1,
                   panel.spacing = ggplot2::unit(0, "line"),
                   panel.border = ggplot2::element_rect(color=border_color, fill=NA)) +
    ggplot2::xlab(paste(quantity, "of", rlang::as_name(rlang::enquo(x)))) +
    ggplot2::ylab(paste(quantity, "of", rlang::as_name(rlang::enquo(y))))

  return(g)
}

# make devtools::check() ignore the NSE variables inside dplyr verbs etc.
utils::globalVariables(c("count", "prop", "xkitersect", "xmarg", "xmax", "xmin", "xprop", "xykite", "ykitersect", "ymarg", "ymax", "ymin", "yprop"))
