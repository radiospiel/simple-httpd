begin
  require "pry"
rescue LoadError
  class Binding
    def pry
      STDERR.puts "*** 'binding.pry' not supported: add the 'pry-byebug' gem to your Gemfile."
    end
  end
end

begin
  require "byebug"
rescue LoadError
  def byebug
    STDERR.puts "*** 'byebug' not supported: add the 'byebug' gem to your Gemfile."
  end
end
