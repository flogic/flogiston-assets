class Flogiston::Admin::AssetsController < AdminController
  def index
    @assets = Asset.all
  end
  
  def new
    @asset = Asset.new
  end
  
  def create
    @asset = Asset.new(params[:asset])
    
    if @asset.save
      redirect_to admin_assets_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @asset = Asset.find(params[:id])
  end
  
  def update
    @asset = Asset.find(params[:id])
    @asset.attributes = params[:asset]
    
    if @asset.save
      redirect_to(admin_assets_path)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    asset = Asset.find(params[:id])
    asset.destroy
    redirect_to admin_assets_path
  end
end
