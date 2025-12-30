import { Editor } from "@tiptap/core"
import StarterKit from "@tiptap/starter-kit"
import CodeBlockLowlight from "@tiptap/extension-code-block-lowlight"
import { createLowlight, common } from "lowlight"

const lowlight = createLowlight(common)

// グローバルに公開
window.TiptapEditor = Editor
window.TiptapStarterKit = StarterKit
window.TiptapCodeBlockLowlight = CodeBlockLowlight
window.tiptapLowlight = lowlight
