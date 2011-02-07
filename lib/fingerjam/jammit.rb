module Jammit
  class Compressor

    # Used by rake fingerjam:package
    def rewrite_asset_path(relative_path, absolute_path)
      if File.exist?(absolute_path)
        Fingerjam::Base.save_cached_url_from_path(relative_path, absolute_path)
      else
        relative_path
      end
    end

  end
end