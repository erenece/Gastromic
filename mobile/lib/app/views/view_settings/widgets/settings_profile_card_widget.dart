part of 'settings_widgets.dart';

mixin SettingsProfileCardWidget {
  static Widget profileCard(
    BuildContext context, {
    required SettingsProfileModel profile,
    required VoidCallback onEditTap,
  }) {
      return Container(
      padding: context.paddingNormal,
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: context.normalBorderRadius,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(profile.photoUrl),
          ),
          context.sizedHeightBoxNormal,
          Text(profile.name, style: context.titleLarge),
          Text(profile.bio, style: context.bodyMedium),
          context.sizedHeightBoxNormal,
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SettingsStatItemWidget.statItem(
                context,
                value: '${profile.visitCount}',
                label: 'Ziyaret Sayısı',
              ),
              SettingsStatItemWidget.statItem(
                context,
                value: '${profile.membershipYears} Yıl',
                label: 'Üyelik Süresi',
              ),
            ],
          ),
          context.sizedHeightBoxNormal,
          PrimaryButton(label: 'Profili Düzenle', onPressed: onEditTap),
        ],
      ),
    );
  }
}

    
