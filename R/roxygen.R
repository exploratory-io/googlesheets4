# functions to help reduce duplication and increase consistency in the docs

### ss ----
param_ss <- function(..., pname = "ss") {
  template <- glue("
    @param {pname} \\
    Something that identifies a Google Sheet: its file ID, a URL from
    which we can recover the ID, an instance of `googlesheets4_spreadsheet`
    (returned by [gs4_get()]), or a [`dribble`][googledrive::dribble], which
    is how googledrive represents Drive files. Processed through
    [as_sheets_id()].
    ")
  dots <- list2(...)
  if (length(dots) > 0) {
    template <- c(template, dots)
  }
  glue_collapse(template, sep = " ")
}

### sheet ----
param_sheet <- function(..., action, pname = "sheet") {
  template <- glue("
    @param {pname} \\
    Sheet to {action}, in the sense of \"worksheet\" or \"tab\". \\
    You can identify a sheet by name, with a string, or by position, \\
    with a number.
    ")
  dots <- list2(...)
  if (length(dots) > 0) {
    template <- c(template, dots)
  }
  glue_collapse(template, sep = " ")
}

param_before_after <- function(sheet_text) {
  glue("
    @param .before,.after \\
    Optional specification of where to put the new {sheet_text}. \\
    Specify, at most, one of `.before` and `.after`. Refer to an existing \\
    sheet by name (via a string) or by position (via a number). If \\
    unspecified, Sheets puts the new {sheet_text} at the end.
    ")
}
