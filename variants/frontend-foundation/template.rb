source_paths.unshift(File.dirname(__FILE__))

yarn_add_dependencies %w[foundation-sites jquery]

directory "app/frontend/foundation"

copy_file "app/frontend/application.scss"

%w[base components layouts images].each do |dir|
  empty_directory_with_keep_file "app/frontend/#{dir}"
end

append_to_file "app/frontend/packs/application.js" do
  <<~JS
    require.context('../images', true);
    import 'foundation';
    import '../application.scss';
  JS
end


def apply_variant?(name)
  return true if ENV.fetch("VARIANTS", "").split(",").include?(name.to_s)

  ask_with_default(
    "Add #{name} to this application?",
    :blue,
    'N',
    "RT_APPLY_VARIANT_#{name}".gsub("-", "_").upcase
  ).downcase.start_with?("y")
end

def fetch_answer(question, color, env_variable)
  env_answer = ENV.fetch(env_variable, nil).to_s.strip

  return ask(question, color) if env_answer.empty?

  say "#{question}: #{env_answer}", color
  env_answer
end

def ask_with_default(question, color, default, env_variable)
  question = (question.split("?") << " [#{default}]?").join
  answer = fetch_answer(question, color, env_variable)
  answer.to_s.strip.empty? ? default : answer
end

apply "variants/frontend-foundation-layout/template.rb" if apply_variant?(:"foundation-layout")
