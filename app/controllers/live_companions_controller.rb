class LiveCompanionsController < ApplicationController
  before_action :logged_in_user

  def new
    @live_companion = LiveCompanion.new
  end

  def show
    @live_companion = LiveCompanion.find(params[:id])
  end

  def create
    @live_companion = current_user.live_companions.build(live_companion_params)
    if @live_companion.save
      flash[:success] = "ライブ同行者の募集が完了しました！"
      redirect_to live_companion_path(@live_companion)
    else
      render 'live_companions/new'
    end
  end

  def edit
    @live_companion = LiveCompanion.find(params[:id])
  end

  def update
    @live_companion = LiveCompanion.find(params[:id])
    if @live_companion.update_attributes(live_companion_params)
      flash[:success] = "ライブ情報が更新されました！"
      redirect_to @live_companion
    else
      render 'edit'
    end
  end

  private

    def live_companion_params
      params.require(:live_companion).permit(:artist_name, :live_name, :live_memo)
    end
end