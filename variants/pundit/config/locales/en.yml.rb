insert_into_file "config/locales/en.yml", after: /^en:\n/ do
  <<-YAML
  authorization:
    not_authorized: "You are not authorised to perform this action."
  YAML
end
