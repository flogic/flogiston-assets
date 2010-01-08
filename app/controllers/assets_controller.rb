class AssetsController < ApplicationController
  def show
    asset = Asset.find_by_handle(params[:id])
    asset = Asset.find(params[:id]) unless asset
    send_file asset.data.path, :type => asset.data.content_type, :disposition => 'inline'
  end
end
