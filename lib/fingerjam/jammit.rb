require "jammit/compressor"

module Jammit
  class Compressor

    alias :rewrite_asset_path_without_fingerjam :rewrite_asset_path

    def rewrite_asset_path(relative_path, absolute_path)
      if File.exist?(absolute_path)
        Fingerjam::Base.save_cached_url_from_path(relative_path, absolute_path)
      else
        rewrite_asset_path_without_fingerjam(relative_path, absolute_path)
      end
    end

  end
end