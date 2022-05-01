require "rails_helper"

RSpec.describe ApplicationPolicy, type: :policy do
  subject(:policy) { described_class }

  let(:scope) { "Can be anything" }
  let(:user) { FactoryBot.create(:user) }

  permissions ".scope" do
    it { expect { ApplicationPolicy::Scope.new(user, scope).resolve }.to raise_error(NotImplementedError) }
  end

  permissions :index? do
    it { expect(policy).not_to permit(user) }
  end

  permissions :show? do
    it { expect(policy).not_to permit(user) }
  end

  permissions :create? do
    it { expect(policy).not_to permit(user) }
  end

  permissions :new? do
    it { expect(policy).not_to permit(user) }
  end

  permissions :update? do
    it { expect(policy).not_to permit(user) }
  end

  permissions :edit? do
    it { expect(policy).not_to permit(user) }
  end

  permissions :destroy? do
    it { expect(policy).not_to permit(user) }
  end
end
