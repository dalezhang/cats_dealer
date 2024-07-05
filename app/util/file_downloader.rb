class FileDownloader
  def self.download(url, file_path)
    begin
      response = HTTParty.get(url)
      
      tempfile = Tempfile.new('download')
      
      tempfile.write(response.body)
      tempfile.rewind
      
      FileUtils.mv(tempfile.path, file_path)
      
    rescue StandardError => e
      Rails.logger.error("Error downloading file from #{url}: #{e.message}")
      raise e
    ensure
      tempfile&.close!
    end
  end
end
