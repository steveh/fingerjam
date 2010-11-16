class FingerjamDeployment

  # task :jammit,  do
  #   run_locally "rake assets:package"
  #   run_locally "rake assets:lock"
  # 
  #   root_path = File.expand_path(File.dirname(__FILE__) + "/..")
  # 
  #   lockfile = File.join(root_path, "config", "assets.lock.yml")
  # 
  #   YAML.load_file(lockfile).each do |path, hash|
  #     src = "#{root_path}/public#{path}"
  #     dst = "/srv/www/cache.tu.is/public/#{hash}#{path}"
  #     run "mkdir -p #{File.dirname(dst)}"
  #     top.upload src, dst
  #   end
  # 
  #   top.upload lockfile, "#{release_path}/config/assets.lock.yml"
  # end

  def self.define_task(context, task_method = :task, opts = {})
    context.send :namespace, :fingerjam do
      send :desc, "Deploy"
      send task_method, :upload, opts do
        raise env.inspect

        # bundle_cmd     = context.fetch(:bundle_cmd, "bundle")
        # bundle_flags   = context.fetch(:bundle_flags, "--deployment --quiet")
        # bundle_dir     = context.fetch(:bundle_dir, File.join(context.fetch(:shared_path), 'bundle'))
        # bundle_gemfile = context.fetch(:bundle_gemfile, "Gemfile")
        # bundle_without = [*context.fetch(:bundle_without, [:development, :test])].compact
        #
        # args = ["--gemfile #{File.join(context.fetch(:current_release), bundle_gemfile)}"]
        # args << "--path #{bundle_dir}" unless bundle_dir.to_s.empty?
        # args << bundle_flags.to_s
        # args << "--without #{bundle_without.join(" ")}" unless bundle_without.empty?
        #
        # run "#{bundle_cmd} install #{args.join(' ')}"
      end
    end
  end

end