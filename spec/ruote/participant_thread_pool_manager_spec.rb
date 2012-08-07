describe ParticipantThreadPoolManager do  
  describe 'create_pool' do
    it 'creates a new pool to be persisted by the manager' do
      pm=ParticipantThreadPoolManager.instance
      pm.create_pool({})
      pm.create_pool()
      pm.create_pool() =~ /[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}/

      lambda {pm.create_pool(nil)}.should raise_error
      lambda {pm.create_pool([])}.should raise_error
      
      lambda {pm.create_pool({max_threads: 0})}.should raise_error
      lambda {pm.create_pool({max_threads: -1})}.should raise_error
      pm.create_pool({min_threads: 0})
      lambda {pm.create_pool({min_threads: -1})}.should raise_error
      lambda {pm.create_pool({max_threads: 10,min_threads: 11})}.should raise_error
      pm.create_pool({max_threads: 10,min_threads: 10})
      pm.create_pool({max_threads: 10,min_threads: 9})
      
      k=pm.create_pool()
      pm.get_pool(k).should_not == nil
      pm.get_pool(k).process {}
    end
  end
end