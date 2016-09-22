# server-down-notification
简单配置一下，服务器挂掉或者监控超标的时候会自动打电话给你～

## 依赖

* sinatra
* UCPAAS 云之讯的开发者账号(注册送10元。。。)

## 食用方法

### first step.

到[云之讯](http://www.ucpaas.com)注册一个开发者账号，创建一个项目，然后把UID，AUTH_TOKEN，APP_ID，CONFIG_PHONE填好，CONFIG_PHONE需要在云之讯管理控制台填写，测试用项目最多只能填写10个手机号（贵公司不会有10+运维吧～）

### 安装依赖 

```shell
gem install sinatra
```

### and then.

```shell
nohup ruby ./main.rb -p8888 -o0.0.0.0 &
```

### 大功告成～

```shell
curl http://localhost:8888/smscode/111888
```

记住不要把喜欢的歌曲设置为手机铃声，不然会在半夜骂娘的～

## 最后一步

这个小脚本只能提供从网络打电话的功能，要和监控绑定起来还需要配置一下。

### 先写个小脚本使其可以从命令行打电话

```ruby
#!/usr/local/bin/ruby

def show_help
puts %{
Call me program is a simple server side phone caller.
dependent CURL command.
Usage:
    callme code

    code: the integer code you want say to me.
          must be length in 4-8.
}
end

arg = "#{ARGV[0]}"
puts arg
unless ARGV.length == 1
    show_help
    exit
end

num = arg.sub('.', '')[0,7]
puts num.to_i
`sh -c "curl \"http://localhost:8888/smscode/#{num.to_i}\""`
puts "Send phone call success."
```

把这个小脚本放到PATH下面，我放在/usr/sbin中的
再配置nagios命令command.cfg，定义这个命令后在监控通知行为中就可以直接用了

```shell
 define command{
     command_name   callme
     command_line   /usr/sbin/callme $HOSTADDRESS$
     }
```

配置contact.cfg，定制*notification_commands为callme
```
define contact{
         contact_name                    zhongnan    ; Short name of user
         use      generic-contact                    ; Inherit default values from generic-contact template (defined above)
         alias                           plugine     ; Full name of user

         service_notification_period     24x7
         host_notification_period        24x7
         service_notification_options    w,u,c,r,f,s
         host_notification_options       d,u,r,f,s
         host_notification_commands      callme
         service_notification_commands   callme
         }
```

我让程序在挂掉的时候把挂的机器的IP地址用语音报给我，这在多台服务器的时候特别有用。

## 全剧终

提供了一个小小的小技巧，运维人不止有吃不完的短信，还有包送到家的电话～
你可以尝试你熟悉的语音验证码平台而不必用云之讯，嫌nagios难配remote甚至可以自己写个ping或者curl轮询脚本。

# 准备好迎接凌晨4点的洛杉矶了么～ JUST DO OPS
