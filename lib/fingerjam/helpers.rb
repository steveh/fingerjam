module FingerjamHelpers

  # Used by Rails view helpers
  def rewrite_asset_path(source, path = nil)
    return Fingerjam.hashed_path(source) if Fingerjam.enabled? && Fingerjam.hashed?(source)

    if path && path.respond_to?(:call)
      return path.call(source)
    elsif path && path.is_a?(String)
      return path % [source]
    end

    asset_id = rails_asset_id(source)
    if asset_id.blank?
      source
    else
      source + "?#{asset_id}"
    end
  end

end