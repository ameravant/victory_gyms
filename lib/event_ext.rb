module EventExt

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def event_extra_methods
      belongs_to :instructor, :class_name => 'Person'
      validates_numericality_of :registration_limit, :only_integer => true, 
        :message => 'must be a whole number', :if => :registration
      include EventExt::InstanceMethods
    end
  end
  
  module InstanceMethods
  end
  
end
ActiveRecord::Base.send(:include, EventExt)
Event.send(:event_extra_methods)
