# Music Beat Marketplace 🎵

یک پلتفرم کامل فروش بیت موسیقی برای بازار ایران

## ویژگی‌ها

### برای خریداران 🛍️
- مرور و جستجوی بیت‌ها
- پخش پیش‌نمایش آنلاین
- خرید با انتخاب لایسنس (MP3/WAV/Stems)

### برای پرودیوسرها 🎹
- آپلود بیت با قیمت‌گذاری
- داشبورد فروش و درآمد
- مشاهده بیت‌های خودی
- اطلاعات خریداران

## دمو آنلاین
[مشاهده دمو](https://godeeye2004.github.io/music-sale/)

## تکنولوژی‌ها
- **Framework**: Flutter
- **Database**: Hive (Local NoSQL)
- **Audio**: just_audio
- **Authentication**: Local with SHA-256
- **State Management**: Provider ready

## نصب و اجرا

```bash
# نصب dependencies
flutter pub get

# اجرا روی Web
flutter run -d chrome

# اجرا روی iOS
flutter run -d ios

# اجرا روی Android
flutter run -d android

# اجرا روی macOS
flutter run -d macos
```

## ساختار پروژه
```
lib/
├── config/         # تنظیمات و تم
├── models/         # مدل‌های داده (Hive)
├── services/       # سرویس‌ها (DB, Auth, Storage, Payment)
├── screens/        # صفحات UI
└── widgets/        # کامپوننت‌های قابل استفاده مجدد
```

## Build برای Production

```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## مجوز
MIT License - برای استفاده شخصی و تجاری آزاد

---
ساخته شده با ❤️ برای جامعه موسیقی ایران
