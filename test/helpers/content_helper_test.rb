require "test_helper"

class ContentHelperTest < ActionView::TestCase
  # =====================================
  # 正常系
  # =====================================

  test "sanitize_tiptap_content 許可されたHTMLタグを保持する" do
    html = "<p>テスト<strong>太字</strong></p>"
    result = sanitize_tiptap_content(html)

    assert_includes result, "<p>"
    assert_includes result, "<strong>"
  end

  test "sanitize_tiptap_content 画像タグを許可する" do
    html = '<img src="/image.jpg" alt="テスト">'
    result = sanitize_tiptap_content(html)

    assert_includes result, "<img"
    assert_includes result, 'src="/image.jpg"'
    assert_includes result, 'alt="テスト"'
  end

  test "sanitize_tiptap_content コールアウト属性を許可する" do
    html = '<blockquote data-callout="info">情報</blockquote>'
    result = sanitize_tiptap_content(html)

    assert_includes result, 'data-callout="info"'
  end

  test "sanitize_tiptap_content コードブロックのclass属性を許可する" do
    html = '<pre class="language-ruby"><code>puts "hello"</code></pre>'
    result = sanitize_tiptap_content(html)

    assert_includes result, 'class="language-ruby"'
  end

  # =====================================
  # XSS対策
  # =====================================

  test "sanitize_tiptap_content scriptタグを除去する" do
    html = '<p>テスト</p><script>alert("XSS")</script>'
    result = sanitize_tiptap_content(html)

    # scriptタグは除去される（中身はテキストとして残るが実行されない）
    assert_not_includes result, "<script>"
  end

  test "sanitize_tiptap_content onclickなどのイベントハンドラを除去する" do
    html = '<p onclick="alert(1)">テスト</p>'
    result = sanitize_tiptap_content(html)

    assert_not_includes result, "onclick"
  end

  test "sanitize_tiptap_content javascript:スキームを除去する" do
    html = '<a href="javascript:alert(1)">リンク</a>'
    result = sanitize_tiptap_content(html)

    assert_not_includes result, "javascript:"
  end

  test "sanitize_tiptap_content iframeタグを除去する" do
    html = '<iframe src="https://evil.com"></iframe><p>テスト</p>'
    result = sanitize_tiptap_content(html)

    assert_not_includes result, "<iframe"
    assert_includes result, "<p>テスト</p>"
  end

  # =====================================
  # エッジケース
  # =====================================

  test "sanitize_tiptap_content nilの場合は空文字を返す" do
    result = sanitize_tiptap_content(nil)

    assert_equal "", result
  end

  test "sanitize_tiptap_content 空文字の場合は空文字を返す" do
    result = sanitize_tiptap_content("")

    assert_equal "", result
  end

  test "sanitize_tiptap_content html_safeな結果を返す" do
    result = sanitize_tiptap_content("<p>テスト</p>")

    assert result.html_safe?
  end
end
