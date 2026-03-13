import SwiftUI

struct EditProfileView: View {
    @StateObject var viewModel: EditProfileViewModel
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Редактирование профиля")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)

                VStack(spacing: 12) {
                    inputField(title: "Фамилия", placeholder: "Введите фамилию", text: $viewModel.lastName)

                    inputField(title: "Имя", placeholder: "Введите имя", text: $viewModel.firstName)

                    inputField(title: "Отчество", placeholder: "Введите отчество", text: $viewModel.middleName)

                    inputField(
                        title: "Email",
                        placeholder: "Введите email",
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                Button {
                    Task {
                        await viewModel.save()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Сохранить")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(viewModel.isLoading)

                Button {
                    showDeleteAlert = true
                } label: {
                    Text("Удалить аккаунт")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .foregroundStyle(.red)
                .disabled(viewModel.isLoading)
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
        .alert("Удалить аккаунт?", isPresented: $showDeleteAlert) {
            Button("Удалить", role: .destructive) {
                Task {
                    await viewModel.deleteAccount()
                }
            }

            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Аккаунт будет удалён без возможности восстановления.")
        }
    }

    private func inputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization? = .sentences
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 10)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
