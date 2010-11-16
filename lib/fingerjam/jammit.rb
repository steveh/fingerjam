module Jammit
  class Compressor

    # Used by rake fingerjam:package
    def rewrite_asset_path(path, file_path)
      return Fingerjam::Base.generate_path(path, Fingerjam::Base.generate_hash(file_path))

      asset_id = rails_asset_id(file_path)
      (!asset_id || asset_id == '') ? path : "#{path}?#{asset_id}"
    end

  end
end