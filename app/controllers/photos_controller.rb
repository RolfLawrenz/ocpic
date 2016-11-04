class PhotosController < ApplicationController

  PHOTOS_FOLDER = "public/images/thumbs"

  def index
    if Camera::CameraManager.instance.connected?

      Camera::CameraManager.instance.refresh
      camera = Camera::CameraManager.instance.camera
      prepare_photos(camera)

      @photo_files = camera.photo_files
      @photo_count = @photo_files.count

      render :index
    else
      render "camera/not_connected"
    end
  end

  private

  def prepare_photos(camera)
    puts "PREPARE PHOTOS"

    @photo_file_date = {}

    # Get list of existing photos in disk photo_folder
    disk_files = Dir["#{PHOTOS_FOLDER}/*"]

    # Get list of photos on camera
    camera_files = camera.photo_files

    # Remove photos in disk folder not in camera folder
    disk_files.each do |disk_file|
      unless camera_files.any? {|f| File.basename(disk_file).include?(f.name) }
        puts "Delete #{disk_file}"
        File.delete(disk_file)
      end
    end

    # Download photos not on folder but in camera
    download_photos = false
    camera_files.each do |camera_file|
      match = false
      disk_files.each do |disk_file|
        if File.basename(disk_file).include?(camera_file.name)
          match = true
        end
      end
      download_photos = true unless match
    end
    camera.download_thumbs(PHOTOS_FOLDER) if download_photos

    # Set photo_file_date
    disk_files = Dir["#{PHOTOS_FOLDER}/*"]
    camera_files.each do |camera_file|
      disk_files.each do |disk_file|
        if File.basename(disk_file).include?(camera_file.name)
          @photo_file_date[camera_file.name] = File.mtime(disk_file)
        end
      end
    end
  end

end
