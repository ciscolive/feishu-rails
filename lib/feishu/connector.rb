require "active_support/concern"

module Feishu
  extend ActiveSupport::Concern
  module Connector
    # 定义常用的 URL
    AUTH_URL    = "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal/"
    USER_INFO   = "https://open.feishu.cn/open-apis/contact/v1/user/batch_get"
    GROUP_LIST  = "https://open.feishu.cn/open-apis/chat/v4/list"
    GROUP_INFO  = "https://open.feishu.cn/open-apis/chat/v4/info"
    SEND_TEXT   = "https://open.feishu.cn/open-apis/message/v4/send/"
    IMAGE_URL   = "https://open.feishu.cn/open-apis/im/v1/images"
    MESSAGE_URL = "https://open.feishu.cn/open-apis/im/v1/messages"

    # 获取飞书 TOKEN 并缓存
    def access_token
      Rails.cache.fetch("feishu_token", expires_in: 2.hours) do
        res = HTTP.post(AUTH_URL, json: { app_id: Config.app_id, app_secret: Config.app_secret })
        JSON.parse(res.body.readpartial)["tenant_access_token"]
      end
    end

    # 认证成功后，后续请求都携带 TOKEN
    def request
      HTTP.headers(Authorization: "Bearer #{access_token}")
    end

    def batch_user_info(open_ids)
      res   = request.get(USER_INFO, params: { open_ids: open_ids })
      users = JSON.parse(res.body.readpartial)

      users["data"]
    end

    # 获取机器人所在的群列表
    def group_list(page_size = 200, page = nil)
      # 请求后端
      res = request.get(GROUP_LIST, params: { page_size: page_size, page_token: page })
      # 序列化
      group_content = JSON.parse(res.body.readpartial)

      group_content["data"]
    end

    # 获取群信息
    def group_info(chat_id)
      # 请求后端
      res = request.get(GROUP_INFO, params: { chat_id: chat_id })
      # 序列化
      group_users_content = JSON.parse(res.body.readpartial)

      group_users_content["data"]["members"]
    end

    #  获取群成员信息
    # def member_list(chat_id)
    #   res = request.get("https://open.feishu.cn/open-apis/chat/v4/members", :params => {:chat_id=> chat_id})
    #   group_users_content = JSON.parse(res.body.readpartial)

    #   member_ids = group_users_content["data"]
    # end

    # 上传图片到飞书后台
    def upload_image(image_path)
      # 读取图片
      data = HTTP::FormData::File.new image_path

      # 请求后端
      res = request.post(IMAGE_URL, form: { image_type: "message", image: data })
      ret = JSON.parse res.body.readpartial
      # 返回上传后的序列号
      ret["data"]["image_key"]
    end

    # 发送文本消息
    def send_text(open_id, text)
      # 请求后端
      res = request.post(SEND_TEXT, json: { open_id: open_id, msg_type: "text", content: { text: text } })
      # 序列化
      JSON.parse(res.body.readpartial)
    end

    # 使用推荐的消息接口
    def send_message(receive_type, receive_id, msg_type, content)
      # 请求后端
      res = request.post(MESSAGE_URL, params: { receive_id_type: receive_type }, json: { receive_id: receive_id, msg_type: msg_type, content: content })
      # 序列化
      JSON.parse(res.body.readpartial)
    end

    # 发生富文本消息
    # def send_alert(chat_id)
    #   data = {
    #     "chat_id":  chat_id,
    #     "msg_type": "post",
    #     "content":  {
    #       "post": {
    #         "zh_cn": {
    #           "title":   title,
    #           "content": [
    #                        [
    #                          {
    #                            "tag":       "text",
    #                            "un_escape": True,
    #                            "text":      content
    #                          },
    #                          {
    #                            "tag":     "at",
    #                            "user_id": self.user_id
    #
    #                          },
    #                        ],
    #                        [
    #                          {
    #                            "tag":       "img",
    #                            "image_key": self.image_key,
    #                            "width":     1000,
    #                            "height":    600
    #                          }
    #                        ]
    #                      ]
    #         }
    #       }
    #     }
    #   }
    # end
  end
end
