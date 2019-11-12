module Simple::Service
  class Context
    def initialize
      @hsh = {}
    end

    IDENTIFIER_PATTERN = "[a-z][a-z0-9_]*"
    IDENTIFIER_REGEXP = Regexp.compile("\\A#{IDENTIFIER_PATTERN}\\z")
    ASSIGNMENT_REGEXP = Regexp.compile("\\A(#{IDENTIFIER_PATTERN})=\\z")

    def [](key)
      key = key.to_sym
      @hsh[key]
    end

    def []=(key, value)
      key = key.to_sym
      existing_value = @hsh[key]

      unless existing_value.nil? || existing_value == value
        raise "Cannot overwrite existing context setting #{key.inspect}"
      end

      @hsh[key] = value
    end

    def method_missing(sym, *args, &block)
      if block
        super
      elsif args.count == 0 && sym =~ IDENTIFIER_REGEXP
        self[sym]
      elsif args.count == 1 && sym =~ ASSIGNMENT_REGEXP
        self[$1.to_sym] = args.first
      else
        super
      end
    end

    def respond_to_missing?(sym, include_private = false)
      return true if IDENTIFIER_REGEXP.maptch?(sym)
      return true if ASSIGNMENT_REGEXP.maptch?(sym)

      super
    end
  end
end
