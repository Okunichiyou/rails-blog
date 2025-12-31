# frozen_string_literal: true

class EditorImagesController < ApplicationController
  before_action :authenticate_user!

  MAX_WIDTH = 600
  MAX_HEIGHT = 600

  def create
    blob = ActiveStorage::Blob.create_and_upload!(
      io: params[:image],
      filename: params[:image].original_filename,
      content_type: params[:image].content_type
    )

    # 最大サイズに縮小した variant を返す
    variant = blob.variant(resize_to_limit: [ MAX_WIDTH, MAX_HEIGHT ]).processed

    render json: { url: rails_representation_url(variant) }
  end
end
