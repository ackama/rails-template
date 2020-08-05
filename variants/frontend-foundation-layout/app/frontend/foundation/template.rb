directory "app/frontend/foundation/components"

append_to_file "app/frontend/foundation/index.js" do
  "\nimport './components/header';\n"
end

append_to_file "app/frontend/foundation/foundation_and_overrides.scss" do
  <<~MODULES
  @import "components/footer";
  @import "components/header";
  @import "components/navigation";
  @import "components/search-bar";
  MODULES
end
