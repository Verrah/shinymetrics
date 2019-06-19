#' Metric Panel Footer
#'
#' This is a component module to ...
#'
#'
#' @param id a string indicating the id to call the module with
#' @param input standard \code{shiny} boilerplate
#' @param output standard \code{shiny} boilerplate
#' @param session standard \code{shiny} boilerplate
#' @param metric a \code{tbl_metric} object
#' @inheritParams input_date_range
#' @inheritParams input_select_period
#' @param ... Additional parameters to pass to module
#' @examples
#' \dontrun{
#' shinybones::preview_module(metric_panel_footer,
#'   selected_date_range_preset = 'Last Week',
#'   selected_period = 'month'
#' )
#' }
#' @export
#' @importFrom shiny NS fluidRow
#' @importFrom shinydashboard box
#' @importFrom rlang .data
#' @examples
#' \dontrun{
#' shinybones::preview_module(
#'   metric_panel_footer,
#'   metric = tidymetrics::flights_nyc_avg_arr_delay
#' )
#' }
metric_panel_footer <- function(input, output, session,
                                metric,
                                date_range = c(Sys.Date() - 365, Sys.Date()),
                                selected_date_range_preset = 'Last Year',
                                ...){
  ns <- session$ns
  rv_date_range <- shiny::callModule(input_date_range, "date_range",
    date_range = date_range,
    date_range_preset = selected_date_range_preset
  )

  metric_filtered <- shiny::reactive({
    date_range <- rv_date_range()
    get_value(metric) %>%
      dplyr::filter(.data$period == input$period) %>%
      dplyr::filter(date >= date_range[1]) %>%
      dplyr::filter(date <= date_range[2]) %>%
      dplyr::select(-.data$period) %>%
      dplyr::arrange(date)
  })

  shiny::callModule(download_csv, 'download_data',
    dataset = metric_filtered,
    filename = function(){
      paste0(
        gsub("_", "-", attr(metric, 'metadata')$metric_full),
        '-',
        gsub("_", "-", input$period),
        '-',
        format(Sys.time(), "%Y-%m-%d-%H-%M-%S"),
        '.csv'
      )
    }
  )
}

#' @rdname metric_panel_footer
metric_panel_footer_ui <- function(id, selected_period = NULL, ...){
  ns <- shiny::NS(id)
  download_csv_ui_right <- function(...){
    shiny::tags$div(
      class = 'pull-right',
      style='margin-top:25px;',
      download_csv_ui(...)
    )
  }
  shiny::fluidRow(
    shinydashboard::box(
      width = 12,
      title = NULL,
      # Percentage Toggle ----
      shiny::column(2, input_toggle_pct(ns('show_pct'))),
      # Period Picker ----
      shiny::column(3, input_select_period(
        ns('period'),
        selected_period = selected_period
      )),
      # Date Range Selector ----
      shiny::column(5, shiny::fluidRow(
        input_date_range_ui(ns('date_range'))
      )),
      # Download Button ----
      shiny::column(2, download_csv_ui_right(ns('download_data')))
    )
  )
}
