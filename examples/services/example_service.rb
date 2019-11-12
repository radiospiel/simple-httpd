# rubocop:disable Naming/UncommunicativeMethodParamName, Lint/UnusedMethodArgument

module Example; end
module Example::Service
  include ::Simple::Service

  def test(a:, b:)
    # "this is a test; a is #{a.inspect}, b is #{b.inspect}"
    "hello from ExampleService#test"
  end

  def echo(one, two, a:, b:)
    "one: [#{one}]/two: [#{two}]/a: [#{a}]/b: [#{b}]"
  end

  def echo_context
    ::Simple::Service.context.inspect
  end

  def this_is_a_helper!; end

  private

  def this_is_a_private_helper; end
end
