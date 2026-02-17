module User::AutoPresence
  extend ActiveSupport::Concern

  PRESENCE_TTL = 90.seconds

  class_methods do
    def sweep_stale_presence
      where("active_connections > 0 AND last_active_at < ?", PRESENCE_TTL.ago).find_each do |user|
        user.update!(active_connections: 0, availability: :away)
      end

      where(active_connections: 0, availability: :online, manually_away: false).update_all(availability: :away)
    end
  end

  def mark_connected
    self.class.update_counters(id, active_connections: 1)
    touch(:last_active_at)
    reload
    auto_set_online unless manually_away?
  end

  def mark_disconnected
    self.class.update_counters(id, active_connections: -1)
    self.class.where(id: id).where("active_connections < 0").update_all(active_connections: 0)
    reload
    auto_set_away if active_connections < 1
  end

  def refresh_presence
    touch(:last_active_at)
  end

  def set_manually_away!
    update!(manually_away: true, availability: :away)
  end

  def set_manually_active!
    update!(manually_away: false, availability: :online)
  end

  private
    def auto_set_online
      update!(availability: :online) unless online?
    end

    def auto_set_away
      update!(availability: :away) unless away?
    end
end
