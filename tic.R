add_package_checks()

if (Sys.getenv("BUILD_PKGDOWN") != "" && !ci()$is_tag()) {
  get_stage("install") %>%
    add_code_step(remotes::install_github("tidyverse/tidytemplate"))

  get_stage("deploy") %>%
    add_step(step_build_pkgdown())

  if (Sys.getenv("id_rsa") != "") {
    get_stage("before_deploy") %>%
      add_step(step_setup_ssh()) %>%
      add_step(step_test_ssh())

    # pkgdown documentation can be built optionally. Other example criteria:
    # - `inherits(ci(), "TravisCI")`: Only for Travis CI
    # - `ci()$is_tag()`: Only for tags, not for branches
    # - `Sys.getenv("BUILD_PKGDOWN") != ""`: If the env var "BUILD_PKGDOWN" is set
    # - `Sys.getenv("TRAVIS_EVENT_TYPE") == "cron"`: Only for Travis cron jobs
    get_stage("deploy") %>%
      add_step(step_push_deploy(commit_paths = "docs"))
  }
}
