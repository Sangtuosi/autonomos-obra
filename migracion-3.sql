-- Pegar en Supabase > SQL Editor > Run (después de migracion-2.sql)
alter table profiles
  add column if not exists skills_extra text default '',
  add column if not exists vehicle text default '',
  add column if not exists tools text default '',
  add column if not exists work_notes text default '',
  add column if not exists tpc boolean default false,
  add column if not exists prl boolean default false;
alter table likes add column if not exists from_autonomo boolean not null default false;

drop policy if exists "likes crear" on likes;
drop policy if exists "likes responder" on likes;
create policy "likes crear" on likes for insert to authenticated with check (
  status = 'pending' and (
    (company_id = auth.uid() and from_autonomo = false) or
    (autonomo_id = auth.uid() and from_autonomo = true)));
create policy "likes responder" on likes for update to authenticated
  using ((autonomo_id = auth.uid() and from_autonomo = false) or (company_id = auth.uid() and from_autonomo = true))
  with check ((autonomo_id = auth.uid() and from_autonomo = false) or (company_id = auth.uid() and from_autonomo = true));

-- Perfil público para compartir por WhatsApp (el teléfono sigue privado)
create policy "profiles publicos" on profiles for select to anon using (true);
create policy "reviews publicas" on reviews for select to anon using (true);
