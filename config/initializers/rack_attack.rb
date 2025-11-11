# config/initializers/rack_attack.rb

class Rack::Attack
    # Throttle configuration
    
    ### Throttle all requests by IP ###
    throttle('req/ip', limit: 300, period: 5.minutes) do |req|
      req.ip
    end
    
    ### Throttle login attempts by email ###
    throttle('logins/email', limit: 5, period: 20.seconds) do |req|
      if req.path == '/api/v1/auth/login' && req.post?
        # Normalize email to prevent case-sensitivity bypass
        req.params['email'].to_s.downcase.gsub(/\s+/, '')
      end
    end
    
    ### Throttle registration attempts ###
    throttle('registrations/ip', limit: 5, period: 1.hour) do |req|
      if req.path == '/api/v1/auth/register' && req.post?
        req.ip
      end
    end
    
    ### Throttle password reset requests ###
    throttle('password_resets/email', limit: 3, period: 1.hour) do |req|
      if req.path == '/api/v1/auth/password' && req.post?
        req.params['email'].to_s.downcase.gsub(/\s+/, '')
      end
    end
    
    ### Block suspicious requests ###
    
    # Block requests with no user agent
    blocklist('block_no_user_agent') do |req|
      req.user_agent.blank?
    end
    
    # Allow specific IPs (your staging/testing servers)
    safelist('allow_local') do |req|
      # Allow localhost
      req.ip == '127.0.0.1' || req.ip == '::1'
    end
    
    ### Custom response for throttled requests ###
    self.throttled_responder = lambda do |env|
      retry_after = (env['rack.attack.match_data'] || {})[:period]
      [
        429, # status
        {
          'Content-Type' => 'application/json',
          'Retry-After' => retry_after.to_s
        },
        [{
          error: 'Rate limit exceeded. Please try again later.',
          retry_after: retry_after
        }.to_json]
      ]
    end
    
    ### Custom response for blocked requests ###
    self.blocklisted_responder = lambda do |env|
      [
        403,
        { 'Content-Type' => 'application/json' },
        [{ error: 'Forbidden' }.to_json]
      ]
    end
  end
  
  # Enable logging (optional but recommended)
  ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, payload|
    req = payload[:request]
    
    if [:throttle, :blocklist].include? req.env['rack.attack.match_type']
      Rails.logger.warn "[Rack::Attack] #{req.env['rack.attack.match_type']}: #{req.ip} #{req.request_method} #{req.fullpath}"
    end
  end