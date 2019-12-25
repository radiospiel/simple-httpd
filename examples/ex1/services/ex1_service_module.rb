# Not a real service, but still loaded automatically when mounting ex1
module Ex1ServiceModule
  extend self

  def hello_world
    "hello_world"
  end
end
