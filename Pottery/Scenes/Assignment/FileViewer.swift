import SwiftUI
import AVKit

struct FileViewer: View {

    let file: AssignmentFile
    private var fileURL: URL? { URL(string: file.url) }

    var body: some View {
        Group {
            if let fileURL {
                if file.mimeType.contains("image") {
                    AsyncImage(url: fileURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .padding()
                } else if file.mimeType.contains("video") {
                    VideoPlayer(
                        player: AVPlayer(url: fileURL)
                    )
                    .ignoresSafeArea()
                } else {
                    VStack {
                        Image(systemName: "doc")
                            .font(.largeTitle)

                        Text(file.fileName)

                        Link("Открыть файл", destination: fileURL)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                    Text("Некорректная ссылка на файл")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
    }
}
