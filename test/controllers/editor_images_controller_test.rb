require "test_helper"

class EditorImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = User.create!(name: "editor_images_author", author: true)

    User::DatabaseAuthentication.create!(
      user: @author,
      email: "editor_images_author@example.com",
      password: "password123"
    )
  end

  def sign_in_as(email)
    post login_path, params: {
      database_authentication: {
        email: email,
        password: "password123"
      }
    }
  end

  def uploaded_image
    file_path = Rails.root.join("test", "fixtures", "files", "test_image.png")
    Rack::Test::UploadedFile.new(file_path, "image/png")
  end

  # =====================================
  # create アクション
  # =====================================

  test "POST /editor_images 画像をアップロードできる" do
    sign_in_as("editor_images_author@example.com")

    # 元のBlobとvariantのBlobが作成される
    assert_difference "ActiveStorage::Blob.count", 2 do
      post editor_images_path, params: { image: uploaded_image }
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.key?("url")
    assert_match %r{/rails/active_storage/representations}, json_response["url"]
  end

  test "POST /editor_images JSONレスポンスにurlキーが含まれる" do
    sign_in_as("editor_images_author@example.com")

    post editor_images_path, params: { image: uploaded_image }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["url"].present?
  end

  # =====================================
  # 認証テスト
  # =====================================

  test "POST /editor_images 未ログインの場合リダイレクト" do
    post editor_images_path, params: { image: uploaded_image }

    assert_redirected_to root_path
  end
end
