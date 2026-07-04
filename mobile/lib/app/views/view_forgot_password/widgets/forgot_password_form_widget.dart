part of 'forgot_password_widgets.dart';

mixin ForgotPasswordFormWidget {
  static Widget forgotPasswordForm(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required bool isLoading,
    required bool isEmailSent,
    required VoidCallback onSubmit,
    required VoidCallback onSupport,
    required ValueChanged<String> onEmailChanged,
  }) {
    return Form(
      key: formKey,
      child: Padding(
        padding: context.horizontalPaddingConstNormal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gastromic',
              style: context.headlineMedium,
              textAlign: TextAlign.center,
            ),
            context.sizedHeightBoxMedium,
            Text(
              'Şifrenizi mi unuttunuz?',
              style: context.titleLarge,
              textAlign: TextAlign.center,
            ),
            context.sizedHeightBoxLow,
            Text(
              'Hesabınıza kayıtlı e-posta adresinizi girin. Size şifrenizi sıfırlamanız için bir bağlantı göndereceğiz.',
              style: context.bodyMedium,
              textAlign: TextAlign.center,
            ),
            context.sizedHeightBoxMedium,
            if (isEmailSent)
              Text(
                'Sıfırlama bağlantısı e-postanıza gönderildi.',
                style: context.bodyMedium.copyWith(color: context.cPrimary),
                textAlign: TextAlign.center,
              )
            else ...[
              AuthTextField(
                controller: emailController,
                label: 'E-posta Adresi',
                hint: 'ornek@eposta.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                onChanged: onEmailChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta boş olamaz';
                  }
                  if (!value.isValidEmail) return 'Geçerli bir e-posta giriniz';
                  return null;
                },
              ),
              context.sizedHeightBoxNormal,
              PrimaryButton(
                label: isLoading
                    ? 'Gönderiliyor...'
                    : 'Sıfırlama Bağlantısı Gönder',
                onPressed: isLoading ? () {} : onSubmit,
              ),
            ],
            context.sizedHeightBoxMedium,
            Center(
              child: GestureDetector(
                onTap: onSupport,
                child: Text.rich(
                  TextSpan(
                    text: 'Yardıma mı ihtiyacınız var? ',
                    style: context.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Destek Merkezi',
                        style: context.labelLarge.copyWith(
                          color: context.cPrimary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
