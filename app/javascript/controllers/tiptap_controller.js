import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor", "input", "fileInput"]
  static values = {
    content: String,
    uploadUrl: String
  }

  connect() {
    this.initEditor()
  }

  disconnect() {
    if (this.editor) {
      this.editor.destroy()
    }
  }

  initEditor() {
    const Editor = window.TiptapEditor
    const StarterKit = window.TiptapStarterKit
    const CodeBlockLowlight = window.TiptapCodeBlockLowlight
    const CustomBlockquote = window.TiptapCustomBlockquote
    const Image = window.TiptapImage
    const lowlight = window.tiptapLowlight

    const extensions = [
      StarterKit.configure({
        codeBlock: false,
        blockquote: false,
      }),
      CustomBlockquote,
      CodeBlockLowlight.configure({
        lowlight,
        defaultLanguage: "ruby",
      }),
      Image.configure({
        inline: false,
        allowBase64: false,
      }),
    ]

    this.editor = new Editor({
      element: this.editorTarget,
      extensions,
      content: this.contentValue || "",
      editorProps: {
        attributes: {
          class: "tiptap-editor prose focus:outline-none min-h-[200px] p-4",
        },
      },
      onUpdate: ({ editor }) => {
        if (this.hasInputTarget) {
          this.inputTarget.value = editor.getHTML()
        }
      },
    })
  }

  // ツールバーアクション
  toggleBold() {
    this.editor?.chain().focus().toggleBold().run()
  }

  toggleItalic() {
    this.editor?.chain().focus().toggleItalic().run()
  }

  toggleStrike() {
    this.editor?.chain().focus().toggleStrike().run()
  }

  toggleCode() {
    this.editor?.chain().focus().toggleCode().run()
  }

  toggleCodeBlock() {
    this.editor?.chain().focus().toggleCodeBlock().run()
  }

  toggleBulletList() {
    this.editor?.chain().focus().toggleBulletList().run()
  }

  toggleOrderedList() {
    this.editor?.chain().focus().toggleOrderedList().run()
  }

  toggleBlockquote() {
    this.editor?.chain().focus().toggleBlockquote().run()
  }

  setCalloutType(event) {
    const type = event.currentTarget.dataset.calloutType
    this.editor?.chain().focus().toggleBlockquote().updateAttributes("blockquote", { type }).run()
  }

  setHeading(event) {
    const level = parseInt(event.currentTarget.dataset.level)
    this.editor?.chain().focus().toggleHeading({ level }).run()
  }

  undo() {
    this.editor?.chain().focus().undo().run()
  }

  redo() {
    this.editor?.chain().focus().redo().run()
  }

  openImagePicker() {
    this.fileInputTarget.click()
  }

  async uploadImage(event) {
    const file = event.target.files[0]
    if (!file) return

    const formData = new FormData()
    formData.append("image", file)

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    const response = await fetch(this.uploadUrlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
      },
      body: formData,
    })

    if (response.ok) {
      const { url } = await response.json()
      this.editor?.chain().focus().setImage({ src: url }).run()
    }

    // ファイル選択をリセット
    event.target.value = ""
  }
}
