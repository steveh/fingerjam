Capistrano::Configuration.instance(:must_exist).load do

  namespace :fingerjam do

    desc "Package, lock and upload assets"
    task :upload_public, { :roles => :web } do
      run_locally "rake fingerjam:package"
      run_locally "rake fingerjam:lock"

      lockfile = File.realpath(File.join("config", "assets.lock.yml"))
      public_path = File.realpath(File.join("public"))

      YAML.load_file(lockfile).each do |path, hash|
        local_path = File.join(public_path, path)
        remote_path = File.join(cache_to, hash, path)
        run "mkdir -p #{File.dirname(remote_path)}"
        top.upload(local_path, remote_path)
      end

      top.upload(lockfile, File.join(release_path, "config", "assets.lock.yml"))
    end

    desc "Upload lockfile"
    task :upload_lockfile, { :roles => :app } do
      lockfile = File.realpath(File.join("config", "assets.lock.yml"))
      top.upload(lockfile, File.join(release_path, "config", "assets.lock.yml"))
    end

  end

  after "deploy:finalize_update", "fingerjam:upload_public"
  after "deploy:finalize_update", "fingerjam:upload_lockfile"

end