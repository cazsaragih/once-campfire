class Users::ProfilesController < ApplicationController
  before_action :set_user

  def show
    @direct_memberships, @shared_memberships =
      Current.user.memberships.with_ordered_room.partition { |m| m.room.direct? }
  end

  def update
    if params[:user][:availability].present?
      handle_availability_change(params[:user][:availability])
    else
      @user.update user_params
    end

    redirect_to user_profile_url, notice: update_notice
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      params.require(:user).permit(:name, :avatar, :email_address, :password, :bio).compact
    end

    def handle_availability_change(new_availability)
      if new_availability == "away"
        @user.set_manually_away!
      else
        @user.set_manually_active!
      end
    end

    def update_notice
      params[:user][:avatar] ? "It may take up to 30 minutes to change everywhere." : "✓"
    end
end
