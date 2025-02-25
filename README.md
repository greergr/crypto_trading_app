# Crypto Trading App

تطبيق تداول العملات المشفرة مع روبوتات تداول ذكية.

## المميزات

- واجهة مستخدم حديثة وسهلة الاستخدام
- دعم اللغة العربية والإنجليزية
- تحليلات السوق المتقدمة
- روبوتات تداول متعددة الاستراتيجيات
- تقارير أداء مفصلة
- وضع التداول التجريبي

## متطلبات التشغيل

- Flutter SDK (3.16.0 أو أحدث)
- Dart SDK (3.0.0 أو أحدث)
- مفاتيح API من Binance

## التثبيت

1. استنسخ المستودع:
   ```bash
   git clone https://github.com/greergr/crypto_trading_app.git
   cd crypto_trading_app
   ```

2. قم بتثبيت التبعيات:
   ```bash
   flutter pub get
   ```

3. قم بإنشاء ملف `.env` في المجلد الرئيسي:
   ```
   BINANCE_API_KEY=your_api_key
   BINANCE_API_SECRET=your_api_secret
   ```

## التشغيل

### تشغيل محلي
```bash
flutter run -d chrome
```

### بناء للنشر
```bash
flutter build web --release --base-href /crypto_trading_app/
```

## النشر

### GitHub Pages

1. قم بتمكين GitHub Pages في إعدادات المستودع
2. اختر فرع `gh-pages` كمصدر
3. سيتم النشر تلقائياً عند الدفع إلى فرع `main`

### Vercel

1. قم بربط المستودع مع Vercel
2. اضبط إعدادات المشروع:
   - Framework Preset: `Other`
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`
   - Install Command: `flutter pub get`

## المساهمة

نرحب بمساهماتكم! يرجى اتباع هذه الخطوات:

1. Fork المستودع
2. إنشاء فرع للميزة: `git checkout -b feature/amazing-feature`
3. Commit التغييرات: `git commit -m 'Add amazing feature'`
4. Push إلى الفرع: `git push origin feature/amazing-feature`
5. فتح Pull Request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT - انظر ملف [LICENSE](LICENSE) للتفاصيل.
