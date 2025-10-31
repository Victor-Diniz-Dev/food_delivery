-- dishes: catálogo de produtos
create table if not exists public.dishes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  price_cents int not null check (price_cents >= 0),
  image_url text,
  tags text[] default '{}',
  is_active boolean not null default true,
  created_at timestamptz default now()
);

-- users
create table if not exists public.users (
  id uuid primary key,
  email text unique,
  full_name text,
  created_at timestamptz default now()
);

-- orders
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  status text not null check (status in ('pending','paid','delivered','canceled')),
  total_cents int not null default 0,
  created_at timestamptz default now()
);

-- order_items
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references public.orders(id) on delete cascade,
  dish_id uuid references public.dishes(id),
  quantity int not null check (quantity > 0),
  unit_price_cents int not null check (unit_price_cents >= 0)
);

-- view: pedidos ativos
create or replace view public.v_orders_active as
  select * from public.orders where status in ('pending','paid');

-- ativar Row Level Security
alter table public.dishes enable row level security;
alter table public.users enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- políticas básicas
create policy "read public dishes" on public.dishes
for select to anon, authenticated using (is_active = true);

create policy "user self read" on public.users
for select to authenticated using (id = auth.uid());

create policy "user self upsert" on public.users
for insert to authenticated with check (id = auth.uid());

create policy "user self update" on public.users
for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

create policy "read own orders" on public.orders
for select to authenticated using (user_id = auth.uid());

create policy "insert own orders" on public.orders
for insert to authenticated with check (user_id = auth.uid());

create policy "read own order_items" on public.order_items
for select to authenticated using (
  exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
);

create policy "insert own order_items" on public.order_items
for insert to authenticated with check (
  exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
);
