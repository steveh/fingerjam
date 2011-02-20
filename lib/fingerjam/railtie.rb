require "fingerjam"
require "rails"

module Fingerjam
  class Railtie < Rails::Railtie
    initializer "fingerjam.configure_rails_initialization" do
      Fingerjam::Base.configure

      ActionView::Base.send(:include, Fingerjam::Helpers)
    end
  end
end