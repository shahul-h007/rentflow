@echo off
echo Building RentFlow Member App APK...
flutter build apk --release --dart-define=SUPABASE_URL=https://sbgpttvssbwpbfyeicmk.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_NNHOsiiVYu43-wbBVqULBg_8gcXMwgL --dart-define=API_BASE_URL=https://rentflow-sooty.vercel.app
echo.
echo Build complete! Your APK should be located in build\app\outputs\flutter-apk\app-release.apk
pause
