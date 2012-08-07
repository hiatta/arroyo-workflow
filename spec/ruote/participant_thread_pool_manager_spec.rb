describe ParticipantThreadPoolManager do  
  describe 'create_pool' do
    it 'creates a new pool to be persisted by the manager' do
      pm=ParticipantThreadPoolManager.instance
      pm.create_pool({})
      pm.create_pool()

      lambda {pm.create_pool(nil)}.should raise_error
      lambda {pm.create_pool([])}.should raise_error
      
      lambda {pm.create_pool({max_threads: 0})}.should raise_error
      lambda {pm.create_pool({max_threads: -1})}.should raise_error
      pm.create_pool({min_threads: 0})
      lambda {pm.create_pool({min_threads: -1})}.should raise_error
      
      puts "FOO #{pm.create_pool()}"
      raise StandardError
    end
  end
end