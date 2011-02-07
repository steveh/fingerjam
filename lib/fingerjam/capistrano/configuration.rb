Capistrano::Configuration.instance(:must_exist).load do

  set :strategy, Capistrano::Deploy::Strategy::Fingerjam.new(self)
  set :copy_cache, true

  _cset(:cache_host) { "www.example.com" }
  _cset(:cache_protocol) { "https" }

end

