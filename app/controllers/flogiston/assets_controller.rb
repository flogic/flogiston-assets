class Flogiston::AssetsController < ApplicationController
  def show
    param = params[:id].join('/')
    asset = Asset.find_by_handle(param)
    asset = Asset.find(param) unless asset

    if asset.s3?
      redirect_to asset.data.url
    else
      send_file asset.data.path, :type => asset.data.content_type, :disposition => 'inline'
    end
  end
end
