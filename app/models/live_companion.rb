class LiveCompanion < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :live_lists, dependent: :destroy
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :artist_name, presence: true, length: { maximum: 30 }
  validates :live_name,   presence: true, length: { maximum: 50 }
  validates :schedule, presence: true
  validate  :date_not_before_today
  validates :live_venue, presence: true
  validates :live_memo, length: { maximum: 140 }

  def feed_comment(live_companion_id)
    Comment.where("live_companion_id = ?", live_companion_id)
  end

  private

    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "：5MBより大きい画像はアップロードできません。")
      end
    end

    def date_not_before_today
      if schedule.nil? || schedule < Date.today
        errors.add(:schedule, "は今日以降のものを選択してください")
      end
    end
end
