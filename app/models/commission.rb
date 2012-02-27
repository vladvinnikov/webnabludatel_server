# encoding: utf-8

class Commission < ActiveRecord::Base
  has_many :user_locations, dependent: :destroy
  has_many :users, through: :user_locations
  has_many :watcher_reports, dependent: :destroy

  belongs_to :region

  # TODO: add validations

  STATUSES = %W(pending approved rejected)

  validates :status, presence: true, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    class_eval <<-EOF
    scope :#{status}, where(status: :#{status})

    EOF
  end

  before_validation :set_default_status

  geocoded_by :address
  after_validation :geocode

  def status
    ActiveSupport::StringInquirer.new("#{read_attribute(:status)}")
  end

  protected
    def set_default_status
      self.status = "pending"
    end
end
