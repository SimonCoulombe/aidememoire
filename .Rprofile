message("renv .Rprofile")
# options -----
options(Ncpus = max(1L, min(parallel::detectCores()-1L, 10L)), # parallel processing when installing from source
        mc.cores = max(1L, min(parallel::detectCores()-1L, 10L)),
        digits = 4L,
        scipen = 999L,
        warnPartialMatchArgs = TRUE,  # warn when using partial arguments
        warnPartialMatchDollar = TRUE, # warn when using partial arguments
        warnPartialMatchAttr = TRUE, # warn when using partial arguments
        show.error.locations = "top",
        repos = c(
          "coop-cran" = "https://rstudiotest3.cgic.ca:4242/coop-cran/latest",
          "coop-internal" = "https://rstudiotest3.cgic.ca:4242/coop-internal/latest"
        )
)
# non-confidential environment variables    ----
Sys.setenv(TZ="America/Toronto")
Sys.setenv(RENV_CONFIG_SANDBOX_ENABLED = "FALSE")
# 
# # create my custom library folder if they dont existe
# for (name in c("R_LIBS_USER", "R_LIBS_SITE")) {
#   path <- Sys.getenv(name)
#   if (nzchar(path) && !utils::file_test("-d", path)) {
#     dir.create(path, showWarnings=FALSE, recursive=TRUE)
#     warning("R needs to be restarted because R package library folder ", name, "=", sQuote(path), " was just created.", immediate. = TRUE)
#   }
# }
#rm(name)
#rm(path)
# non-confidential environment variables that depend on OS  ----
if(Sys.info()[['sysname']] == 'Windows'){
  Sys.setlocale("LC_ALL","English_Canada.1252")
  Sys.setenv(RENV_DOWNLOAD_FILE_METHOD = "wininet")
  
} else if(Sys.info()[['sysname']] == 'Linux'){
  options(download.file.method="wget")
  Sys.setlocale("LC_ALL","en_CA")
  Sys.setenv(RENV_DOWNLOAD_FILE_METHOD = "libcurl")
}


source("renv/activate.R")
