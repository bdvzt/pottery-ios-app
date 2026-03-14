import SwiftUI
import AVKit

struct FileViewer: View {

    let file: AssignmentFile

    var body: some View {

        if file.mimeType.contains("image") {

            AsyncImage(url: URL(string: file.url)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .padding()

        } else if file.mimeType.contains("video") {

            VideoPlayer(
                player: AVPlayer(url: URL(string: file.url)!)
            )
            .ignoresSafeArea()

        } else {

            VStack {
                Image(systemName: "doc")
                    .font(.largeTitle)

                Text(file.fileName)

                Link("Открыть файл", destination: URL(string: file.url)!)
            }
        }
    }
}
