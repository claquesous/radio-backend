module SimpleCommand
  prepend ActiveSupport::Concern

  class CommandResult
    attr_reader :result, :errors

    def initialize(result: nil, errors: nil)
      @result = result
      @errors = errors || ActiveModel::Errors.new(self)
    end

    def success?
      errors.empty?
    end

    def failure?
      !success?
    end
  end

  module ClassMethods
    def call(*args)
      new(*args).call
    end
  end

  def call
    raise NotImplementedError, "You must implement the `call` method in your command class."
  end

  def success(result = nil)
    CommandResult.new(result: result)
  end

  def failure(errors)
    CommandResult.new(errors: errors)
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end
end
