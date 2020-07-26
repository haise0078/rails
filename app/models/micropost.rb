class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  default_scope -> { order(created_at: :desc) }
  scope :including_replies, ->(replied_to) { where(in_reply_to: replied_to) }
  before_save :set_reply
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validates :image,   content_type: {
    in: %w[image/jpeg image/gif image/png],
    message: "must be a valid image format"
  }, size: {
    less_than: 5.megabytes,
    message: "should be less than 5MB"
  }

  private

  def set_reply
    replied_to = self.content.scan(/@([^\r\n]+)/).first
    if !replied_to.nil? && replied_to.length > 0
      replied_user = User.find_by(name: replied_to)
      if !replied_user.nil?
        self.in_reply_to = replied_user.id
      end
    end
  end
end
