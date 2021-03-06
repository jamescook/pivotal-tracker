class BasicObject #:nodoc:
  instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|instance_eval|proxy_|^object_id$)/ }
end unless defined?(BasicObject)

module PivotalTracker
  class Proxy < BasicObject

    def initialize(owner, target)
      @owner = owner
      @target = target
      @opts = nil
    end

    def all(options={})
      proxy_found(options)
    end

    def find(param, options={})
      return all(options) if param == :all
      return proxy_found(options).detect { |document| document.id == param }
    end

    def <<(*objects)
      objects.flatten.each do |object|
        @found << object
      end
    end

    protected

      def proxy_found(options)
        # Check to see if options have changed
        if @opts == options
          @found || load_found(options)
        else
          load_found(options)
        end
      end

    private

      def method_missing(method, *args, &block)
        @target.send(method, *args, &block)
      end

      def load_found(options)
        @opts = options
        @target.all(@owner, @opts)
      end

  end
end
