source_paths.unshift(File.dirname(__FILE__))

run "yarn add foundation-sites jquery"
run "yarn add --dev font-awesome"

directory "app/frontend/foundation"

copy_file "app/frontend/application.scss"

%w[base components layouts images].each do |dir|
  empty_directory_with_keep_file "app/frontend/#{dir}"
end

append_to_file "app/frontend/packs/application.js" do
  <<~JS
    require.context('../images', true);
    import "foundation";
    import "../application.scss";
  JS
end


def apply_variant?(name)
  return true if ENV.fetch("VARIANTS", "").split(",").include?(name.to_s)

  ask_with_default("Add #{name} to this application?", :blue, 'N').downcase.start_with?("y")
end

def ask_with_default(question, color, default)
  question = (question.split("?") << " [#{default}]?").join
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

apply "variants/frontend-foundation-layout/template.rb" if apply_variant?(:"foundation-layout")