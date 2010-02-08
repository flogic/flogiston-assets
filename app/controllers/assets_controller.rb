class AssetsController < ApplicationController
  def show
    param = params[:id].join('/')
    asset = Asset.find_by_handle(param)
    asset = Asset.find(param) unless asset
    send_file asset.data.path, :type => asset.data.content_type, :disposition => 'inline'
  end
end
