require "fingerjam/deployment"

Capistrano::Configuration.instance(:must_exist).load do
  FingerjamDeployment.define_task(self, :task, { :roles => :web, :except => { :no_release => true } })
end