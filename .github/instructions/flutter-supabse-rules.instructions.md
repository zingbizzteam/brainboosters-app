---
applyTo: '**'
---
## **1. Coding Standards**

- **Naming Conventions:**
    - Classes, enums, typedefs: `UpperCamelCase`
    - Variables, methods, parameters: `lowerCamelCase`
    - Files and folders: `snake_case`
    - Constants: `UPPERCASE_SNAKE_CASE`
    - Use descriptive, meaningful names; avoid abbreviations and magic numbers[^1][^13].
- **Formatting \& Linting:**
    - Enforce formatting with `flutter format` and `flutter_lints`.
    - No unused code or imports.
    - Write clear comments for complex logic, but prefer self-documenting code[^7][^13].
- **Code Quality:**
    - Keep functions and widgets small and focused.
    - Use DRY (Don’t Repeat Yourself) principles.
    - Write unit, widget, and integration tests for all business logic and critical UI[^7][^13].

---

## **2. Flutter App Architecture \& Modularity**

- **Project Structure:**
    - Use a modular architecture: split into independent feature modules (e.g., `/modules/auth`, `/modules/courses`, `/modules/profile`).
    - Place shared code (widgets, themes, utils, services) in a `/shared` or `/core` directory.
    - Each feature module should have its own `data`, `domain`, and `presentation` layers for models, logic, and UI.
- **Separation of Concerns:**
    - UI (widgets/screens) should be presentation-only and not contain business logic.
    - Use state management (e.g., BLoC, Riverpod, Provider) to separate logic from UI.
    - Service and repository layers handle all Supabase/data access and business rules.
- **Dependency Management:**
    - Use dependency injection (e.g., `get_it`, `provider`) for services and repositories.
    - No direct cross-module dependencies—communicate via interfaces or shared services.

---

## **3. Responsiveness \& UI**

- **Responsive Design:**
    - Every screen must adapt to mobile, tablet, and web/desktop using responsive layouts.
    - Use `MediaQuery`, `LayoutBuilder`, and packages like `responsive_framework` for breakpoints and scaling.
    - Avoid hardcoded sizes; use relative units and flexible widgets (e.g., `Flexible`, `Expanded`, `Spacer`).
    - Test UI on all target devices.
- **UI Consistency:**
    - Centralize theme, colors, and text styles in a shared theme file.
    - Use reusable, parameterized widgets for cards, lists, forms, etc.
    - All navigation must support deep linking and web routes.

---

## **4. Supabase \& Data Layer**

- **Supabase Integration:**
    - Initialize Supabase in `main.dart` with secure keys.
    - Use the `supabase_flutter` package for all auth, database, and storage operations.
    - All database access is via service/repository classes—never directly in UI code.
- **Data Management:**
    - CRUD: All Create, Read, Update, Delete operations are handled via Supabase APIs.
    - Use row-level security (RLS) and policies to secure data access by user role.
    - Listen for real-time updates using Supabase subscriptions for live features (e.g., chat, notifications, progress).
    - Store and access files (e.g., course videos, certificates) using Supabase Storage APIs.
- **Data Modeling:**
    - Design normalized tables for users, courses, enrollments, lessons, quizzes, progress, notifications, etc.
    - Use clear, consistent naming for all tables and fields.
    - Document all schema and API endpoints.

---

## **5. Preferences \& Domain Knowledge**

- **E-Learning Domain:**
    - Support for user roles: student, instructor, admin.
    - Modular features: course catalog, enrollments, lessons, quizzes, assignments, progress tracking, certificates, notifications.
    - Secure authentication (email/password, social login) and user profile management.
    - Real-time updates for progress, chat, and notifications.
    - Analytics for learning progress and engagement.
- **AI/Tooling Preferences:**
    - Use Copilot, Gemini, and MCP/Context7 for code suggestions, but always review and refactor for clarity and standards.
    - Prefer modular, testable, and maintainable code over quick hacks.
    - Document architectural decisions and key workflows in a `docs/` folder.

---

## **Summary Table**

| Area | Rule/Best Practice |
| :-- | :-- |
| Naming | UpperCamelCase (classes), lowerCamelCase (vars), snake_case (files), UPPERCASE (constants) |
| Structure | Modular features, shared/core for common code, strict separation of data/domain/presentation |
| Responsiveness | Use breakpoints, flexible widgets, and responsive packages for all screens |
| Supabase | All data via services, secure with RLS, use real-time subscriptions for live features |
| State Management | Use BLoC/Riverpod/Provider, keep UI logic-free |
| Testing | Write tests for logic and UI, use lints and code analysis |
| Documentation | Comment complex code, document data models and API, maintain `docs/` for architecture decisions |
| Security | Enforce RLS, validate all user input, never expose secrets in code |


---
