require "pathname"
require "yaml"
require "jammit"

namespace :fingerjam do

  desc "Package assets with Jammit"
  task :package => :environment do
    Jammit.package!(:force => true)
  end

  desc "Lock packages to assets.lock.yml"
  task :lock => :environment do
    relative_root = Pathname.new(Rails.root) + "public"

    hashes = {}

    Pathname.glob(relative_root + "**" + "*.{#{Fingerjam.extensions.join(",")}}").each do |absolute_path|
      relative_path = "/" + absolute_path.relative_path_from(relative_root).to_s
      hashes[relative_path] = Fingerjam.generate_hash(absolute_path)
    end

    File.open(Fingerjam.lockfile, "w") do |lockfile|
      lockfile.puts hashes.to_yaml
    end
  end

end