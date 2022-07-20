require "rails_helper"

describe RetinaImageHelper, type: :helper do
  subject(:tag) { helper.retina_image_tag("example.png", alt: "example") }

  before { allow(helper).to receive(:image_path) { |file| "/images/#{file}" } }

  it { assert_match(%r{\A<img src=".*" srcset=".*" alt=".*" />\z}, tag) }
  it { assert_match(/alt="example"/, tag) }
  it { assert_match(%r{src="/images/example.png"}, tag) }
  it { assert_match(%r{srcset="/images/example.png 1x,/images/example@2x.png 2x"}, tag) }
end
