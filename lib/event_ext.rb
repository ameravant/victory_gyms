module EventExt

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def find_for_days_from_now(int)
      find(:all, :conditions => ["date_and_time > ? and date_and_time < ?", (int.send(:day).from_now.strftime("%y-%m-%d") + " 00:00:00").to_time, (int.send(:day).from_now.strftime("%y-%m-%d") + " 23:59:59").to_time])
    end
    def event_extra_methods
      belongs_to :instructor, :class_name => 'Person'
      validates_numericality_of :registration_limit, :only_integer => true, 
      :message => 'must be a whole number', :if => :registration
      include EventExt::InstanceMethods
    end
  end
  
  module InstanceMethods
    def format_time_for_schedule
      if self.date_and_time.strftime("%H").to_i > 12
        (self.date_and_time.strftime("%H").to_i - 12).to_s + ":#{self.date_and_time.strftime('%M')} PM"
      else
        self.date_and_time.strftime("%H:%M") + " AM"
      end
    end
  end
  
end
ActiveRecord::Base.send(:include, EventExt)
Event.send(:event_extra_methods)
