# encoding: utf-8

class WatcherReferral < ActiveRecord::Base
  belongs_to :user

  has_many :referral_photos, dependent: :destroy

  STATUSES = ["pending", "approved", "rejected", "problem"]

  validates :user, presence: true
  validates :status, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  #scope :not_done, where("status = 'approved' OR status = 'problem'")
  scope :recent, order(:created_at)
  scope :pending, where(:status => "pending")

  after_initialize :set_default_status
  after_save :update_watcher_status

  attr_accessible :comment

  def status
    ActiveSupport::StringInquirer.new("#{read_attribute(:status)}")
  end

  def approve!(comment = nil)
    self.status = "approved"
    self.comment = comment

    save
  end

  def reject!(comment = nil)
    self.status = "rejected"
    self.comment = comment

    save
  end

  def problem!(comment = nil)
    self.status = "problem"
    self.comment = comment

    save
  end

  private
    def update_watcher_status
      if status != status_was
        self.user.watcher_status = status
        self.user.save!
      end
    end

    def set_default_status
      self.status = "pending" if self.status.blank?
    end
end
