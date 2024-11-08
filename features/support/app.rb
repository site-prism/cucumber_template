# frozen_string_literal: true

class App
  # Add in each page here then you can just access them using @app.page_one e.t.c.
  #
  # One thing to note is that if you load your pages verbosely, then load validations are
  # ran. But if you don't load them, you might want to append .tap(&:when_loaded) to the
  # memoization call for the method. This ensures load validations are ran
  def page_one
    @page_one ||= PageOne.new
  end

  def page_two
    @page_two ||= PageTwo.new
  end
end
