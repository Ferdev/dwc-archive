class DarwinCore
  class Expander
    def initialize(archive_path, tmp_dir)
      @archive_path = archive_path
      @tmp_dir = tmp_dir
      @path = File.join(tmp_dir, 'dwc_' + rand(10000000000).to_s)
      @unpacker = get_unpacker
    end

    def unpack
      clean
      @unpacker.call(@path, @archive_path) if @unpacker
    end

    def path
      @files_path ||= files_path
    end

    def clean
      FileUtils.rm_rf(@path) if FileTest.exists?(@path)
    end

    def files
      return nil unless path && FileTest.exists?(path)
      Dir.entries(path).select {|e| e !~ /[\.]{1,2}$/}.sort
    end
    
    private
    def get_unpacker
      file_type = IO.popen("file -z " + @archive_path).read
      
      if file_type.match(/tar.*gzip/i)
        return proc do |tmp_path, archive_path| 
          FileUtils.mkdir tmp_path
          system "tar -zxvf #{archive_path} -C #{tmp_path}"
        end
      end

      if file_type.match(/Zip/)
        return proc { |tmp_path, archive_path| system "unzip -qq -d #{tmp_path} #{archive_path}" }
      end
      
      return nil
    end
    
    def path_entries(dir)
      Dir.entries(dir).select {|e| e !~ /[\.]{1,2}$/}.sort
    end
      
    def files_path  
      res = nil
      entries = path_entries(@path)
      if entries.include?('meta.xml')
        res = @path
      else
        entries.each do |e|
          check_path = File.join(@path, e)
          if FileTest.directory?(check_path)
            if path_entries(check_path).include?('meta.xml')
              res = check_path
              break
            end
          end
        end
      end
      res
    end
  end


end