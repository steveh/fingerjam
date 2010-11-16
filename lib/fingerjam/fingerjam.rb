require "digest/md5"
require "yaml"

class Fingerjam

  LOCKFILE = File.join(Rails.root, "config", "assets.lock.yml")

  begin
    HASHES = YAML.load_file(LOCKFILE)
    ENABLED = HASHES.present? && Rails.env.production?
  rescue Errno::ENOENT
    HASHES = {}
    ENABLED = false
  end

  class << self

    def lockfile
      LOCKFILE
    end

    def enabled?
      ENABLED
    end

    def hashed?(relative_path)
      HASHES.has_key?(relative_path)
    end

    def hashed_path(relative_path)
      generate_path(relative_path, HASHES[relative_path])
    end

    def generate_path(relative_path, hash)
      "http://%s/%s%s" % [host, HASHES[relative_path], relative_path]
    end

    def host
      "cache.tu.is"
    end

    def extensions
      %w{js css png jpg gif}
    end

    def generate_hash(absolute_path)
      Digest::MD5.hexdigest(absolute_path.to_s)
    end

  end

end