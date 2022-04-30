# Setups auditing of frontend dependencies using audit-app as part of CI,
# and generates an .auditapprc.json configured to ignore any vulnerabilities
# that exist at the time the app is generated, since they'll be unpatchable
#
# This means that this variant should be run after all other variants to ensure
# all js packages have been installed; otherwise we risk not ignoring a vulnerability
# which will result in CI breaking out of the box, which is a bad experience

copy_file ".auditapprc.json"

audit_app_config = JSON.parse(File.read("./.auditapprc.json"))
audit_app_config["ignore"] = `CI=true npx audit-app --no-config --output paths`.split("\n")

File.write("./.auditapprc.json", JSON.generate(audit_app_config))

run "yarn run format-fix"

append_to_file "bin/ci-run" do
  <<~AUDIT
    echo "* ******************************************************"
    echo "* Running JS package audit"
    echo "* ******************************************************"
    npx audit-app
  AUDIT
end
