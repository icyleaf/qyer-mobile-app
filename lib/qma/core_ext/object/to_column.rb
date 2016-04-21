module QMA
  ##
  # 转换各种类型输出 terminal table 可用的文字
  module ToColumn
    def to_column
      case self
      when Hash
        collect { |k, v| "#{k}: #{v}" }.join("\n")
      when Array
        join("\n")
      else
        to_s
      end
    end
  end
end

class Object
  include QMA::ToColumn
end