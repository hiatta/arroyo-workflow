# This class encapsulates usage of the Ruote system so that actual workflow jobs need not directly 
module Arroyo
  module Workflow
    module WorkflowJob
            
      # The name of the function that user-defined jobs must implement to execute their work
      JOB_WORKFLOW_METHOD_NAME=:workflow

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def engine
          @engine ||= WorkflowEngine.new.engine
        end

        def participant(*args, &block)
          raise StandardError,"Participant must have a label and class as arguments" unless args and args.size>=2

          pool_opts=args[2] || {}
          pool_opts=pool_opts.select { |k,v| ParticipantThreadPoolManager::VALID_OPTS.include?(k) } 
          pool_key=ParticipantThreadPoolManager.instance.create_pool(pool_opts)
          
          if args.size >= 3
            args[2][:pool_key]=pool_key
          else
            args << { pool_key: pool_key }
          end
          args[2]=args[2].with_indifferent_access
          engine.register_participant(*args, &block)
        end
      
        def define(*args, &block)
          Ruote.define(*args, &block)
        end
            
        def perform(job_parameters, job_message)
          raise StandardError, "Programmer Error: the workflow function must be implemented in the child class" unless self.respond_to?(JOB_WORKFLOW_METHOD_NAME)

          jp=job_parameters ? job_parameters.clone : {}
          jp[:_job_message]=job_message.clone
          
          # get workflow
          pdef=send(JOB_WORKFLOW_METHOD_NAME,jp)
          raise StandardError, "Programmer Error: the workflow function must return a valid workflow" unless pdef and pdef.is_a?(Array) and pdef.size > 2
          
          # run actual job and then block for it to complete
          wfid = engine.launch(pdef, jp.with_indifferent_access)
          engine.wait_for(wfid)
          result=engine.process(wfid)
          
          raise StandardError, "Workflow created an error [#{result.errors.first.message}] with trace: \n#{result.errors.first.trace}\n\n\n" if result and result.errors
        end
      end
    end
  end
end