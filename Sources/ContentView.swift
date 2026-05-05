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
        CodeSample(
            id: "swift",
            title: "Swift",
            language: .swift,
            text: """
            import Foundation

            struct User: Codable {
                let id: Int
                let name: String
            }

            let users = [
                User(id: 1, name: "Ada"),
                User(id: 2, name: "Linus"),
            ]

            print(users.map(\\.name).joined(separator: ", "))
            """
        ),
        CodeSample(
            id: "javascript",
            title: "JavaScript",
            language: .javascript,
            text: """
            async function loadUsers() {
              const res = await fetch("/api/users")
              if (!res.ok) {
                throw new Error("request failed")
              }

              const users = await res.json()
              return users.map((user) => user.name)
            }
            """
        ),
        CodeSample(
            id: "python",
            title: "Python",
            language: .python,
            text: """
            from dataclasses import dataclass

            @dataclass
            class User:
                id: int
                name: str

            users = [User(1, "Grace"), User(2, "Ken")]
            print(", ".join(user.name for user in users))
            """
        ),
        CodeSample(
            id: "json",
            title: "JSON",
            language: .json,
            text: """
            {
              "project": "SwiftUI Code Editor",
              "features": ["editing", "syntax highlight", "multi-language"],
              "enabled": true
            }
            """
        ),
    ]

    @State private var selectedSampleID = "swift"
    @State private var text = ""

    private var selectedSample: CodeSample {
        samples.first(where: { $0.id == selectedSampleID }) ?? samples[0]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Picker("语言", selection: $selectedSampleID) {
                    ForEach(samples) { sample in
                        Text(sample.title).tag(sample.id)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 180)
                .onChange(of: selectedSampleID, initial: true) { _, _ in
                    text = selectedSample.text
                }

                Spacer()

                Text("高亮: \(selectedSample.title)")
                    .foregroundStyle(.secondary)
            }

            CodeEditor(
                source: $text,
                language: selectedSample.language,
                theme: .atelierSavannaLight,
                flags: .defaultEditorFlags
            )
            .font(.system(size: 14, weight: .regular, design: .monospaced))
        }
        .padding(16)
    }
}
