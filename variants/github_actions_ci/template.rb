template "variants/github_actions_ci/workflows/ci.yml.tt", ".github/workflows/ci.yml", force: true
copy_file "variants/github_actions_ci/workflows/deploy_to_ec2.yml", ".github/workflows/deploy_to_ec2.yml"
copy_file "variants/github_actions_ci/workflows/deploy_to_heroku.yml", ".github/workflows/deploy_to_heroku.yml"

append_to_file! "bin/ci-run" do
  <<~ACTIONLINT

    echo "* ******************************************************"
    echo "* Running ActionLint"
    echo "* ******************************************************"
    actionlint
  ACTIONLINT
end
