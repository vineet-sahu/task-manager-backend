module Api
  module V1
    class SessionsController < DeviseTokenAuth::SessionsController
      respond_to :json
    end
  end
end
