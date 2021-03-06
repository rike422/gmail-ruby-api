module Gmail
  class GmailObject
    include Enumerable
    include Hooks
    define_hooks :after_initialize

    # The default :id method is deprecated and isn't useful to us
    undef :id if method_defined?(:id)

    def initialize(hash = {})
      @values = Hashie::Mash.new hash
      run_hook :after_initialize
    end

    def to_s(*_args)
      JSON.pretty_generate(@values.to_hash)
    end

    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)}>  " + to_s
    end

    def [](k)
      @values[k.to_sym]
    end

    def []=(k, v)
      @values.send("#{k}=", v)
    end

    def to_json(*_a)
      JSON.generate(@values)
    end

    def as_json(*a)
      @values.as_json(*a)
    end

    def detailed
      if self.class == GmailObject
        raise "Can't detail a generic GmailObject. It needs to be a Thread, Message, Draft or Label"
      end

      self.class.get(id)
    end

    def refresh
      if self.class == GmailObject
        raise "Can't refresh a generic GmailObject. It needs to be a Thread, Message, Draft or Label"
      end
      @values = self.class.get(id).values
      self
    end

    alias detailed! refresh
    #
    def to_hash
      Util.symbolize_names(@values.to_hash)
    end

    attr_reader :values

    #
    # def each(&blk)
    #   @values.each(&blk)
    # end
    #
    # def _dump(level)
    #   Marshal.dump([@values, @api_key])
    # end
    #
    # def self._load(args)
    #   values, api_key = Marshal.load(args)
    #   construct_from(values)
    # end
    #
    # if RUBY_VERSION < '1.9.2'
    #   def respond_to?(symbol)
    #     @values.has_key?(symbol) || super
    #   end
    # end
    #
    protected

    def metaclass
      class << self
        self
      end
    end

    #
    # def remove_accessors(keys)
    #   metaclass.instance_eval do
    #     keys.each do |k|
    #       next if @@permanent_attributes.include?(k)
    #       k_eq = :"#{k}="
    #       remove_method(k) if method_defined?(k)
    #       remove_method(k_eq) if method_defined?(k_eq)
    #     end
    #   end
    # end
    #
    # def add_accessors(keys)
    #   metaclass.instance_eval do
    #     keys.each do |k|
    #       next if @@permanent_attributes.include?(k)
    #       k_eq = :"#{k}="
    #       define_method(k) { @values[k] }
    #       define_method(k_eq) do |v|
    #         if v == ""
    #           raise ArgumentError.new(
    #                     "You cannot set #{k} to an empty string." +
    #                         "We interpret empty strings as nil in requests." +
    #                         "You may set #{self}.#{k} = nil to delete the property.")
    #         end
    #         @values[k] = v
    #         @unsaved_values.add(k)
    #       end
    #     end
    #   end
    # end
    #
    def method_missing(name, *args)
      if @values.send(name.to_s + '?')
        @values.send(name)
      else
        begin
          @values.send(name.to_s, args[0])
        rescue
          begin
            super.send(name)
          rescue
            nil
          end
        end
      end
    end

    #
    # def respond_to_missing?(symbol, include_private = false)
    #   super
    # end
  end
end
