class MfaPolicy < ApplicationPolicy
  def show?
    true
  end

  def new?
    true
  end

  def create?
    true
  end
end
