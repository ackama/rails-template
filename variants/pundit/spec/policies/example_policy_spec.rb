require "rails_helper"

RSpec.describe ExamplePolicy, type: :policy do # rubocop:disable RSpec/EmptyExampleGroup
  let(:scope) { Example.all }
  let(:user) { FactoryBot.create(:user) }

  subject { described_class }

  permissions ".scope" do
    pending "add some examples to (or delete) #{__FILE__}"
    # it { expect(ExamplePolicy::Scope.new(user, scope).resolve).to eq [] }
  end

  permissions :show? do
    pending "add some examples to (or delete) #{__FILE__}"
    # it { expect(subject).to permit(user) }
  end

  permissions :create? do
    pending "add some examples to (or delete) #{__FILE__}"
    # it { expect(subject).to permit(user) }
  end

  permissions :update? do
    pending "add some examples to (or delete) #{__FILE__}"
    # it { expect(subject).to permit(user) }
  end

  permissions :destroy? do
    pending "add some examples to (or delete) #{__FILE__}"
    # it { expect(subject).to permit(user) }
  end
end
