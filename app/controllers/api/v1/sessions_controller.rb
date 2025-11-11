module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        super
      end
    end
  end
end
