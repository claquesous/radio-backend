class SongPolicy < ApplicationPolicy
  def new?
    create?
  end

  def create?
    user.admin?
  end

  def show?
    true
  end

  def edit?
    update?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end

