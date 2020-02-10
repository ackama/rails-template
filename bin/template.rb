%w[setup ci-run].each do |bin|
  copy_file "bin/#{bin}", force: true
  chmod "bin/#{bin}", '+x'
end
