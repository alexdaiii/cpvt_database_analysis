# Install required R packages

requirements <- c("rstatix", "effectsize", "rcompanion")

for (package in requirements) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package)
  }
}
