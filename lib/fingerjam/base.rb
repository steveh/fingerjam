require "digest/md5"
require "yaml"

module Fingerjam
  class Base

    cattr_accessor :host
    cattr_accessor :lockfile
    cattr_accessor :enabled
    cattr_accessor :hashes

    class << self

      def configure(opts = {})
        self.host = opts.delete(:host)
        self.lockfile = opts.delete(:lockfile) || File.join(Rails.root, "config", "assets.lock.yml")
        self.hashes = YAML.load_file(lockfile)
        self.enabled = hashes.present? && Rails.env.production?
      rescue Errno::ENOENT
        self.hashes = {}
        self.enabled = false
      end

      def enabled?
        enabled
      end

      def hashed?(relative_path)
        hashes.has_key?(relative_path)
      end

      def hashed_path(relative_path)
        generate_path(relative_path, hashes[relative_path])
      end

      def generate_path(relative_path, hash)
        "http://%s/%s%s" % [host, hashes[relative_path], relative_path]
      end

      def extensions
        %w{js css png jpg gif}
      end

      def generate_hash(absolute_path)
        Digest::MD5.hexdigest(absolute_path.to_s)
      end

    end

  end
end