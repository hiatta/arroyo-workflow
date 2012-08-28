# This class encapsulates all storage and engine/dashboard concepts from Ruote
module Arroyo
  module Workflow
    class WorkflowEngine

      # The storage mechanism used by the engine
      attr_reader :storage

      # The execution mechanism
      attr_reader :engine

      STORAGE_OPTS = {
        's_dispatch_pool' => [ 'arroyo/ruote/bounded_dispatch_pool', 'Ruote::BoundedDispatchPool' ]
      }
      
      def initialize
        restart_engine
      end
  
      def restart_engine
        @storage = Ruote::HashStorage.new(STORAGE_OPTS)
        @engine = Ruote::Engine.new(Ruote::Worker.new(@storage))
      end
      
      # Delegate to Ruote::Engine
      def method_missing(method, *args, &block)
        return super unless @engine.respond_to?(method)
        @engine.send(method, *args, &block)
      end

      # Delegate to Ruote::Engine
      def respond_to?(method)
        return @engine.respond_to?(method) || super
      end
    end
  end
end