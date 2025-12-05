%w[setup ci-run].each do |bin|
  copy_file "variants/backend-base/bin/#{bin}", "bin/#{bin}", force: true
  chmod "bin/#{bin}", "+x"
end

remove_file "bin/ci"
