import SwiftUI

/// Clean, institutional-grade login screen for LiquidityOS.
/// Features Gmail authentication with hardcoded credentials and one-tap demo login.
struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("loggedInUserEmail") private var loggedInUserEmail: String = "user@gmail.com"
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    
    // HARDCODED CREDENTIALS
    static let demoEmail = "user@gmail.com"
    static let demoPassword = "password123"
    static let adminEmail = "admin@gmail.com"
    static let adminPassword = "admin123"
    
    var body: some View {
        NavigationStack {
            ZStack {
                LOSTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 20)
                        
                        // MARK: - App Branding
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(LOSTheme.primary.gradient)
                                    .frame(width: 72, height: 72)
                                    .shadow(color: LOSTheme.primary.opacity(0.35), radius: 10, y: 5)
                                
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 34, weight: .semibold))
                                    .foregroundStyle(Color.white)
                            }
                            
                            VStack(spacing: 4) {
                                Text("LiquidityOS")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.primary)
                                
                                Text("Financial Resilience Operating System")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        .padding(.top, 10)
                        
                        // MARK: - Login Card
                        VStack(spacing: 18) {
                            // Error Callout
                            if let error = errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundStyle(LOSTheme.criticalRed)
                                        .font(.system(size: 13))
                                    Text(error)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(LOSTheme.criticalRed)
                                    Spacer()
                                }
                                .padding(10)
                                .background(LOSTheme.criticalRed.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            // Gmail Input Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("GMAIL ADDRESS")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.6)
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(LOSTheme.primary)
                                        .frame(width: 20)
                                    
                                    TextField("user@gmail.com", text: $email)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .keyboardType(.emailAddress)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    if !email.isEmpty {
                                        Button {
                                            email = ""
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.secondary)
                                        }
                                    }
                                }
                                .padding(12)
                                .background(LOSTheme.background)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(LOSTheme.cardBorder, lineWidth: 1)
                                )
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("PASSWORD")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.6)
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(LOSTheme.primary)
                                        .frame(width: 20)
                                    
                                    if isPasswordVisible {
                                        TextField("Enter password", text: $password)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                            .font(.system(size: 14, weight: .medium))
                                    } else {
                                        SecureField("Enter password", text: $password)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    
                                    Button {
                                        isPasswordVisible.toggle()
                                    } label: {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.secondary)
                                    }
                                }
                                .padding(12)
                                .background(LOSTheme.background)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(LOSTheme.cardBorder, lineWidth: 1)
                                )
                            }
                            
                            // Sign In Button
                            Button(action: handleSignIn) {
                                HStack(spacing: 8) {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.black)
                                            .scaleEffect(0.85)
                                    } else {
                                        Text("Sign In")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(LOSTheme.primary)
                                .foregroundStyle(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: LOSTheme.primary.opacity(0.3), radius: 6, y: 3)
                            }
                            .disabled(isLoading)
                            
                            // Divider
                            HStack {
                                Rectangle().fill(LOSTheme.cardBorder).frame(height: 1)
                                Text("OR")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.secondary)
                                Rectangle().fill(LOSTheme.cardBorder).frame(height: 1)
                            }
                            .padding(.vertical, 4)
                            
                            // Continue with Google Button
                            Button(action: continueWithGoogle) {
                                HStack(spacing: 10) {
                                    Image(systemName: "g.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(LOSTheme.primary)
                                    
                                    Text("Continue with Google")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(LOSTheme.background)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(LOSTheme.cardBorder, lineWidth: 1)
                                )
                            }
                        }
                        .padding(20)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(LOSTheme.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        // MARK: - Hardcoded Credentials Helper Card
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(LOSTheme.primary)
                                Text("DEMO CREDENTIALS")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.6)
                                Spacer()
                                
                                Button("Autofill") {
                                    autofillDemo()
                                }
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(LOSTheme.primary)
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Gmail: \(Self.demoEmail)")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    Text("Password: \(Self.demoPassword)")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                }
                                .foregroundStyle(Color.secondary)
                                Spacer()
                            }
                        }
                        .padding(14)
                        .background(LOSTheme.cardBackground.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(LOSTheme.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                    }
                }
            }
        }
        .onAppear {
            if email.isEmpty {
                email = Self.demoEmail
                password = Self.demoPassword
            }
        }
    }
    
    // MARK: - Authentication Logic
    private func handleSignIn() {
        errorMessage = nil
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty else {
            errorMessage = "Please enter your Gmail address."
            return
        }
        
        guard !cleanPassword.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isLoading = false
            
            let isUserValid = (cleanEmail == Self.demoEmail && cleanPassword == Self.demoPassword)
            let isAdminValid = (cleanEmail == Self.adminEmail && cleanPassword == Self.adminPassword)
            
            if isUserValid || isAdminValid {
                loggedInUserEmail = cleanEmail
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isLoggedIn = true
                }
            } else {
                errorMessage = "Invalid credentials. Use user@gmail.com / password123"
            }
        }
    }
    
    private func continueWithGoogle() {
        autofillDemo()
        handleSignIn()
    }
    
    private func autofillDemo() {
        email = Self.demoEmail
        password = Self.demoPassword
        errorMessage = nil
    }
}
