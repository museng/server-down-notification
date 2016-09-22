#/usr/bin/env ruby

# ##########################
# 服务器状态电话通知小助手
# 需要在云之讯注册账号
# (http://www.ucpaas.com)
# ##########################

require 'sinatra'
require 'net/http'
require 'uri'
require 'openssl'

require 'json'
require 'digest'
require 'base64'

USER_SID = '********************************'      # 用户SID
AUTH_TOKEN = '********************************'    # 接口调用AuthToken
APP_ID      = '********************************'   # 应用ID
CONFIG_PHONE = ['183*****074']                     # 配置的需要发送语音验证码的手机号

API_PHONE_CODE = "https://api.ucpaas.com/2014-06-30/Accounts/#{USER_SID}/Calls/voiceCode?sig="   # 发送语音验证码的接口

# Controllers
# WSDL: Send Phone Call To All Known User
get '/smscode/:code' do
    puts "send code is: #{params[:code]}"
    CONFIG_PHONE.each {|phone| send_phone_call phone, params[:code]}
end

# Helper Methods

# Send Phone Call Api Call
def send_phone_call(phone, code)
    tm = (Time.now - 120).localtime.strftime '%Y%m%d%H%M%S'
    puts "time is: #{tm}"
    auth_token    = generate_authorization tm
    sig           = generate_sig           tm
    puts            "sig is: #{sig}"
    puts            "auth_token is #{auth_token}"
    uri           = URI (API_PHONE_CODE + sig)
    req = Net::HTTP::Post.new("#{API_PHONE_CODE}#{sig}",
                            'Content-Type'   => 'application/json;charset=utf-8',
                            'Authorization'  => auth_token,
                            'Accept'         => 'application/json')
    req.body = %{
        {
            "voiceCode": {
                "appId": "#{APP_ID}",
                "to":    "#{phone}",
                "type":  "0",
                "verifyCode": "#{code}",
                "displayNum": "075512345678",
                "playTimes":  "3"
            }
        }
    }
    puts "host: #{uri.hostname}, path: #{uri.path}, port: #{uri.port}"

    res = Net::HTTP.start(uri.hostname, uri.port,
                         :use_ssl => true,
                         :verify_mode => OpenSSL::SSL::VERIFY_NONE
                         ){|http| http.request(req)}
    puts res.body
    res
end

def generate_authorization(tm)
    Base64.strict_encode64("#{USER_SID}:#{tm}").strip
end

def generate_sig(tm)
    Digest::MD5.new.hexdigest("#{USER_SID}#{AUTH_TOKEN}#{tm}").upcase
end
