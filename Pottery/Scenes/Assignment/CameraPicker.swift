import SwiftUI

struct CameraPicker: UIViewControllerRepresentable {

    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {

            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }
    }
}
