# this applies the js-linting tools to the app, and so should be run after *all*
# frontend variants have finished running to ensure that we don't cause any
# overrides or miss files

# must be run after prettier is installed and has been configured by setting
# the 'prettier' key in package.json
run "yarn run js-lint-fix"
run "yarn run format-fix"
