describe Arroyo::Workflow::WorkflowEngine do  
  describe 'respond_to?' do
    it 'checks to see if either WorkflowEngine or the Ruote Engine respond to a function' do
      we=Arroyo::Workflow::WorkflowEngine.instance
      we.respond_to?(:foobar).should == false
            
      # a function in WorkflowEngine
      we.respond_to?(:restart_engine).should == true
      
      # a function in Ruote::Engine
      we.respond_to?(:respark).should == true
    end
  end  
end