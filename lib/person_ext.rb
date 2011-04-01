module PersonExt

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def person_extra_methods
      has_many :events, :foreign_key => "instructor_id"
      include PersonExt::InstanceMethods
    end
  end
  
  module InstanceMethods
  end
  
end
ActiveRecord::Base.send(:include, PersonExt)
Person.send(:person_extra_methods)