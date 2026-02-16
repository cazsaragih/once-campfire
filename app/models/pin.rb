class Pin < ApplicationRecord
  belongs_to :message, touch: true
  belongs_to :creator, class_name: "User", default: -> { Current.user }

  validates :message_id, uniqueness: true

  scope :ordered, -> { order(created_at: :desc) }
end
