copy_file "variants/backend-base/lib/tasks/coverage.rake", "lib/tasks/coverage.rake"
copy_file "variants/backend-base/lib/tasks/app.rake", "lib/tasks/app.rake"
copy_file "variants/backend-base/lib/tasks/dev.rake", "lib/tasks/dev.rake"

template "variants/backend-base/lib/tasks/assets.rake.tt", "lib/tasks/assets.rake", force: true
