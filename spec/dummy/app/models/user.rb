class User < ActiveRecord::Base
  has_many :likes

  def self.to_csv(enum)
    all.each do |user|
      enum << user.to_csv
		end
  end

  def send_instructions
    Notifier.instructions(self).deliver
  end

  def to_csv
    [
      self.name,
      self.last_name,
      self.address,
      self.email,
      self.created_at.to_s,
      self.updated_at.to_s
    ]
  end
end
