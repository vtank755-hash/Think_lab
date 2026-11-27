# Dynamic Application Migration Checklist

## Audit status

- [x] Inventory the Flutter source tree: 47 Dart files under `lib/` and 24 Dart files under `test/`.
- [x] Trace the app entry point and imperative navigation.
- [x] Check dependencies and platform configuration for a backend.
- [x] Connect the supplied Android Firebase app config to the Android Gradle build and startup.
- [x] Confirm Android-only is the current Firebase target and Firestore is enabled.
- [x] Connect email/password sign-in, registration, password reset, and admin-role lookup to Firebase Auth/Firestore.
- [x] Add baseline Firestore rules and Firebase CLI project/rules configuration.
- [x] Identify the main in-memory, hardcoded, and demo data stores.
- [ ] Migrate and verify the pages below.

The supplied `android/app/google-services.json` matches the Android
`applicationId`, and Android Firebase startup is wired. The repository has
Android, iOS, and web platform folders, but only Android has Firebase native
configuration; no FlutterFire options, iOS plist, or web app configuration is
present. FlutterFire CLI is not installed. Firestore and Email/Password
Authentication were reported enabled, but the Firebase Console could not be
opened because Google 2-Step Verification could not be completed. Sign-in,
registration, password reset, session restoration, Firestore profile creation,
admin-role checks, category CRUD, and profile name/phone/bio updates are wired
but not verified against the live project. Firestore and Storage rules are
prepared but are not deployed or emulator-verified. Storage is unconfirmed and
no upload is integrated. The app
still uses local assets, hardcoded seed data, `ValueNotifier` state, and
`SharedPreferences` for the quiz catalog. Widget tests use fake services and
do not prove Firebase project connectivity, rules, or cross-device
synchronization.

## Page-by-page checklist

`[ ]` means backend migration and end-to-end verification are not complete.
Auth code is wired, but production integration is not complete until the
Firestore rules are deployed, an initial admin is bootstrapped, and Auth flows
are verified against the Firebase project or emulators.

### App entry, authentication, and user panel

- [ ] **Splash** — `lib/pages/splash_screen.dart`: restores a Firebase session
  and routes by admin document; verify with project/emulator.
- [ ] **User login** — `lib/login_user.dart`: Firebase email/password sign-in
  and password reset are wired; verify with project/emulator.
- [ ] **Registration** — `lib/register_user.dart`: Firebase Auth account and
  Firestore profile creation are wired; verify with project/emulator.
- [ ] **Admin login** — `lib/admin_login.dart`: Firebase Auth plus
  `admins/{uid}` role lookup are wired; bootstrap the first admin document in
  Firebase Console and verify rules before use.
- [ ] **Home and bottom-navigation shell** — `lib/index.dart`: home content,
  tabs, banner, categories, popular/recommended courses, and continue-learning
  card use local/static data. The fallback tab content is only a label.
- [ ] **Search** — `lib/searches.dart`: searches the local course catalog.
- [ ] **Categories** — `lib/categories.dart`: cards now stream public,
  active categories from Firestore; category counts and course listings still
  use the local course catalog. Deploy and verify Firestore rules/data.
- [ ] **Category course list** — `lib/category_courses.dart`: filters the
  in-process course catalog.
- [ ] **Course details and curriculum** — `lib/course_details.dart`: renders
  the local course object and local quiz/purchase state.
- [ ] **Module details** — `lib/module_detail_page.dart`: reads modules and
  lessons from the local course object.
- [ ] **Lesson/video player** — `lib/lesson_page.dart`,
  `lib/widgets/lesson_video_player.dart`, and `lib/open_lesson.dart`: use
  bundled video assets and in-memory progress/resume state.
- [ ] **My Learning** — `lib/my_learning_page.dart`: derives enrolled and
  completed courses from process-local state.
- [ ] **Wishlist** — `lib/wishlist_page.dart`: uses an in-memory notifier.
- [ ] **Profile** — `lib/profile_page.dart` and `lib/edit_profile_page.dart`:
  profile display loads from Auth/Firestore during sign-in, and name/phone/bio
  edits now call the owner-scoped Firestore update. Live rules and database
  writes remain unverified; email is read-only and profile photo upload awaits
  Firebase Storage configuration.
