module InstanceUtils
  @@git_hash_short_val_saved = 0
  def self.git_hash_short_val
    unless @@git_hash_short_val_saved.positive?
      # git_hash = %x{git rev-parse HEAD}.gsub(/[^\d]+/, "")
      # val = (git_hash.size > 2 ? git_hash[0..1] : git_hash).to_i || 0
      git_hash = File.lstat(Rails.root.join('config', 'secrets.yml')).atime.seconds_since_midnight.to_i.to_s
      val = (git_hash[-2..-1] || git_hash).to_i || 0
      @@git_hash_short_val_saved = val.positive? ? val : 1
    end
    @@git_hash_short_val_saved
  end
end
