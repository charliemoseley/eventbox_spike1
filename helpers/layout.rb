class EventBoxWeb < Sinatra::Base
  helpers do
    def current_path
      return "home" if request.path_info == "/"
      request.path_info[1..request.path_info.length]
    end
  end
end