class AssetsController < ApplicationController
  def show
    asset = Asset.find(params[:id])
    send_file asset.data.path, :type => asset.data.content_type, :disposition => 'inline'
  end
end
