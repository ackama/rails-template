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

  ask_with_default("Add #{name} to this application?", :blue, 'N').downcase.start_with?("y")
end

def ask_with_default(question, color, default)
  question = (question.split("?") << " [#{default}]?").join
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

# the foundation variant tend to make lighthouse sad *sometimes* - while we're
# currently discussing switching to bootstrap, we're not yet ready to remove
# this variant so for now we lower the required lighthouse scores to pass just
# enough to stop CI failing without having to disable the tests entirely

# gsub_file "spec/support/shared_examples/an_accessible_page.rb",
#   "pass_lighthouse_audit(:accessibility)",
#   "pass_lighthouse_audit(:accessibility, score: 95)"
#
# gsub_file "spec/support/shared_examples/a_performant_page.rb",
#   "pass_lighthouse_audit(:performance, score: 95)",
#   "pass_lighthouse_audit(:performance, score: 90)"

apply "variants/frontend-foundation-layout/template.rb" if apply_variant?(:"foundation-layout")
