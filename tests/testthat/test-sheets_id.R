test_that("can coerce simple strings and drive_id's to sheets_id", {
  expect_s3_class(as_sheets_id("123"), "sheets_id")
  expect_identical(as_sheets_id(as_sheets_id("123")), as_sheets_id("123"))
  expect_identical(
    as_sheets_id(googledrive::as_id("123")),
    as_sheets_id("123")
  )
})

test_that("string with invalid character is rejected", {
  expect_error(as_sheets_id("abc{123"), "invalid characters")
})

test_that("invalid inputs are caught", {
  expect_error(as_sheets_id(NULL), "Cannot turn `NULL`")
  expect_error(as_sheets_id(character()), "must have length == 1")
  expect_error(as_sheets_id(letters[1:2]), "must have length == 1")
  expect_error(as_sheets_id(1), "Don't know how to coerce")
})

test_that("id can be dug out of a URL", {
  expect_identical(
    as_sheets_id("https://docs.google.com/spreadsheets/d/abc123/"),
    as_sheets_id("abc123")
  )
  expect_identical(
    as_sheets_id("https://docs.google.com/spreadsheets/d/abc123/edit#gid=123"),
    as_sheets_id("abc123")
  )
})

test_that("invalid URL produces error", {
  expect_error(as_sheets_id("https://www.r-project.org"), "does not match")
})

# how I created the reference dribble, which represents two files:
#   * one Google Sheet
#   * one non-Google Sheet
# gap_id <- googlesheets::gs_gap_key()
# chicken <- googledrive::drive_upload(googledrive::drive_example("chicken.jpg"))
# chicken_id <- googledrive::as_id(chicken)
# x <- googledrive::drive_get(id = c(gap_id, chicken_id))
# saveRDS(x, file = test_path("ref/dribble.rds"))

test_that("multi-row dribble is rejected", {
  d <- readRDS(test_path("ref/dribble.rds"))
  expect_error(as_sheets_id(d), "must have exactly 1 row")
})

test_that("dribble with non-Sheet file is rejected", {
  d <- readRDS(test_path("ref/dribble.rds"))
  d <- googledrive::drive_reveal(d, what = "mime_type")
  d <- d[d$mime_type == "image/jpeg", ]
  expect_error(as_sheets_id(d), "must refer to a Google Sheet")
})

test_that("dribble with one Sheet can be coerced", {
  d <- readRDS(test_path("ref/dribble.rds"))
  d <- googledrive::drive_reveal(d, what = "mime_type")
  d <- d[d$mime_type == "application/vnd.google-apps.spreadsheet", ]
  expect_s3_class(as_sheets_id(d), "sheets_id")
})

test_that("a googlesheets4_spreadsheet can be coerced", {
  x <- new("Spreadsheet", spreadsheetId = "123")
  out <- as_sheets_id(new_googlesheets4_spreadsheet(x))
  expect_s3_class(out, "sheets_id")
  expect_identical(out, as_sheets_id("123"))
})

test_that("as_id.googlesheets4_spreadsheet is just as_sheets_id()", {
  x <- new_googlesheets4_spreadsheet(list(spreadsheetId = "123"))
  expect_identical(googledrive::as_id(x), as_sheets_id(x))
})

## sheets_id print method ----

test_that("sheets_id print method reveals metadata", {
  skip_if_offline()
  skip_if_no_token()

  verify_output(
    test_path("ref", "sheets-id-print-with-token.txt"),
    print(gs4_example("gapminder"))
  )
})

test_that("sheets_id print method doesn't error for nonexistent ID", {
  skip_if_offline()
  skip_if_no_token()

  expect_error_free(format(as_sheets_id("12345")))

  verify_output(
    test_path("ref", "sheets-id-print-nonexistent.txt"),
    print(as_sheets_id("12345"))
  )
})

test_that("can print public sheets_id if deauth'd", {
  skip_if_offline()
  skip_on_cran()

  original_cred <- .auth$get_cred()
  original_auth_active <- .auth$auth_active
  withr::defer({
    .auth$set_cred(original_cred)
    .auth$set_auth_active(original_auth_active)
  })

  gs4_deauth()

  verify_output(
    test_path("ref", "sheets-id-print-deauthed.txt"),
    print(gs4_example("mini-gap"))
  )
})

test_that("sheets_id print does not error for lack of cred", {
  skip_if_offline()
  skip_on_cran()

  original_cred <- .auth$get_cred()
  original_auth_active <- .auth$auth_active
  withr::defer({
    .auth$set_cred(original_cred)
    .auth$set_auth_active(original_auth_active)
  })
  withr::local_options(list(gargle_oauth_cache = FALSE))

  # typical initial state: auth_active, but no token yet
  .auth$clear_cred()
  .auth$set_auth_active(TRUE)

  expect_error_free(format(gs4_example("mini-gap")))

  verify_output(
    test_path("ref", "sheets-id-print-no-cred.txt"),
    print(gs4_example("mini-gap"))
  )
})
