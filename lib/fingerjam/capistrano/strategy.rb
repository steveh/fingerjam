require "pathname"
require "jammit"
require "fingerjam"
require "capistrano/recipes/deploy/strategy/copy"

module Capistrano
  module Deploy
    module Strategy
      class Fingerjam < Copy

        def deploy!
          if File.exists?(copy_cache)
            logger.debug "refreshing local cache to revision #{revision} at #{copy_cache}"
            system(source.sync(revision, copy_cache))
          else
            logger.debug "preparing local cache at #{copy_cache}"
            system(source.checkout(revision, copy_cache))
          end

          # Check the return code of last system command and rollback if not 0
          unless $? == 0
            raise Capistrano::Error, "shell command failed with return code #{$?}"
          end

          logger.debug "copying cache to deployment staging area #{destination}"
          Dir.chdir(copy_cache) do
            FileUtils.mkdir_p(destination)
            queue = Dir.glob("*", File::FNM_DOTMATCH)
            while queue.any?
              item = queue.shift
              name = File.basename(item)

              next if name == "." || name == ".."
              next if copy_exclude.any? { |pattern| File.fnmatch(pattern, item) }

              if File.symlink?(item)
                FileUtils.ln_s(File.readlink(File.join(copy_cache, item)), File.join(destination, item))
              elsif File.directory?(item)
                queue += Dir.glob("#{item}/*", File::FNM_DOTMATCH)
                FileUtils.mkdir(File.join(destination, item))
              else
                FileUtils.ln(File.join(copy_cache, item), File.join(destination, item))
              end
            end
          end

          File.open(File.join(destination, "REVISION"), "w") { |f| f.puts(revision) }

          fingerjam

          logger.trace "compressing #{destination} to #{filename}"
          Dir.chdir(tmpdir) { system(compress(File.basename(destination), File.basename(filename)).join(" ")) }

          upload(filename, remote_filename)
          run "cd #{configuration[:releases_path]} && #{decompress(remote_filename).join(" ")} && rm #{remote_filename}"
        ensure
          FileUtils.rm filename rescue nil
          FileUtils.rm_rf destination rescue nil
        end

        def fingerjam
          logger.trace "packaging assets with fingerjam for #{cache_host} to #{destination}"

          ::Fingerjam::Base.configure(
            :host      => cache_host,
            :protocol  => cache_protocol,
            :root_path => destination
          )

          ::Fingerjam::Base.package_and_lock!
         end

      end
    end
  end
end