import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @State private var showLogoutAlert = false

    var body: some View {
        VStack(spacing: 20) {
            header

            if viewModel.isLoading {
                ProgressView()
                    .tint(Color.accentColor)
            } else if let profile = viewModel.profile {
                VStack(spacing: 12) {
                    profileRow(title: "Фамилия", value: profile.lastName ?? "—")
                    profileRow(title: "Имя", value: profile.firstName ?? "—")
                    profileRow(title: "Отчество", value: profile.middleName ?? "—")
                    profileRow(title: "Email", value: profile.email)
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Button {
                Task {
                    await viewModel.loadProfile()
                }
            } label: {
                Text("Обновить")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .foregroundStyle(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(viewModel.isLoading)

            Button {
                showLogoutAlert = true
            } label: {
                Text("Выйти")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .padding(24)
        .background(Color(.systemBackground))
        .task {
            await viewModel.loadProfile()
        }
        .alert("Выйти из аккаунта?", isPresented: $showLogoutAlert) {
            Button("Выйти", role: .destructive) {
                Task {
                    await viewModel.logout()
                }
            }

            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Вы сможете войти снова в любое время.")
        }
    }

    private var header: some View {
        HStack {
            Color.clear
                .frame(width: 44, height: 44)

            Spacer()

            Text("Профиль")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.accentColor)

            Spacer()

            Button {
                viewModel.openEditProfile()
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.12))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isLoading || viewModel.profile == nil)
        }
    }

    private func profileRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 10)

            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
