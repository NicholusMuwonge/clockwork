# frozen_string_literal: true

class CacheInvalidator
  def invalidate_components_report_cache(cache_key)
    return unless cache_key

    cache_exists = Rails.cache.fetch(cache_key)
    delete_file(cache_exists) if cache_exists
    Rails.cache.delete(cache_key)
  end

  private

  def delete_file(file_path)
    FileUtils.rm_f(file_path)
  end
end
