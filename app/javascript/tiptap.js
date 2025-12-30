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

// グローバルに公開
window.TiptapEditor = Editor
window.TiptapStarterKit = StarterKit
window.TiptapCodeBlockLowlight = CodeBlockLowlight
window.tiptapLowlight = lowlight
