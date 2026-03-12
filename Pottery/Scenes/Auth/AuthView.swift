import SwiftUI

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Вход")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 12) {
                inputField(
                    title: "Email",
                    placeholder: "Введите email",
                    text: $viewModel.email,
                    keyboardType: .emailAddress,
                    autocapitalization: .never
                )

                secureInputField(
                    title: "Пароль",
                    placeholder: "Введите пароль",
                    text: $viewModel.password
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
                    await viewModel.login()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Войти")
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
                viewModel.openRegistration()
            } label: {
                Text("Зарегистрироваться")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.accentColor)
            }
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .padding(24)
        .background(Color(.systemBackground))
        .dismissKeyboardOnTap()
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

    private func secureInputField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 10)

            SecureField(placeholder, text: text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
