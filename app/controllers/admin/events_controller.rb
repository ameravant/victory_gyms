class Admin::EventsController < AdminController

  def new
    @event_categories = EventCategory.active
    @event = Event.new
  end

  def edit
    @event_categories = EventCategory.active
    add_breadcrumb @event.name
  end
end

