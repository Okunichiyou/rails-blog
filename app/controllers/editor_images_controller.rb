# frozen_string_literal: true

class EditorImagesController < ApplicationController
  before_action :authenticate_user!

  def create
    blob = ActiveStorage::Blob.create_and_upload!(
      io: params[:image],
      filename: params[:image].original_filename,
      content_type: params[:image].content_type
    )

    render json: { url: url_for(blob) }
  end
end
