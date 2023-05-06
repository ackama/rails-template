def generate_db_secrets
  puts "DB_ENCRYPTION_INIT: Running rails db:encryption:init to set realistic values in ENV variables"

  raw = `bin/rails db:encryption:init`
  unparsed_yaml = raw.sub(/Add.+\n/, "")
  parsed = YAML.safe_load(unparsed_yaml)
  parsed.fetch("active_record_encryption")
rescue StandardError => e
  puts "DB_ENCRYPTION_INIT: Recovering from error: #{e.inspect}"
  {
    "primary_key" => "FAILED_TO_GENERATE_DEFAULT_PRIMARY_KEY",
    "deterministic_key" => "FAILED_TO_GENERATE_DEFAULT_DETERMINISTIC_KEY",
    "key_derivation_salt" => "FAILED_TO_GENERATE_DEFAULT_KEY_DERIVATION_SALT"
  }
end

# To avoid setting a bad security example we don't use the same secrets for the
# example.env (which is checked in) and your local .env file.
example_env_db_secrets = generate_db_secrets
dot_env_db_secrets = generate_db_secrets

gsub_file("example.env", "PLACEHOLDER_PRIMARY_KEY", example_env_db_secrets.fetch("primary_key"))
gsub_file("example.env", "PLACEHOLDER_DETERMINISTIC_KEY", example_env_db_secrets.fetch("deterministic_key"))
gsub_file("example.env", "PLACEHOLDER_KEY_DERIVATION_SALT", example_env_db_secrets.fetch("key_derivation_salt"))

gsub_file(".env", "PLACEHOLDER_PRIMARY_KEY", dot_env_db_secrets.fetch("primary_key"))
gsub_file(".env", "PLACEHOLDER_DETERMINISTIC_KEY", dot_env_db_secrets.fetch("deterministic_key"))
gsub_file(".env", "PLACEHOLDER_KEY_DERIVATION_SALT", dot_env_db_secrets.fetch("key_derivation_salt"))
