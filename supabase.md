```sql
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text,
  phone text,
  date_of_birth date,
  language text,
  avatar_url text,
  selected_courses text[],
  onboarding_completed boolean default false,
  created_at timestamptz default now()
);

```