- [ ] **Cart** — `lib/cart.dart` and `lib/cart_page.dart`: cart is in memory.
- [ ] **Checkout** — `lib/checkout_page.dart`: creates no backend order.
- [ ] **UPI payment and success** — `lib/upi_payment_page.dart`: demo QR and
  simulated payment confirmation; no real payment verification.
- [ ] **Quiz and results** — `lib/quiz_page.dart`, `lib/quiz.dart`, and
  `lib/quiz_results.dart`: seeded quizzes and attempts are local; quiz catalog
  uses `SharedPreferences`, while attempts are in memory.
- [ ] **Certificate** — `lib/certificate_page.dart`: generated/displayed from
  local completion data; no persisted issuance record.

### Admin panel

- [ ] **Dashboard and statistics** — `lib/admin_dashboard.dart`: navigation
  works locally; displayed statistics are not derived from a backend.
- [ ] **Manage courses** — `lib/admin_courses_page.dart`: contains local seed
  entries and in-memory add/edit/delete; not durable or synchronized.
- [ ] **Create/edit course form** — `lib/create_course_quiz_page.dart`:
  returns an in-memory course; resource selection is local and is not uploaded
  to durable storage.
- [ ] **Alternate course form** — `lib/admin_create_course_page.dart`: a
  separate form with simulated upload behavior; it is not the form currently
  opened by the dashboard's course flow.
- [ ] **Manage categories** — `lib/admin_category.dart`: Firestore-backed
  realtime list and add/edit/delete share the `categories` collection with the
  user page. Deploy and verify Firestore rules/data; course synchronization
  still depends on migrating the course catalog.
- [ ] **Manage users** — `lib/admin_manega_user.dart`: local sample users and
  in-memory edits/deletes; no Auth account administration or persisted roles.
- [ ] **Enrollments** — `lib/admin_enrollments_page.dart`: fixed sample
  enrollment rows and totals.
- [ ] **Orders & payments** — `lib/admin_orders_page.dart`: fixed sample order
  rows; no payment-provider records.
- [ ] **Admin profile** — `lib/admin_profile.dart`: locally managed display
  data; not tied to an authenticated admin profile.
- [ ] **Quiz management/editor** — `lib/admin_quiz_management.dart`: quiz
  catalog operations persist only on this device via `SharedPreferences`.
- [ ] **Course delete confirmation** — `lib/admin_course_delete.dart`: dialog
  only; deletion durability depends on the course store.

### Shared data, models, and reusable UI

- [ ] **Course catalog and curriculum** — `lib/course.dart`: built-in courses,
  lessons, and category/course helpers are local constants; the recently added
  admin-created catalog entries exist only for the running process.
- [ ] **Session and user profile state** — `lib/session.dart`: updated from
  Firebase Auth results, but broader account-state restoration and profile
  synchronization remain incomplete.
- [ ] **Cart and purchases** — `lib/cart.dart`, `lib/purchases.dart`: local
  notifiers, not durable user-scoped records.
- [ ] **Learning progress** — `lib/progress.dart`: completion, resume points,
  and video positions are in memory.
- [ ] **Reusable navigation/progress/completion widgets** —
  `lib/widgets/nav_bar.dart`, `lib/widgets/progress_card.dart`,
  `lib/widgets/completion_card.dart`, and `lib/widgets/module_row.dart`: must
  consume migrated state without changing the existing design.
- [ ] **Create-course compatibility alias** — `lib/create_course_page.dart`:
  exports the active create-course form.
- [ ] **Quiz list page** — `lib/course_quiz_list_page.dart`: currently has no
  page implementation.
- [ ] **App startup** — `lib/main.dart`: initializes Firebase on Android only;
  other platforms still need FlutterFire options.

## Firebase CRUD verification matrix

`Wired*` means the client code is connected but has not been exercised against
the live Firebase project or the emulator. `Local` means the screen still uses
in-memory, seeded, or device-only data. `Blocked` means the operation requires
a trusted backend or missing platform/service setup. Tests listed here are
automated UI tests and do not prove live database persistence.

