class ::Profile::MyStations::StationImgsController < Profile::MyStations::MyStationsBaseController
  before_action :set_current_my_station_img
  skip_before_action :set_current_my_station_img, only: %w{index new create}


  def set_current_my_station_img
    return @current_my_station_img if @current_my_station_img
    add_breadcrumb "Edit", edit_profile_my_station_path(@current_my_station.id)
    add_breadcrumb "MyStationImgs", profile_my_station_station_imgs_path(@current_my_station.id)
    id = params[:eimg_id] || params[:my_station_eimg_id]
    result = @current_my_station.user_station_imgs.detect { |x| x.id.eql?(id.to_i || 0) }
    unless result
      raise ActionController::RoutingError.new("MyStationImgs #{ id } not found in your station[#{ @current_my_station.id }]")
    end
    add_breadcrumb "MyStationImgs \##{ result.id }", result.profile_default_url
    @current_my_station_img = result
    result
  end

  def index
    add_breadcrumb "Edit", edit_profile_my_station_path(@current_my_station.id)
    add_breadcrumb "MyStationImgs", profile_my_station_station_imgs_path(@current_my_station.id)
    # @item = @current_my_station.station_imgs.new()
    @items = @current_my_station.user_station_imgs
  end

  def create
    @item = @current_my_station
    add_breadcrumb "Edit", edit_profile_my_station_path(@current_my_station.id)
    add_breadcrumb "MyStationImgs", profile_my_station_station_imgs_path(@current_my_station.id)
    if @item.can_owner_attach_image?
      if params[:img_file].tempfile.size > 4.megabyte
        @item.errors.add(:user_station_imgs, "is too big. Max 4MB for image.")
      else
        processed = ImageProcessing::MiniMagick.source(params[:img_file].tempfile).resize_to_limit(140, 140).strip.call
        if processed
          acceptable_types = ["image/jpeg", "image/png"]
          if acceptable_types.include?(MIME::Types.type_for(processed.path).first.content_type)
            new_img = @item.user_station_imgs.create!(name: params[:img_file].original_filename, prio: @item.user_station_imgs.count + 1)
            if new_img.image_file.attach(io: params[:img_file].tempfile, filename: params[:img_file].original_filename)
              # if new_img.image_file_sm.attach(io: processed, filename: 'sm_' + params[:img_file].original_filename)
                File.delete(processed.path) if File.exist?(processed.path)
                return success_redirect('Image added', profile_my_station_station_imgs_path(@item.id))
              # else
              #   @item.errors.add(:station_images_sm, "Can not attach station_image_sm")
              # end
            else
              @item.errors.add(:user_station_imgs, "Can not attach station_image")
            end
          else
            @item.errors.add(:user_station_imgs, "must be a JPEG or PNG")
          end
          File.delete(processed.path) if File.exist?(processed.path)
        end
      end
    else
      @item.errors.add(:user_station_imgs, "You can not attach more images to this station.")
    end
    flash2 :alert, "Errors found"
    render action: :index
  end
end
