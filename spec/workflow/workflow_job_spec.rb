describe Arroyo::Workflow::WorkflowJob do  
  
  class TestParticipantOne
    include Ruote::LocalParticipant
    def consume(workitem)
      reply(workitem)
    end
  end    
  
  class BaseTestJob
    include Arroyo::Workflow::WorkflowJob    
    ARROYO_JOB_NAME="test_job"    
  end

  class TestJobOne < BaseTestJob
    def self.workflow(job_parameters)
      participant "five", TestParticipantOne, { test_string: "test1", max_threads: 1 }
      define {sequence { five } }
    end
  end

  class TestJobTwo < BaseTestJob
    def self.workflow(job_parameters)
      participant "six", TestParticipantOne, { test_string: "test2", max_threads: 1 }
      []
    end
  end

  class TestJobThree < BaseTestJob
    def self.workflow(job_parameters)
      participant "seven", TestParticipantOne, { test_string: "test2", max_threads: 1 }
      {}
    end
  end

  describe 'participant' do
    it 'registers a participant so that it may be called in a workflow' do
      BaseTestJob.participant(/.*zero.*/, TestParticipantOne, { test_string: "test0" })
      BaseTestJob.participant("one", TestParticipantOne, { test_string: "test1", max_threads: 1 })
      BaseTestJob.participant("two", TestParticipantOne)
      BaseTestJob.participant("three", TestParticipantOne, { max_threads: 10 })
      
      # WorkflowJob.engine.participant queries for participants; WorkflowJob.participant adds participants
      BaseTestJob.engine.participant_list.size.should==4
      BaseTestJob.engine.participant("zero").is_a?(TestParticipantOne).should == true
      BaseTestJob.engine.participant("asdfsdzeroasdfads").is_a?(TestParticipantOne).should == true
      BaseTestJob.engine.participant("one").is_a?(TestParticipantOne).should == true
      BaseTestJob.engine.participant("one ").should == nil
      
      lambda {BaseTestJob.participant("four")}.should raise_error
      lambda {BaseTestJob.participant(TestParticipantOne)}.should raise_error      
      
      BaseTestJob.engine.participant_list.each do |p|
        args=p.to_a.last.last
        if args["max_threads"]
          ParticipantThreadPoolManager.instance.get_pool(args['pool_key']).instance_variable_get('@max_size').to_i == args["max_threads"]
        end
      end
    end
  end  

  describe 'perform' do
    it 'executes the actual workflow' do
      lambda {BaseTestJob.perform({})}.should raise_error
      lambda {TestJobTwo.perform({})}.should raise_error
      lambda {TestJobThree.perform({})}.should raise_error
      TestJobOne.perform({})
    end
  end  
end