| Page | Collection / service | Create | Read | Update | Delete | Realtime | Testing |
|---|---|---:|---:|---:|---:|---:|---|
| Splash / session restore | Firebase Auth, `users`, `admins` | — | Wired* | — | — | No | Fake Auth tests |
| User login / password reset | Firebase Auth | — | Wired* | — | — | No | Fake Auth tests |
| Registration | Firebase Auth, `users` | Wired* | Wired* | — | — | No | Fake Auth tests |
| Admin login | Firebase Auth, `admins`, `users` | — | Wired* | — | — | No | Fake role tests |
| Home / bottom navigation | `courses`, `categories`, user progress | Local | Local | — | — | No | UI tests only |
| Search | `courses` | — | Local | — | — | No | UI tests only |
| Categories | `categories` | Admin | Wired* | Admin | Admin | Wired* | Fake repository tests |
| Category course list | `courses` | — | Local | — | — | No | UI tests only |
| Course details / curriculum | `courses`, `course_quizzes` | — | Local | — | — | No | UI tests only |
| Module details | `courses` | — | Local | — | — | No | UI tests only |
| Lesson / video player | `users/{uid}/progress` | Local | Local | Local | — | No | UI tests only |
| My Learning | `enrollments`, user progress | — | Local | — | — | No | UI tests only |
| Wishlist | `users/{uid}/wishlist` | Local | Local | Local | Local | No | UI tests only |
| Profile display | `users/{uid}` | — | Wired* | — | — | No | UI tests only |
| Edit Profile | `users/{uid}` | — | Local session | Wired* | — | No | Fake Auth service |
| Cart | No Firestore collection yet | Local | Local | Local | Local | No | UI tests only |
| Checkout | `orders` | Blocked | — | — | — | No | No backend test |
| UPI payment / success | `orders`, `enrollments` | Blocked | — | — | — | No | Demo payment tests |
| Quiz / results | `course_quizzes`, quiz attempts | Local | Local | Local | Local | No | UI tests only |
| Certificate | No issuance collection yet | — | Local | — | — | No | UI tests only |
| Admin dashboard / statistics | `users`, `courses`, `orders`, `enrollments` | — | Local | — | — | No | UI tests only |
| Manage courses | `courses` | Local | Local | Local | Local | No | UI tests only |
| Create/edit course forms | `courses` | Local | Local | Local | — | No | UI tests only |
| Alternate course form | `courses`, Storage | Local | Local | Local | Local | No | UI tests only |
| Manage categories | `categories` | Wired* | Wired* | Wired* | Wired* | Wired* | Fake repository tests |
| Manage users | `users`, Firebase Auth | Local | Local | Local | Local | No | UI tests only |
| Enrollments | `enrollments` | — | Local | — | — | No | UI tests only |
| Orders & payments | `orders` | Blocked | Local | Blocked | Blocked | No | UI tests only |
| Admin profile | `users/{uid}` | — | Local | Local | — | No | UI tests only |
| Quiz management/editor | `course_quizzes` | Local | Local | Local | Local | No | Device-storage tests |
| Course delete confirmation | `courses` | — | Local | — | Local | No | UI tests only |

## Backend prerequisites and security gates

- [x] Select/provide a Firebase project and its project ID (present in the supplied Android config).
- [x] Restrict the current Firebase target to Android.
- [x] Enable Cloud Firestore (reported by the project owner).
- [x] Enable Firebase Authentication Email/Password (reported by the project owner).
- [ ] Confirm/enable Firebase Storage and verify that the default bucket exists.
- [ ] Integrate Firebase Storage uploads; `storage.rules` currently permits
  only an authenticated user to manage their own image under
  `users/{uid}/profile/`, with a 5 MiB limit, and denies all other paths.
- [ ] Create the first admin Auth account and provision `admins/{uid}` manually
  in Firebase Console; no admin email/account was provided. Never grant roles
  based on an email substring or client-side flag.
- [ ] Deploy `firestore.rules` before connecting real user data.
- [ ] Deploy `storage.rules` before enabling any upload feature.
- [ ] After creating the first admin in Firebase Authentication, create
  `admins/{uid}` in Firestore manually from the trusted Firebase Console. The
  client intentionally cannot grant itself admin access.
- [ ] Configure Razorpay order creation and signature verification on a trusted
  server; store secrets in Firebase Functions/Secret Manager, never in the app.
- [ ] Add emulator-backed tests for authorization, CRUD, persistence, and
  realtime synchronization before declaring a page complete.

The Android APK build is not yet verified: Gradle could not download a
Google Maven artifact in this environment due to a network/TLS resolution
failure. `flutter test` passes, and `flutter analyze lib/main.dart` is clean.

Do not put service-account keys, private credentials, or payment secrets in
this repository or in chat. Generated Flutter client configuration is not a
replacement for secure database rules.
