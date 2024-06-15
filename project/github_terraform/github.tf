# resource "github_repository" "gcp_test_tsuno" {
#   name                 = "gcp-my-staging-environment"
#   private = true
#   description          = ""
#   allow_merge_commit   = false
#   allow_rebase_merge   = false
#   has_downloads        = true
#   has_issues           = true
#   has_projects         = true
#   has_wiki             = true
#   vulnerability_alerts = true
#   pages {
#       source {
#           branch = main
#       }
#   }
# }

resource "github_repository" "first_repo" {
    name = "first_repo"
    private = false
}
