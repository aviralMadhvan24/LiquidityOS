import SwiftUI

/// Production-grade authentication screen for LiquidityOS.
/// Connects to the backend user database with local cryptographic fallback,
/// supports both Sign In and Account Registration, and enforces strict credential validation.
struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("loggedInUserEmail") private var loggedInUserEmail: String = "user@gmail.com"
    @AppStorage("loggedInUserName") private var loggedInUserName: String = "Demo Investor"
    
    enum AuthMode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case register = "Create Account"
        
        var id: String { rawValue }
    }
    
    @State private var authMode: AuthMode = .signIn
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    
    @State private var errorMessage: String? = nil
    @State private var successNotice: String? = nil
    @State private var isLoading: Bool = false
    @State private var isServerOnline: Bool = false
    
    // Quick Demo Credentials for evaluation
    static let demoEmail = "user@gmail.com"
    static let demoPassword = "password123"
    static let adminEmail = "admin@gmail.com"
    static let adminPassword = "admin123"
    
    // Email Validation
    private var isEmailValid: Bool {
        let clean = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$")
        return emailPredicate.evaluate(with: clean)
    }
    
    private var isPasswordValid: Bool {
        password.count >= 6
    }
    
    private var doPasswordsMatch: Bool {
        password == confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LOSTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 12)
                        
                        // MARK: - App Branding
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(LOSTheme.primary.gradient)
                                    .frame(width: 68, height: 68)
                                    .shadow(color: LOSTheme.primary.opacity(0.35), radius: 10, y: 5)
                                
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundStyle(Color.white)
                            }
                            
                            VStack(spacing: 3) {
                                Text("LiquidityOS")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.primary)
                                
                                Text("Financial Resilience Operating System")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            // Database Connectivity Indicator Badge
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(isServerOnline ? LOSTheme.safeGreen : Color.secondary)
                                    .frame(width: 7, height: 7)
                                Text(isServerOnline ? "Connected to Auth Database" : "Local Database Active")
                                    .font(.caption2.bold())
                                    .foregroundStyle(isServerOnline ? LOSTheme.safeGreen : Color.secondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(isServerOnline ? LOSTheme.safeGreen.opacity(0.12) : Color.primary.opacity(0.05))
                            .clipShape(Capsule())
                        }
                        .padding(.top, 6)
                        
                        // MARK: - Auth Card Container
                        VStack(spacing: 16) {
                            // Mode Switcher: Sign In vs Create Account
                            Picker("Authentication Mode", selection: $authMode) {
                                ForEach(AuthMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: authMode) { _, _ in
                                errorMessage = nil
                                successNotice = nil
                            }
                            
                            // Error Callout
                            if let error = errorMessage {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(LOSTheme.criticalRed)
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.top, 1)
                                    Text(error)
                                        .font(.caption.bold())
                                        .foregroundStyle(LOSTheme.criticalRed)
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                                .padding(10)
                                .background(LOSTheme.criticalRed.opacity(0.12))
                                .clipShape(.rect(cornerRadius: LOSTheme.radiusSmall))
                            }
                            
                            // Success Callout
                            if let notice = successNotice {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(LOSTheme.safeGreen)
                                        .font(.system(size: 13))
                                    Text(notice)
                                        .font(.caption.bold())
                                        .foregroundStyle(LOSTheme.safeGreen)
                                    Spacer()
                                }
                                .padding(10)
                                .background(LOSTheme.safeGreen.opacity(0.12))
                                .clipShape(.rect(cornerRadius: LOSTheme.radiusSmall))
                            }
                            
                            // Full Name (Only for Registration)
                            if authMode == .register {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("FULL NAME")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.secondary)
                                        .tracking(0.6)
                                    
                                    HStack(spacing: 10) {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(LOSTheme.primary)
                                            .frame(width: 20)
                                        
                                        TextField("e.g. Rohit Sharma", text: $name)
                                            .textInputAutocapitalization(.words)
                                            .autocorrectionDisabled()
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .padding(12)
                                    .background(LOSTheme.background)
                                    .clipShape(.rect(cornerRadius: LOSTheme.radiusSmall))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: LOSTheme.radiusSmall)
                                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                                    )
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            // Email Address Field
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("EMAIL ADDRESS")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.secondary)
                                        .tracking(0.6)
                                    Spacer()
                                    if !email.isEmpty {
                                        if isEmailValid {
                                            Label("Valid format", systemImage: "checkmark.circle.fill")
                                                .labelStyle(.iconOnly)
                                                .font(.system(size: 11))
                                                .foregroundStyle(LOSTheme.safeGreen)
                                        } else {
                                            Text("Invalid format")
                                                .font(.caption2)
                                                .foregroundStyle(LOSTheme.criticalRed)
                                        }
                                    }
                                }
                                
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
                                            Label("Clear email", systemImage: "xmark.circle.fill")
                                        }
                                        .labelStyle(.iconOnly)
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.secondary)
                                    }
                                }
                                .padding(12)
                                .background(LOSTheme.background)
                                .clipShape(.rect(cornerRadius: LOSTheme.radiusSmall))
                                .overlay(
                                    RoundedRectangle(cornerRadius: LOSTheme.radiusSmall)
                                        .stroke(LOSTheme.cardBorder, lineWidth: 1)
                                )
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("PASSWORD")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.secondary)
                                        .tracking(0.6)
                                    Spacer()
                                    if !password.isEmpty && authMode == .register {
                                        Text(isPasswordValid ? "Min length met" : "Min 6 chars")
                                            .font(.caption2)
                                            .foregroundStyle(isPasswordValid ? LOSTheme.safeGreen : LOSTheme.warningAmber)
                                    }
                                }
                                
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
                                        Label(isPasswordVisible ? "Hide password" : "Show password", systemImage: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    }
                                    .labelStyle(.iconOnly)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.secondary)
                                }
                                .padding(12)
                                .background(LOSTheme.background)
                                .clipShape(.rect(cornerRadius: LOSTheme.radiusSmall))
                                .overlay(
                                    RoundedRectangle(cornerRadius: LOSTheme.radiusSmall)
                                        .stroke(LOSTheme.cardBorder, lineWidth: 1)
                                )
                            }
                            
                            // Confirm Password (Only for Registration)
                            if authMode == .register {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("CONFIRM PASSWORD")
                                            .font(.system(size: 10, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.secondary)
                                            .tracking(0.6)
                                        Spacer()
                                        if !confirmPassword.isEmpty {
                                            Text(doPasswordsMatch ? "Passwords match" : "Does not match")
                                                .font(.caption2)
                                                .foregroundStyle(doPasswordsMatch ? LOSTheme.safeGreen : LOSTheme.criticalRed)
                                        }
                                    }
                                    
                                    HStack(spacing: 10) {
                                        Image(systemName: "lock.shield.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(LOSTheme.primary)
                                            .frame(width: 20)
                                        
                                        if isConfirmPasswordVisible {
                                            TextField("Re-enter password", text: $confirmPassword)
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled()
                                                .font(.system(size: 14, weight: .medium))
                                        } else {
                                            SecureField("Re-enter password", text: $confirmPassword)
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled()
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        
                                        Button {
                                            isConfirmPasswordVisible.toggle()
                                        } label: {
                                            Label(isConfirmPasswordVisible ? "Hide password" : "Show password", systemImage: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        }
                                        .labelStyle(.iconOnly)
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.secondary)
                                    }
                                    .padding(12)
                                    .background(LOSTheme.background)
                                    .clipShape(.rect(cornerRadius: LOSTheme.radiusSmall))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: LOSTheme.radiusSmall)
                                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                                    )
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            // Primary Submit Action Button
                            Button(action: handleAuthAction) {
                                HStack(spacing: 8) {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(0.85)
                                    } else {
                                        Text(authMode == .signIn ? "Sign In" : "Register Account")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                        Image(systemName: authMode == .signIn ? "arrow.right" : "person.badge.plus")
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(LOSTheme.primary)
                                .foregroundStyle(Color.white)
                                .clipShape(.rect(cornerRadius: LOSTheme.radiusSmall))
                                .shadow(color: LOSTheme.primary.opacity(0.35), radius: 6, y: 3)
                            }
                            .disabled(isLoading)
                            
                            // Mode Switcher Footer Text
                            HStack(spacing: 4) {
                                Text(authMode == .signIn ? "Don't have an account?" : "Already have an account?")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                
                                Button(authMode == .signIn ? "Sign Up" : "Sign In") {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        authMode = (authMode == .signIn) ? .register : .signIn
                                    }
                                }
                                .font(.caption.bold())
                                .foregroundStyle(LOSTheme.primary)
                            }
                            .padding(.top, 2)
                        }
                        .padding(20)
                        .background(LOSTheme.cardBackground)
                        .clipShape(.rect(cornerRadius: LOSTheme.radiusLarge))
                        .overlay(
                            RoundedRectangle(cornerRadius: LOSTheme.radiusLarge)
                                .stroke(LOSTheme.cardBorder, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 12, y: 4)
                        .padding(.horizontal)
                        
                        // MARK: - Credentials Helper & Quick Fill
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(LOSTheme.primary)
                                Text("DATABASE DEMO ACCOUNTS")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.6)
                                Spacer()
                            }
                            
                            VStack(spacing: 8) {
                                Button {
                                    fillDemoCredentials(email: Self.demoEmail, password: Self.demoPassword)
                                } label: {
                                    HStack {
                                        Text("Investor")
                                            .font(.caption.bold())
                                            .foregroundStyle(Color.primary)
                                        Spacer()
                                        Text("user@gmail.com")
                                            .font(.caption.monospaced())
                                            .foregroundStyle(Color.secondary)
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(LOSTheme.primary.opacity(0.8))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(LOSTheme.background)
                                    .clipShape(.rect(cornerRadius: LOSTheme.radiusSmall))
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    fillDemoCredentials(email: Self.adminEmail, password: Self.adminPassword)
                                } label: {
                                    HStack {
                                        Text("Admin")
                                            .font(.caption.bold())
                                            .foregroundStyle(Color.primary)
                                        Spacer()
                                        Text("admin@gmail.com")
                                            .font(.caption.monospaced())
                                            .foregroundStyle(Color.secondary)
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(LOSTheme.primary.opacity(0.8))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(LOSTheme.background)
                                    .clipShape(.rect(cornerRadius: LOSTheme.radiusSmall))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(14)
                        .background(LOSTheme.cardBackground.opacity(0.8))
                        .clipShape(.rect(cornerRadius: LOSTheme.radiusMedium))
                        .overlay(
                            RoundedRectangle(cornerRadius: LOSTheme.radiusMedium)
                                .stroke(LOSTheme.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .sensoryFeedback(.success, trigger: isLoggedIn)
        .task {
            isServerOnline = await AuthAPIService.shared.checkServerHealth()
            if email.isEmpty {
                email = Self.demoEmail
                password = Self.demoPassword
            }
        }
    }
    
    // MARK: - Validation & Authentication Logic
    
    private func handleAuthAction() {
        errorMessage = nil
        successNotice = nil
        
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Email Format Validation
        guard !cleanEmail.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        guard isEmailValid else {
            errorMessage = "Please enter a valid email address (e.g. user@gmail.com)."
            return
        }
        
        // 2. Password Length Validation
        guard !cleanPassword.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }
        guard isPasswordValid else {
            errorMessage = "Password must be at least 6 characters long."
            return
        }
        
        // 3. Confirm Password Validation (Register mode)
        if authMode == .register {
            guard doPasswordsMatch else {
                errorMessage = "Passwords do not match. Please re-enter to confirm."
                return
            }
        }
        
        isLoading = true
        
        Task {
            do {
                if authMode == .signIn {
                    let result = try await AuthAPIService.shared.login(email: cleanEmail, password: cleanPassword)
                    await MainActor.run {
                        isLoading = false
                        loggedInUserEmail = result.user.email
                        loggedInUserName = result.user.name
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isLoggedIn = true
                        }
                    }
                } else {
                    let result = try await AuthAPIService.shared.register(
                        name: name.isEmpty ? "Investor" : name,
                        email: cleanEmail,
                        password: cleanPassword
                    )
                    await MainActor.run {
                        isLoading = false
                        loggedInUserEmail = result.user.email
                        loggedInUserName = result.user.name
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isLoggedIn = true
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fillDemoCredentials(email: String, password: String) {
        self.authMode = .signIn
        self.email = email
        self.password = password
        self.errorMessage = nil
        self.successNotice = "Demo credentials autofilled."
    }
}
