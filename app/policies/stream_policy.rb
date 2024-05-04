class StreamPolicy < ApplicationPolicy
  def show?
    record.user == user
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      @user.streams
    end
  end

end

