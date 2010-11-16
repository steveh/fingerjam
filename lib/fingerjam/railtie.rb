require "fingerjam"
require "rails"

module Fingerjam
  class Railtie < Rails::Railtie
    initializer "fingerjam.configure_rails_initialization" do
      ActionView::Base.send(:include, Fingerjam::Helpers)
    end

    rake_tasks do
      load "tasks/fingerjam.rake"
    end
  end
end