# encoding: utf-8

class LikesController < ApplicationController
  # GET /likes
  # GET /likes.json
  def index
    @user = User.find(params[:user_id])
    @likes = @user.likes

    respond_to do |format|
      format.html # index.html.erb
      format.csv
    end
  end

  def render_elsewhere
    @user = User.find(params[:user_id])
    render :csv => "index", :template => 'users/index'
  end
end
