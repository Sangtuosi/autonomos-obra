-- Pegar entero en Supabase > SQL Editor > Run
create table if not exists profiles(
  id uuid primary key references auth.users on delete cascade,
  name text not null, trade text not null default 'Albañil', zone text not null default 'Vallès',
  years int default 0, bio text default '', available boolean default true,
  photos text[] default '{}', created_at timestamptz default now());
create table if not exists companies(
  id uuid primary key references auth.users on delete cascade,
  name text not null, rea text default '', created_at timestamptz default now());
create table if not exists contacts(
  user_id uuid primary key references auth.users on delete cascade, phone text not null);
create table if not exists likes(
  company_id uuid references companies on delete cascade,
  autonomo_id uuid references profiles on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined')),
  job text default '', created_at timestamptz default now(),
  primary key(company_id, autonomo_id));
create table if not exists reviews(
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies on delete cascade,
  autonomo_id uuid references profiles on delete cascade,
  stars int not null check (stars between 1 and 5), comment text default '',
  created_at timestamptz default now(), unique(company_id, autonomo_id));

alter table profiles enable row level security;
alter table companies enable row level security;
alter table contacts enable row level security;
alter table likes enable row level security;
alter table reviews enable row level security;

create policy "profiles ver" on profiles for select to authenticated using (true);
create policy "profiles crear" on profiles for insert to authenticated with check (id = auth.uid());
create policy "profiles editar" on profiles for update to authenticated using (id = auth.uid());
create policy "companies ver" on companies for select to authenticated using (true);
create policy "companies crear" on companies for insert to authenticated with check (id = auth.uid());
create policy "companies editar" on companies for update to authenticated using (id = auth.uid());

create policy "contacts ver" on contacts for select to authenticated using (
  user_id = auth.uid() or exists (select 1 from likes l where l.status = 'accepted' and (
    (l.company_id = auth.uid() and l.autonomo_id = contacts.user_id) or
    (l.autonomo_id = auth.uid() and l.company_id = contacts.user_id))));
create policy "contacts crear" on contacts for insert to authenticated with check (user_id = auth.uid());
create policy "contacts editar" on contacts for update to authenticated using (user_id = auth.uid());

create policy "likes ver" on likes for select to authenticated using (company_id = auth.uid() or autonomo_id = auth.uid());
create policy "likes crear" on likes for insert to authenticated with check (company_id = auth.uid() and status = 'pending');
create policy "likes responder" on likes for update to authenticated using (autonomo_id = auth.uid()) with check (autonomo_id = auth.uid());
revoke update on likes from authenticated;
grant update (status) on likes to authenticated;

create policy "reviews ver" on reviews for select to authenticated using (true);
create policy "reviews crear" on reviews for insert to authenticated with check (
  company_id = auth.uid() and exists (select 1 from likes l where l.company_id = auth.uid()
    and l.autonomo_id = reviews.autonomo_id and l.status = 'accepted'));

insert into storage.buckets (id, name, public) values ('fotos','fotos', true) on conflict do nothing;
create policy "fotos subir" on storage.objects for insert to authenticated
  with check (bucket_id = 'fotos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "fotos borrar" on storage.objects for delete to authenticated
  using (bucket_id = 'fotos' and (storage.foldername(name))[1] = auth.uid()::text);
-- Pegar en Supabase > SQL Editor > Run (añade campos nuevos a los perfiles)
alter table profiles
  add column if not exists skills text[] default '{}',
  add column if not exists rate text default '',
  add column if not exists registered boolean default false,
  add column if not exists insured boolean default false,
  add column if not exists has_van boolean default false,
  add column if not exists own_tools boolean default false;
alter table companies
  add column if not exists kind text default 'Constructora',
  add column if not exists zone text default 'Vallès',
  add column if not exists looking_for text[] default '{}',
  add column if not exists job text default '',
  add column if not exists about text default '';
