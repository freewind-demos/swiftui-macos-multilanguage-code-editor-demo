# SwiftUI macOS 多语言代码编辑器

## 简介

这个 Demo 用 SwiftUI 做一个 macOS 窗口，窗口里放可编辑的代码编辑器。

编辑器直接使用第三方组件 `ZeeZide/CodeEditor`，底层接 `Highlightr`，因此可以直接获得多语言语法高亮。

## 快速开始

### 环境要求

- macOS 14+
- Xcode 15+
- XcodeGen

### 运行

```bash
cd swiftui-macos-multilanguage-code-editor-demo
chmod +x scripts/build.sh scripts/build-release.sh
xcodegen generate
open SwiftUIMultilanguageCodeEditorDemo.xcodeproj
```

也可以命令行构建：

```bash
./scripts/build.sh
```

## 概念讲解

### 第三方编辑器组件

核心代码：

```swift
CodeEditor(
    source: $text,
    language: selectedSample.language,
    theme: .atelierSavannaLight,
    flags: .defaultEditorFlags
)
```

这里没有自己桥接 `NSTextView`，而是直接用 `CodeEditor`。

它已经把：

- 文本编辑
- 语法高亮
- 智能缩进

这些常见能力封好了，适合这种“先跑起来”的需求。

### 多语言切换

通过 `Picker` 切换当前语言，同时替换示例代码：

```swift
Picker("语言", selection: $selectedSampleID) {
    ForEach(samples) { sample in
        Text(sample.title).tag(sample.id)
    }
}
.onChange(of: selectedSampleID, initial: true) { _, _ in
    text = selectedSample.text
}
```

这样每次切语言时：

- 高亮规则会切换
- 编辑器内容也会切换成对应示例

### 语言模型

每个示例都绑定一个 `CodeEditor.Language`：

```swift
struct CodeSample: Identifiable, Hashable {
    let id: String
    let title: String
    let language: CodeEditor.Language
    let text: String
}
```

只要第三方库支持的语言，都可以继续往数组里加。

## 完整示例

```swift
import CodeEditor
import SwiftUI

struct CodeSample: Identifiable, Hashable {
    let id: String
    let title: String
    let language: CodeEditor.Language
    let text: String
}

struct ContentView: View {
    private let samples: [CodeSample] = [
        CodeSample(id: "swift", title: "Swift", language: .swift, text: "print(\"hello\")"),
        CodeSample(id: "javascript", title: "JavaScript", language: .javascript, text: "console.log('hello')"),
        CodeSample(id: "python", title: "Python", language: .python, text: "print('hello')"),
        CodeSample(id: "json", title: "JSON", language: .json, text: "{ \"hello\": true }"),
    ]

    @State private var selectedSampleID = "swift"
    @State private var text = ""

    private var selectedSample: CodeSample {
        samples.first(where: { $0.id == selectedSampleID }) ?? samples[0]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("语言", selection: $selectedSampleID) {
                ForEach(samples) { sample in
                    Text(sample.title).tag(sample.id)
                }
            }
            .onChange(of: selectedSampleID, initial: true) { _, _ in
                text = selectedSample.text
            }

            CodeEditor(
                source: $text,
                language: selectedSample.language,
                theme: .atelierSavannaLight,
                flags: .defaultEditorFlags
            )
        }
        .padding()
    }
}
```

## 注意事项

- 首次打开工程时，Xcode 会拉取 Swift Package 依赖
- 若命令行构建失败，先确认 `xcode-select -p` 指向完整 Xcode
- 这个 Demo 重点是“可编辑 + 多语言高亮”，没额外做自动补全、LSP、diagnostics

## 完整讲解（中文）

这个需求本质上分两块：一块是“窗口里要有 Editor”，另一块是“Editor 要支持多语言高亮”。

如果自己从 SwiftUI 原生 `TextEditor` 起步，要么接受没有真正代码高亮，要么就得继续桥接 `NSTextView`，再自己处理着色、滚动、行号、缩进。这条路能做，但对 demo 来说太重。

所以这里直接选现成第三方组件 `CodeEditor`。它本身就是给 SwiftUI 用的代码编辑器包装，接入方式很轻。你只要给它一个文本绑定、一个语言类型、一个主题，再开几个编辑 flag，就已经有比较像样的代码编辑体验了。

多语言部分也没必要做复杂架构。这个 demo 只维护一个 `samples` 数组，每项里放标题、语言类型、示例代码。上面用一个 `Picker` 选语言，下面把当前 `language` 和 `text` 传给 `CodeEditor`。这样切换语言时，用户能立刻看到不同语言的高亮效果，也能继续直接编辑内容。

因此这个 demo 的核心价值不是“自己造编辑器”，而是演示：在 macOS 的 SwiftUI App 里，怎样用最少代码接一个能编辑、能显示多语言高亮的代码窗口。如果后面你要扩展到更多语言、主题切换，或者文件打开保存，继续在这个结构上加就行。
