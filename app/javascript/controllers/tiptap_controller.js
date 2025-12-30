import { Controller } from "@hotwired/stimulus"
import { Editor } from "@tiptap/core"
import StarterKit from "@tiptap/starter-kit"
import CodeBlockLowlight from "@tiptap/extension-code-block-lowlight"
import { createLowlight } from "lowlight"
import ruby from "highlight.js/lib/languages/ruby"
import javascript from "highlight.js/lib/languages/javascript"

// lowlightセットアップ
const lowlight = createLowlight()
lowlight.register("ruby", ruby)
lowlight.register("javascript", javascript)

export default class extends Controller {
  static targets = ["editor", "input"]
  static values = {
    content: String
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
    const extensions = [
      StarterKit.configure({
        codeBlock: false,
      }),
      CodeBlockLowlight.configure({
        lowlight,
        defaultLanguage: "ruby",
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
}
