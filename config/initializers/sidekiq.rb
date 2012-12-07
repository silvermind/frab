#============================================================================
# Copyright (c) DiningCity B.V.  All Rights Reserved.
#============================================================================

# Load the redis.yml configuration file
redis_config = YAML.load_file(Rails.root + 'config/redis.yml')[Rails.env]

# Sidekiq SERVER configuration
Sidekiq.configure_server do |config|
	config.redis = {:url => redis_config['url'], :namespace => 'frab_sidekiq'}
end

# Sidekiq CLIENT configuration
Sidekiq.configure_client do |config|
	config.redis = {:url => redis_config['url'], :namespace => 'frab_sidekiq', :size => 1}
end