-- Pegar en Supabase > SQL Editor > Run (después de migracion-3.sql)
alter table companies add column if not exists logo text default '';
create policy "likes quitar" on likes for delete to authenticated using (company_id = auth.uid());
