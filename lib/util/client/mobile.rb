# frozen_string_literal: true

class Client::Mobile < Mechanize
  include Logging

  def initialize
    super
    user_agent = 'Mozilla/5.0 (Linux; Android 4.4.4; SAMSUNG-SM-N900A Build/tt) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36'
    @global_args = {}
  end

  def post(uri, query = {}, headers = {})
    uri = inject_global(uri, query)
    logger.debug("POST: #{uri}")
    super(uri, query.to_json, headers)
  end

  def get(uri, parameters = [], referer = nil, headers = {})
    uri = inject_global(uri)
    logger.debug("GET: #{uri}")
    super(uri, parameters, referer, headers)
  end

  def inject_global(uri, query = {})
    uri = inject_base(uri) unless uri.include?('http')

    uri = URI.parse(uri)
    parameters = Rack::Utils.parse_nested_query(uri.query).merge(@global_args)
    parameters['hash'] = Digest::SHA1.hexdigest('2sB2jaeNEG6C01QOTldcgCKO-' + query.to_json)
    "#{uri.scheme}://#{uri.host}/#{uri.path}?#{parameters.to_query}"
  end

  def add_global_arg(name, value)
    @global_args[name] = value
  end

  def inject_base(uri)
    "https://#{Account.main.world}.tribalwars.com.br#{uri}"
  end

  def login
    logger.info('Making mobile login'.on_blue)
    account = Account.main
    parameters = [account.username, account.password, '2.7.8']
    result = post('https://www.tribalwars.com.br/m/m/login', parameters)
    result = JSON.parse(result.body)
    throw Exception.new(result['error']) unless result['error'].nil?
    token = result['result']['token']
    post('https://www.tribalwars.com.br/m/m/worlds', [token])
    result = post("https://#{account.world}.tribalwars.com.br/m/g/login", [token, 2, 'android'])
    add_global_arg('sid', JSON.parse(result.body)['result']['sid'])
    get("https://#{account.world}.tribalwars.com.br/login.php?mobile&2")
    Property.put("#{self.class}_cookies", cookies)
  end
end