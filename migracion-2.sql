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
