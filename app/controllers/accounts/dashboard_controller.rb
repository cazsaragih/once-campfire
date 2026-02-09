class Accounts::DashboardController < ApplicationController
  before_action :ensure_can_administer

  TABLES = {
    "users"              => User,
    "sessions"           => Session,
    "accounts"           => Account,
    "rooms"              => Room,
    "memberships"        => Membership,
    "messages"           => Message,
    "bans"               => Ban,
    "boosts"             => Boost,
    "webhooks"           => Webhook,
    "push_subscriptions" => Push::Subscription,
    "searches"           => Search,
    "calls"              => Call,
    "call_participants"  => CallParticipant
  }.freeze

  SENSITIVE_FIELDS = {
    "password_digest" => :filtered,
    "bot_token"       => :truncate,
    "token"           => :truncate,
    "auth_key"        => :truncate,
    "p256dh_key"      => :truncate
  }.freeze

  PER_PAGE = 50

  def index
    @table_stats = TABLES.map { |name, model| { name: name, count: model.count } }
  end

  def show
    @table_name = params[:table]
    @model = TABLES[@table_name]
    return head(:not_found) unless @model

    @columns = @model.column_names
    @page = [ params[:page].to_i, 1 ].max
    @total_count = @model.count
    @total_pages = (@total_count.to_f / PER_PAGE).ceil
    @records = @model.order(id: :desc).offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  helper_method :mask_value

  private
    def mask_value(column, value)
      return value if value.nil?

      case SENSITIVE_FIELDS[column]
      when :filtered then "[FILTERED]"
      when :truncate then value.to_s.truncate(12)
      else value
      end
    end
end
