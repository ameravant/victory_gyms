module EventsHelper
  def link_to_instructor_if_exists(instructor)
    output = ''
    if instructor
      output << 'Instructed by '
      if instructor.profile
        output << link_to(instructor.name, profile_path(instructor.profile))
      else
        output << instructor.name
      end
    end
  end
end