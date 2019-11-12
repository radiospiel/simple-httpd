module Simple::Service
  class Action
    ArgumentError = ::Simple::Service::ArgumentError

    IDENTIFIER_PATTERN = "[a-z][a-z0-9_]*"
    IDENTIFIER_REGEXP = Regexp.compile("\\A#{IDENTIFIER_PATTERN}\\z")

    def self.build_all(service_module:)
      service_module.public_instance_methods(false)
                    .grep(IDENTIFIER_REGEXP)
                    .inject({}) { |hsh, name| hsh.update name => Action.new(service_module, name) }
    end

    attr_reader :service
    attr_reader :name
    attr_reader :arguments
    attr_reader :parameters

    def initialize(service, name)
      instance_method = service.instance_method(name)

      @service = service
      @name = name
      @arguments = []
      @parameters = []

      instance_method.parameters.each do |kind, parameter_name|
        case kind
        when :req, :opt then @arguments << parameter_name
        when :keyreq, :key then @parameters << parameter_name
        else
          raise ArgumentError, "#{full_name}: no support for #{kind.inspect} arguments, w/parameter #{parameter_name}"
        end
      end
    end

    # build a service_instance and run the action, with arguments constructed from
    # args_hsh and params_hsh
    def invoke(args_hsh, params_hsh)
      args_hsh ||= {}
      params_hsh ||= {}

      # build arguments array
      args = extract_arguments(args_hsh)
      args << extract_parameters(params_hsh) unless parameters.empty?

      # run the action. Note: public_send is only
      # an extra safeguard; since actions are already built off public methods
      # there should be no way to call a private service method.
      service_instance = service.build_service_instance
      service_instance.public_send(@name, *args)
    end

    private

    def extract_arguments(args_hsh)
      arguments.map do |name|
        args_hsh.fetch(name.to_s) { raise ArgumentError, "Missing argument in request body: #{name}" }
      end
    end

    def extract_parameters(params_hsh)
      # Note: in contrast to arguments that are being read from the body parameters that
      # are not submitted are being ignored (and filled in by +nil+).
      #
      # Note 2: The parameter names **must** be Symbols, not Strings, otherwise
      # the service_instance.send invocation later would not fill in keyword
      # arguments from the parameters hash.
      parameters.inject({}) do |hsh, parameter|
        hsh.update parameter => params_hsh.fetch(parameter, nil)
      end
    end

    def full_name
      "#{service}##{name}"
    end
  end
end
