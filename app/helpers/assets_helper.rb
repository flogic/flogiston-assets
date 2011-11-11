module AssetsHelper
  def asset_link(handle)
    asset = Asset.find_by_handle(handle)
    return '' unless asset

    return asset.data.url if asset.s3?

    "/assets/#{handle}"
  end
end
