require "rails_helper"

describe RetinaImageHelper, type: :helper do
  subject(:tag) { helper.retina_image_tag("example.png", alt: "example") }

  before { allow(helper).to receive(:image_path) { |file| "/images/#{file}" } }

  it { expect(tag).to match(%r{\A<img src=".*" srcset=".*" alt=".*"\s*/?>}) }
  it { expect(tag).to match(/alt="example"/) }
  it { expect(tag).to match(%r{src="/images/example.png"}) }
  it { expect(tag).to match(%r{srcset="/images/example.png 1x,/images/example@2x.png 2x"}) }
end
