# feishu-Rails

对接飞书机器人，实现告警推送

## Usage

- include Feishu::Connector 到模块或者类对象；
- 主要实现的方法：[:user_id, :send_text, :group_members, :request, :send_alert, :access_token, :chat_id, :upload_image, :send_message, :group_list]
- 群内推送 send_alert(chat_id, title, content, image_path)
- 上传图片到飞书 upload_image(path) ，建议使用图片绝对路径

## Installation

Add this line to your application's Gemfile:

```ruby
gem "feishu-rails"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install feishu-rails
```

add feishu_rails.rb in config/initializers

```ruby
Feishu.config do |f|
  f.app_id      = "xxx"
  f.app_secret  = "yyy"
  f.encrypt_key = "zzz"
end
```

推送群组告警消息：

```ruby
include Feishu::Connector

Feishu::Connector.send_alert("oc_xxx", "title", "content", "/home/xxx/Codes/xxx.png")

```

## Contributing

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).