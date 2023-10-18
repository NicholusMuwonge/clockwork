# frozen_string_literal: true

class CacheHandler
  def self.invalidate_components_report_cache(cache_key)
    return unless cache_key

    cache_exists = Rails.cache.fetch(cache_key)
    delete_file(cache_exists) if cache_exists
    Rails.cache.delete(cache_key)
  end

  def self.cache_file_path(file_path, project_key, expires_in = 4.hours)
    Rails.cache.write(file_cache_name(project_key), file_path.to_s, expires_in:)
  end

  def self.file_cache_name(project_key)
    "#{project_key&.downcase}_components_file_cache"
  end

  private

  def delete_file(file_path)
    FileUtils.rm_f(file_path)
  end
end
