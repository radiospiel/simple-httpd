# rubocop:disable Naming/UncommunicativeMethodParamName, Lint/UnusedMethodArgument

module ExplicitService
  include ::Simple::Service

  def explicit_test(a:, b:)
    # "this is a test; a is #{a.inspect}, b is #{b.inspect}"
    "hello from ExplicitService#test"
  end

  def explicit_echo(one, two, a:, b:)
    "one: [#{one}]/two: [#{two}]/a: [#{a}]/b: [#{b}]"
  end

  def echo_context
    ::Simple::Service.context.inspect
  end
end
