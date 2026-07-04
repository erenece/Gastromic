part of 'login_widgets.dart';

mixin LoginFormWidget {
  static Widget loginForm(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required bool obscurePassword,
    required VoidCallback onToggleObscure,
    required VoidCallback onSubmit,
    required VoidCallback onForgotPassword,
    required VoidCallback onGoToRegister,
    required ValueChanged<String> onEmailChanged,
    required ValueChanged<String> onPasswordChanged,
  }) {
    return Form(
      key: formKey,
      child: Padding(
        padding: context.horizontalPaddingConstNormal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Giriş Yap',
              style: context.headlineMedium,
              textAlign: TextAlign.center,
            ),

            context.sizedHeightBoxLow,
            Text(
              'Tekrar hoş geldin, seni görmek güzel.',
              style: context.bodyMedium,
              textAlign: TextAlign.center,
            ),
            context.sizedHeightBoxMedium,
            AuthTextField(
              controller: emailController,
              label: 'E-posta veya Telefon',
              hint: 'E-posta veya telefon numaranız',
              icon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              onChanged: onEmailChanged,
              validator: (value) {
                if (value == null || value.isEmpty) return 'E-posta boş olamaz';
                if (!value.isValidEmail) return 'Geçerli bir e-posta giriniz';
                return null;
              },
            ),
            context.sizedHeightBoxNormal,
            AuthTextField(
              controller: passwordController,
              label: 'Şifre',
              hint: 'Şifreniz',
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgotPassword,
                child: Text('Şifremi Unuttum', style: context.bodyMedium),
              ),
            ),
            context.sizedHeightBoxNormal,
            PrimaryButton(label: 'Giriş Yap', onPressed: onSubmit),
            context.sizedHeightBoxNormal,
            AuthSwitchWidget(
              questionText: 'Hesabın yok mu? ',
              linkLabel: 'Kayıt Ol',
              onLinkPressed: onGoToRegister,
            ),
          ],
        ),
      ),
    );
  }
}
