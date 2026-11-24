# TELEGRAM X — стартовый проект

Это исходный код кроссплатформенного Flutter-приложения для Windows и Android.
В проекте уже есть экран настройки, регистрация/вход по email, список пользователей,
создание личного диалога и отправка/получение текстовых сообщений через Supabase.

## Важно
Это стартовая рабочая основа, а не готовая копия Telegram. Для работы через интернет
нужен собственный проект Supabase. Не публикуйте `service_role` key и не вставляйте его
в приложение. Используйте только Project URL и anon/public key.

## 1. Установить инструменты (Windows 10)
1. Установите Flutter SDK: https://docs.flutter.dev/get-started/install/windows/desktop
2. Установите Android Studio: https://developer.android.com/studio
3. Установите Visual Studio Community и компонент **Desktop development with C++**:
   https://visualstudio.microsoft.com/downloads/
4. Установите VS Code: https://code.visualstudio.com/
5. В VS Code откройте Extensions и установите расширения Flutter и Dart.

## 2. Подключить backend
1. Создайте проект на https://supabase.com/ (бесплатный тариф имеет ограничения).
2. В Supabase откройте SQL Editor.
3. Откройте файл `supabase/schema.sql`, скопируйте его содержимое и выполните в SQL Editor.
4. В Project Settings → API скопируйте Project URL и anon/public key.
5. В Supabase → Authentication → Providers убедитесь, что Email включён.
6. В Supabase → Database → Replication/ публикации включите Realtime для таблицы `messages`.

## 3. Запуск в VS Code
1. Распакуйте ZIP в папку, например `C:\TELEGRAM_X`.
2. Откройте эту папку в VS Code.
3. Откройте Terminal → New Terminal.
4. Выполните:
   flutter pub get
5. Для запуска Windows:
   flutter run -d windows --dart-define=SUPABASE_URL=ВАШ_URL --dart-define=SUPABASE_ANON_KEY=ВАШ_PUBLIC_KEY
6. Для Android подключите телефон с включённой USB debugging или запустите эмулятор:
   flutter devices
   flutter run -d УСТРОЙСТВО --dart-define=SUPABASE_URL=ВАШ_URL --dart-define=SUPABASE_ANON_KEY=ВАШ_PUBLIC_KEY

## 4. Сборка
Windows:
   flutter build windows --dart-define=SUPABASE_URL=ВАШ_URL --dart-define=SUPABASE_ANON_KEY=ВАШ_PUBLIC_KEY

Android APK:
   flutter build apk --release --dart-define=SUPABASE_URL=ВАШ_URL --dart-define=SUPABASE_ANON_KEY=ВАШ_PUBLIC_KEY

## Уже реализовано в основе
- Тёмная тема и бренд TELEGRAM X
- Регистрация и вход по email
- Список пользователей
- Личные текстовые чаты
- Обновление сообщений в реальном времени (после включения Realtime)

## Следующие этапы разработки
- Настройка профиля и уникального username
- Поиск и добавление контактов
- Группы и каналы
- Отправка изображений и файлов через Storage
- Push-уведомления
- Голосовые и видеозвонки
- Дополнительное усиление безопасности, блокировки и жалобы

## Примечание о безопасности
Этот проект — учебная стартовая реализация. Перед реальным публичным запуском нужно провести
проверку RLS-политик, защиту от спама, лимиты запросов, обработку жалоб и аудит безопасности.

## Автоматическая сборка Windows через GitHub
1. Создайте на GitHub пустой репозиторий.
2. Загрузите в него всё содержимое этой папки, включая скрытую папку `.github`.
3. Откройте вкладку Actions и запустите workflow `Build TELEGRAM X for Windows` (или дождитесь запуска после push).
4. После успешной сборки откройте завершённый запуск workflow и скачайте Artifact `TELEGRAM-X-Windows`.
5. Распакуйте ZIP и запускайте `telegram_x.exe` из папки `Release`.

Для публикации одного установочного EXE позже добавим упаковщик (например, Inno Setup).
Для работы регистрации и чатов нужно сначала подключить Supabase; без ключей приложение покажет экран настройки.
