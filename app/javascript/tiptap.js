import { Editor } from "@tiptap/core"
import StarterKit from "@tiptap/starter-kit"
import Blockquote from "@tiptap/extension-blockquote"
import CodeBlockLowlight from "@tiptap/extension-code-block-lowlight"
import { createLowlight, common } from "lowlight"

const lowlight = createLowlight(common)

// カスタムBlockquote（コールアウト対応）
const CustomBlockquote = Blockquote.extend({
  addAttributes() {
    return {
      type: {
        default: "default",
        parseHTML: (element) => element.getAttribute("data-callout") || "default",
        renderHTML: (attributes) => ({
          "data-callout": attributes.type,
        }),
      },
    }
  },
})

// グローバルに公開
window.TiptapEditor = Editor
window.TiptapStarterKit = StarterKit
window.TiptapCodeBlockLowlight = CodeBlockLowlight
window.TiptapCustomBlockquote = CustomBlockquote
window.tiptapLowlight = lowlight
