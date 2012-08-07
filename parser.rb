require 'net/http'
require 'nokogiri'
require 'active_support/core_ext/numeric/time.rb'
class Parser
  TYPES = ["Pomodoro", "Short Break", "Long Break"]
  attr_accessor :username, :pomodoro_url
  def initialize(username)
    self.username = username
    @pomodoro_url = "http://tomatoi.st/#{@username}"
  end
  def username=(username)
    @username=username
    @pomodoro_url = "http://tomatoi.st/#{@username}"
  end
  def content
    uri = URI(pomodoro_url)
    res = Net::HTTP.get_response(uri).body
    return res
  end
  def nokogirize(res)
    Nokogiri.parse(res)
  end
  def pomodoros
    doc = nokogirize(self.content)
    pomos = doc.css('li').map do |li|
      hasherize_pomodoros(li)
    end
    return pomos
  end
  def parse_time(time_text)
    if time_text["about"]
      string_time = time_text.split("about\s").last.split("\n").first
      string_time = string_time.split("\s").map {|s| if s["\d"] then s.to_i else s end }
      approximate_time = string_time[0].to_i.send(string_time[1]).ago
    else 
      approximate_time = 1.minute.ago
    end
    return approximate_time
  end
  private
  def hasherize_pomodoros(list_item, pomo_type = "")
    TYPES.each {|t| pomo_type = t if list_item.children.text[t] }
    time_text = list_item.children.css(".time").text
    pomo = {}
    pomo["type"] = pomo_type
    pomo["time"] = parse_time(time_text)
    pomo
  end
end