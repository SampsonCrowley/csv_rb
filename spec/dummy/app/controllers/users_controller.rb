# encoding: utf-8

class UsersController < ApplicationController
  respond_to :csv, :html
  layout Proc.new { |c| return (c.request.format.symbol == :csv ? false : :default )}

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.csv
    end
  end

  def show
    @user = User.find(params[:id])
    respond_with(@user) do |format|
      format.csv { render "respond_with.csv.csvrb" }
    end
  end

  def send_instructions
    @user = User.find(params[:user_id])
    @user.send_instructions
    render plain: "Email sent"
  end

  def export
    @user = User.find(params[:id])
    respond_to do |format|
      format.csv do
        render csv: "export", filename: "export_#{@user.id}"
      end
    end
  end
end
