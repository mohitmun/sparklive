class String
  def format_url
    if self.blank?
      return self
    elsif self.include?("linkedin.com")
      uri = Addressable::URI.heuristic_parse(self)
      result = uri.domain + uri.path 
      result = result.sub(/\/$/, "")
      return result
    end
    return self.sub(/^https?\:\/\/(www.)?/,'')
  end

  def parse_json
    JSON.parse(self) rescue self
  end
end

class Array
  def html_safe
    result = "<ul>"
    self.each do |item|
      li = "<li><strong>#{item}</strong></li>"
      result = result + li
    end
    result = result + "</ul>"
    return result.html_safe
  end

  def breakup
    result = Hash.new(0)
    self.uniq.each do |a|
      result[a] = self.count(a)
    end
    return result
  end
end
class ActiveRecord::Base     
  #instance method, E.g: Order.new.foo       
  def self.search_col(col, query)
    key = arel_table[col]
    where(key.matches("%#{query}%"))
  end
end
class Hash
  def method_missing(m, *args, &blk)
    fetch(m) { fetch(m.to_s) { super } }
  end
end