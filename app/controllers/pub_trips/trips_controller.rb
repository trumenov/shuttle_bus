# frozen_string_literal: true

class ::PubTrips::TripsController < ::PubTrips::PubTripsBaseController
  skip_before_action :set_front_side_current_trip, only: %w{index new create}


  def index
    per_page = 24
    # data = ::PubTripsSearchHelper.get_trips_collection(params)
    # events = data[:items]
    search_item = { name: 'Search', prop_name: :search }
    # @filter_items = [search_item] + data[:filter_items]
    ids_sql = ::PubTripsSearchHelper.get_search_where_sql(params[:search].to_s, true)
    @filter_items = [search_item]
    # @items = events.page(params_page).per(per_page)
    @items = Trip.active.published_only.where(ids_sql).page(params_page).per(per_page)
  end

  def show
    @item = @front_side_current_trip
  end

  def chat
    @new_msg = TripChatMsg.new
    @items = load_chat_msgs_list
    @unread_ids = load_unreaded_msgs_ids_and_mark_them_readed(@items)
  end

  def load_chat_msgs_list
    per_page = 30
    main_data[:title] = "Trip \##{ @front_side_current_trip.id } Chat"
    add_breadcrumb 'Chat', chat_trip_path(@front_side_current_trip.id)
    search_attrs = can_current_user_read_trip_chat? ? { trip: @front_side_current_trip } : { id: 0 }
    TripChatMsg.where(search_attrs).order(id: :DESC).page(params_page).per(per_page)
  end

  def load_unreaded_msgs_ids_and_mark_them_readed(msgs)
    result = []
    TripChatMsgUnread.where(user: current_user).where(trip_chat_msg_id: msgs.map(&:id)).includes(:trip_chat_msg).each do |umsg|
      result.push(umsg.trip_chat_msg_id)
      if (umsg.trip_chat_msg.created_at + 5.seconds) < Time.now()
        umsg.destroy!
      end
    end
    result
  end

  def chat_add_msg
    @new_msg = TripChatMsg.new
    new_html = params[:msg_text].strip.gsub(/[\r]+/, "").text_to_html
    if can_current_user_read_trip_chat? && new_html.size_positive?
      new_attrs = { user: current_user, msg_html: new_html }
      @new_msg = @front_side_current_trip.trip_chat_msgs.create!(new_attrs)
      if @new_msg.id && @new_msg.id.positive?
        return redirect_to chat_trip_path(@front_side_current_trip.id)
      end
    end
    @items = load_chat_msgs_list
    @unread_ids = load_unreaded_msgs_ids_and_mark_them_readed(@items)
    flash2 :alert, "Errors found"
    render action: :chat
  end
end
