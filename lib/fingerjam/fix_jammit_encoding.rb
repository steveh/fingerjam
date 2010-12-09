# Monkey patch Jammit to fix encoding issue
module Jammit

  class Compressor

    def compress_js(paths)
      if (jst_paths = paths.grep(Jammit.template_extension_matcher)).empty?
        js = concatenate(paths)
      else
        js = concatenate(paths - jst_paths) + compile_jst(jst_paths)
      end
      js = js.force_encoding('utf-8')
      Jammit.compress_assets ? @js_compressor.compress(js) : js
    end
    
  end
  
end