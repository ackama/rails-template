require "rails_helper"

RSpec.describe ApplicationPolicy, type: :policy do
  subject(:policy) { described_class }

  let(:scope) { "REPLACE_ME_WITH_REAL_SCOPE" }
  let(:user) do
    # FactoryBot.create(:user)
    "REPLACE_ME_WITH_REAL_USER"
  end

  it "rejects a missing policy user" do
    expect { policy.new(nil, :record) }.to raise_error(Pundit::NotAuthorizedError, "must be logged in")
  end

  permissions ".scope" do
    it "rejects a missing scope user" do
      expect do
        ApplicationPolicy::Scope.new(nil, scope)
      end.to raise_error(Pundit::NotAuthorizedError, "must be logged in")
    end

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
