module Fingerjam
  class Base

    cattr_accessor :protocol
    cattr_accessor :host
    cattr_accessor :cache_prefix

    cattr_accessor :root_path
    cattr_accessor :assets_yml_path
    cattr_accessor :lock_yml_path
    cattr_accessor :public_path
    cattr_accessor :packages_path
    cattr_accessor :cache_path

    cattr_accessor :cached_paths
    cattr_accessor :cached_urls

    cattr_accessor :enabled

    class << self

      def configure(options = {})
        self.protocol        = options.delete(:protocol)     || "https"
        self.host            = options.delete(:host)         || "www.example.com"
        self.cache_prefix    = options.delete(:cache_prefix) || "/cache/"

        self.root_path       = options.delete(:root_path)       || Rails.root
        self.assets_yml_path = options.delete(:assets_yml_path) || File.join(root_path, "config", "assets.yml")
        self.lock_yml_path   = options.delete(:lock_yml_path)   || File.join(root_path, "config", "assets.lock.yml")
        self.public_path     = options.delete(:public_path)     || File.join(root_path, "public")
        self.packages_path   = options.delete(:packages_path)   || File.join(public_path, "packages")
        self.cache_path      = options.delete(:cache_path)      || File.join(public_path, cache_prefix)

        self.cached_paths    = {}

        begin
          self.cached_urls   = YAML.load_file(lock_yml_path)
        rescue
          self.cached_urls   = {}
        end

        self.enabled         = !cached_urls.empty? && Rails.env.production?

        Jammit.const_set("ASSET_ROOT", root_path)
      end

      def enabled?
        enabled
      end

      def cached?(relative_path)
        self.cached_urls.include?(relative_path)
      end

      def cached_url(relative_path)
        self.cached_urls[relative_path]
      end

      def save_cached_url_from_path(relative_path, absolute_path)
        save_cached_path_from_path(relative_path, absolute_path)
        generate_cached_url(relative_path)
      end

      def package_and_lock!
        package
        scan_public
        symlink
        write_lockfile
      end

      private

        def extensions
          %w{js css png jpg gif}
        end

        def save_cached_path_from_path(relative_path, absolute_path)
          self.cached_paths[relative_path] = generate_cached_path_from_absolute(relative_path, absolute_path)
          self.cached_paths[relative_path]
        end

        def calculate_hash(absolute_path)
          Digest::MD5.file(absolute_path.to_s).hexdigest
        end

        def generate_cached_path_from_absolute(relative_path, absolute_path)
          hash = calculate_hash(absolute_path)
          generate_cached_path_from_hash(relative_path, hash)
        end

        def generate_cached_path_from_hash(relative_path, hash)
          extname = File.extname(relative_path)
          "%s%s%s" % [cache_prefix, hash, extname]
        end

        def generate_cached_url(relative_path)
          cached_path = self.cached_paths[relative_path]
          "%s://%s%s" % [protocol, host, cached_path]
        end

        def package
          Jammit.package!({
            :config_path   => assets_yml_path,
            :output_folder => packages_path,
            :force         => true
          })
        end

        def public_pathname
          Pathname.new(public_path)
        end

        def cacheable_public_files
          Pathname.glob(public_pathname + "**" + "*.{#{extensions.join(",")}}")
        end

        def scan_public
          cacheable_public_files.each do |absolute_pathname|
            relative_path = "/" + absolute_pathname.relative_path_from(public_pathname).to_s
            save_cached_path_from_path(relative_path, absolute_pathname.to_s)
          end
        end

        def symlink
          cached_paths.each_pair do |relative_path, cached_path|
            # Strip leading / from relative path to determine absolute path
            src_u_path = File.join(public_path, relative_path[1..relative_path.length])
            dst_u_path = File.join(public_path, cached_path[1..cached_path.length])

            # Gzip version of asset
            src_c_path = File.join(public_path, (relative_path[1..relative_path.length] + ".gz"))
            dst_c_path = File.join(public_path, (cached_path[1..cached_path.length]     + ".gz"))

            # Create root directory
            FileUtils.mkdir_p(File.dirname(dst_u_path))

            # Create relative symlink from RAILS_ROOT/public/cache/$MD5SUM.$EXT to original file
            File.symlink(".." + relative_path,         dst_u_path.to_s) if !File.exists?(dst_u_path)
            File.symlink(".." + relative_path + ".gz", dst_c_path.to_s) if !File.exists?(dst_c_path) && File.exists?(src_c_path)

            cached_urls[relative_path] = generate_cached_url(relative_path)
          end
        end

        def write_lockfile
          puts "writing lockfile #{lock_yml_path}"

          File.open(lock_yml_path, "w") do |lockfile|
            lockfile.puts cached_urls.to_yaml
          end
        end

    end

  end
end