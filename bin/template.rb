%w[setup ci-run ci-test-pipeline-1 ci-test-pipeline-2].each do |bin|
  copy_file "bin/#{bin}", force: true
  chmod "bin/#{bin}", '+x'
end
