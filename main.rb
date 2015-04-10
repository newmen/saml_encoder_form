require 'base64'
require 'cgi'
require 'sinatra'
require 'zlib'

def gzdeflate(s)
  Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(s, Zlib::FINISH)
end

def base64_encode(s)
  Base64.encode64(s)
end

def urlencode(s)
  CGI::escape(s)
end

def singleline(s)
  s.gsub("\n", ' ')
end

def encode(s)
  urlencode(singleline(base64_encode(gzdeflate(s))).strip.gsub(' ', ''))
end

def remove_intermediate_speces(s)
  singleline(s.strip).gsub(/>\s+/, '>').gsub(/\s+</, '<').gsub(/\s+/, ' ')
end

# def gzinflate(s)
#   Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(s)
# end

# def base64_decode(s)
#   Base64.decode64(encoded_and_compressed_image)
# end

get '/' do
  erb :index
end

post '/crypt' do
  @provider_url = params['provider_url']
  @add_params = params['add_params']
  @xml = params['xml']

  @result = encode(remove_intermediate_speces(@xml))

  @link_params = [@add_params, "SAMLRequest=#{@result}"]
  @link = "#{@provider_url}?#{@link_params.join('&')}" if @provider_url && !@provider_url.empty?

  erb :index
end
