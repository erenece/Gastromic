part of 'register_widget.dart';

mixin RegisterFormWidget {
  static Widget registerForm(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required bool obscurePassword,
    required bool termsAccepted,
    required bool canSubmit,
    required VoidCallback onToggleObscure,
    required VoidCallback onToggleTerms,
    required VoidCallback onSubmit,
    required VoidCallback onGoToLogin,
    required ValueChanged<String> onNameChanged,
    required ValueChanged<String> onEmailChanged,
    required ValueChanged<String> onPasswordChanged,
    required ValueChanged<String> onConfirmPasswordChanged,
  }) {
    return Form(
      key: formKey,
      child: Padding(
        padding: context.horizontalPaddingConstNormal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Gastromic",
              style: context.headlineMedium,
              textAlign: TextAlign.center,
            ),
            context.sizedHeightBoxLow,
            Text(
              "Hesap Oluştur",
              style: context.bodyMedium,
              textAlign: TextAlign.center,
            ),

            context.sizedHeightBoxMedium,
            AuthTextField(
              controller: nameController,
              label: "Ad-Soyad",
              hint: "Adınız Soyadınız",
              icon: Icons.person_rounded,
              onChanged: onNameChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return "Ad ve Soyad boş olamaz";
                if (value.trim().split(' ').length < 2)
                  return 'Ad ve soyadınız giriniz';
                return null;
              },
            ),
            context.sizedHeightBoxNormal,
            AuthTextField(
              controller: emailController,
              label: "Email",
              hint: "example@mail.com",
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              onChanged: onEmailChanged,
              validator: (value) {
                if (value == null || value.isEmpty) return 'E-posta boş olamaz';
                if (!value.isValidEmail)
                  return 'Geçerli bir e-posta adresi giriniz';
                return null;
              },
            ),
            context.sizedHeightBoxNormal,
            AuthTextField(
              controller: passwordController,
              label: "Şifre",
              hint: "*******",
              icon: Icons.lock_outline,
              obscureText: obscurePassword,
              onToggleObscure: onToggleObscure,
              onChanged: onPasswordChanged,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Şifre boş olamaz';
                if (!value.isValidPassword) {
                  return 'Şifre en az 8 karakter, 1 büyük harf ve 1 rakam içermeli';
                }
                return null;
              },
            ),
            context.sizedHeightBoxNormal,
            AuthTextField(
              controller: confirmPasswordController,
              label: "Şifre Tekrar",
              hint: "********",
              icon: Icons.lock_outline,
              obscureText: obscurePassword,
              onChanged: onConfirmPasswordChanged,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Şifre boş olamaz';
                if (value != passwordController.text)
                  return 'Şifreler eşleşmiyor';
                return null;
              },
            ),

            context.sizedHeightBoxNormal,

            Row(
              children: [
                Checkbox(
                  value: termsAccepted,
                  onChanged: (_) => onToggleTerms(),
                ),
                Expanded(
                  child: Text(
                    "Kullanım koşullarını ve Gizlilik Politikasını okudum, kabul ediyorum.",
                    style: context.bodyMedium,
                  ),
                ),
              ],
            ),
            context.sizedHeightBoxNormal,
            PrimaryButton(label: "Kayıt Ol", onPressed: onSubmit),
            context.sizedHeightBoxNormal,
            AuthSwitchWidget(
              questionText: "Zaten hesabınız var mı? ",
              linkLabel: 'Giriş Yap',
              onLinkPressed: onGoToLogin,
            ),
          ],
        ),
      ),
    );
  }
}
