# Extending Ruote's DispatchPool rather than branching
# This class is loaded in Arroyo::Workflow::WorkflowEngine
module Ruote
  class BoundedDispatchPool < Ruote::DispatchPool

    # Re-implements ruote threaded dispatch with thread-pool constraints
    def do_threaded_dispatch(participant, msg)
      msg = Rufus::Json.dup(msg)
      pool_key=msg["participant"].last["pool_key"] if msg and msg["participant"] and msg["participant"].last["pool_key"]
      actual_dispatch = lambda {
        begin
          do_dispatch(participant, msg)
        rescue => exception
          @context.error_handler.msg_handle(msg, exception)
        end
      }
      
      if pool_key
        ParticipantThreadPoolManager.instance.get_pool(pool_key).process do
          actual_dispatch.call
        end
      else
        Thread.new do
          warn_msg="Dispatching participant in a new thread without a managing thread pool"
          if defined?(Rails)
            Rails.logger.warn(warn_msg)
          else
            puts warn_msg
          end
          actual_dispatch.call
        end
      end
    end
  end
end