template "variants/github_actions_ci/workflows/ci.yml.tt", ".github/workflows/ci.yml"
copy_file "variants/github_actions_ci/workflows/deploy_to_ec2.yml", ".github/workflows/deploy_to_ec2.yml"
copy_file "variants/github_actions_ci/workflows/deploy_to_heroku.yml", ".github/workflows/deploy_to_heroku.yml"
