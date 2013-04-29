class EventBoxWeb < Sinatra::Base
  helpers do
    def current_user
      @current_user ||= User.find session[:user_id] if session[:user_id]
    end

    def protected_page
      unless current_user
        flash[:error] = "You need to be logged in to access this page."
        redirect '/'
      end
    end
  end
end