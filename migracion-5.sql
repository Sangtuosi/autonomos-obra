-- Pegar en Supabase > SQL Editor > Run (después de migracion-4.sql)
-- Opiniones del autónomo sobre la empresa
create table if not exists company_reviews(
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies on delete cascade,
  autonomo_id uuid references profiles on delete cascade,
  stars int not null check (stars between 1 and 5),
  comment text default '',
  created_at timestamptz default now(),
  unique(company_id, autonomo_id));
alter table company_reviews enable row level security;
create policy "creviews ver" on company_reviews for select to authenticated using (true);
create policy "creviews crear" on company_reviews for insert to authenticated with check (
  autonomo_id = auth.uid() and exists (select 1 from likes l where l.company_id = company_reviews.company_id
    and l.autonomo_id = auth.uid() and l.status = 'accepted'));
