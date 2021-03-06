class RegionalReport

  def self.all
    # их немного, делаю счет наизнанку.
    # ugly but it works!
    violations_by_region_id = WatcherReport.approved.violations.joins(:commission).count(group: 'commissions.region_id' )
    regulations_by_region_id = WatcherReport.approved.regulations.joins(:commission).count(group: 'commissions.region_id' )
    users_by_region_id = WatcherReport.joins(:commission).count(:user_id, :group => :region_id, :distinct => true )

    Region.all.map do |region|
      violations = violations_by_region_id[region.id.to_s]
      regulations = regulations_by_region_id[region.id.to_s]
      users = users_by_region_id[region.id.to_s]

      new(region: region, violations: violations, regulations: regulations, users: users)

    end.reject(&:no_reports?)
  end

  attr_accessor :region, :violations, :regulations, :users

  def initialize(attrs={})
    attrs.each do |key, value|
      send "#{key}=", value
    end
  end

  def total
    violations.to_i + regulations.to_i
  end

  def no_reports?
    total.zero?
  end

  def ratio
    violations.to_f / total unless no_reports?
  end

end
