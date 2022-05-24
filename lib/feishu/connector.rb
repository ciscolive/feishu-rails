# frozen_string_literal: true

require "active_support/concern"

module Feishu
  extend ActiveSupport::Concern

  module Connector
    # 定义常用的 URL
    AUTH_URL    = "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal"
    USER_ID     = "https://open.feishu.cn/open-apis/user/v1/batch_get_id?mobiles="
    CHAT_ID     = "https://open.feishu.cn/open-apis/chat/v4/list?page_size=20"
    IMAGE_ID    = "https://open.feishu.cn/open-apis/im/v1/images"
    MESSAGE_URL = "https://open.feishu.cn/open-apis/im/v1/messages"

    GROUP_LIST = "https://open.feishu.cn/open-apis/im/v1/chats"
    GROUP_INFO = "https://open.feishu.cn/open-apis/chat/v4/info"
    SEND_TEXT  = "https://open.feishu.cn/open-apis/message/v4/send"

    # 认证成功后，后续请求都携带 TOKEN
    def request
      HTTP.headers(Authorization: "Bearer #{feishu_token}")
    end

    # 根据手机号码查询用户的 USER_ID
    def user_id(mobile)
      url = "#{USER_ID}#{mobile}"
      # 请求后端
      res = request.get(url)
      # 序列化
      ret = JSON.parse(res.body.readpartial)

      # 返回数据
      ret["data"]["mobile_users"].try(:[], mobile).try(:[], 0).try(:[], "user_id")
    end

    # 获取群组的 chat_id
    def chat_id(name)
      # 请求后端
      res = request.get(CHAT_ID)
      # 序列化
      ret = JSON.parse(res.body.readpartial)

      # 返回数据
      ret["data"]["groups"].select { |i| i["name"] == name }.try(:[], 0).try(:[], "chat_id")
    end

    # 上传图片到飞书后台
    def upload_image(image_path)
      # 读取图片
      data = HTTP::FormData::File.new image_path

      # 请求后端
      res = request.post(IMAGE_ID, form: { image_type: "message", image: data })
      ret = JSON.parse res.body.readpartial

      # 返回上传后的序列号
      ret["data"]["image_key"]
    rescue => e
      Rails.logger("上传图片期间捕捉到异常：#{e}")
    end

    # 获取机器人所在的群列表
    def group_list(page_size = 20, page = nil)
      # 请求后端
      res = request.get(GROUP_LIST, params: { page_size: page_size, page_token: page })
      # 序列化
      ret = JSON.parse(res.body.readpartial)
      # 返回数据
      ret["data"]
    end

    # 获取群信息
    def group_members(chat_id)
      # 请求后端
      res = request.get(GROUP_INFO, params: { chat_id: chat_id })
      # 序列化
      ret = JSON.parse(res.body.readpartial)
      # 返回数据
      ret["data"]["members"]
    end

    # 发送文本消息
    def send_text(open_id, text)
      # 请求后端
      res = request.post(SEND_TEXT, json: { open_id: open_id, msg_type: "text", content: { text: text } })
      # 序列化
      JSON.parse(res.body.readpartial)
    end

    # 使用推荐的消息接口
    def send_message(receive_type = "chat_id", receive_id, msg_type, content)
      # 请求后端
      res = request.post(MESSAGE_URL, params: { receive_id_type: receive_type }, json: { receive_id: receive_id, msg_type: msg_type, content: content })
      # 序列化
      JSON.parse(res.body.readpartial)
    end

    # 向特定群组发生消息
    def send_alert(chat_id, title, content, image_path)
      # 获取上传文件路径
      uploaded_image_path = upload_image(image_path)

      # 初始化数据结构
      data = {
        chat_id:  chat_id,
        msg_type: "post",
        content:  {
          post: {
            zh_cn: {
              title:   title,
              content: [
                         [
                           {
                             tag:       "text",
                             un_escape: true,
                             text:      content
                           },
                           {
                             tag:     "at",
                             user_id: "all"
                           },
                         ],
                         [
                           {
                             tag:       "img",
                             image_key: upload_image(image_path),
                             width:     1000,
                             height:    600
                           }
                         ]
                       ]
            }
          }
        }
      }
      # 如果图片不存在则移除相关属性
      data[:content][:post][:zh_cn][:content].pop if uploaded_image_path.blank?

      # 请求后端
      res = request.post(SEND_TEXT, json: data)

      # 序列化
      JSON.parse(res.body.readpartial).to_query

    rescue => e
      Rails.logger("群发消息期间捕捉到异常：#{e}")
    end
  end

  private
    def feishu_token
      # 获取飞书 TOKEN 并缓存
      Rails.cache.fetch("feishu_token", expires_in: 30.minutes) do
        # res = HTTP.post(AUTH_URL, json: { app_id: app_id, app_secret: app_secret })
        res = HTTP.post(AUTH_URL, json: { app_id: Feishu.app_id, app_secret: Feishu.app_secret })
        JSON.parse(res.body.readpartial)["tenant_access_token"]
      end
    end
end
