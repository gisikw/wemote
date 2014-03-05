module Remo
  module XML
    class << self
      TEMPLATES = {}

      Dir.glob(File.join(File.dirname(__FILE__),'/../../xml/*.xml')).each do |file|
        basename = File.basename(file,'.xml')
        TEMPLATES[basename] = File.read(file)

        define_method basename do |*args|
          t = TEMPLATES[basename].dup
          if (replace = t.scan(/{{\d+}}/).size) != args.size
            raise ArgumentError, "wrong number of arguments calling `#{basename}` (#{args.size} for #{replace})"
          end
          (1..replace).map{|i|t.gsub!("{{#{i}}}",args[i-1].to_s)}
          t
        end

      end
    end
  end
end
