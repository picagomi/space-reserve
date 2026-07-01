-- ============================================================
-- SpaceReserve — Supabase schema / RLS / seed
-- Supabase ダッシュボード → SQL Editor に貼り付けて実行してください
-- ============================================================

-- 施設
create table if not exists public.facilities (
  id          text primary key,
  store_id    text not null,
  name        text not null,
  type        text,
  cap         int,
  area        text,
  loc         text,
  price       int,
  open_h      int,
  close_h     int,
  icon        text,
  equip       jsonb default '[]'::jsonb,
  color       text,
  rating      numeric default 0,
  reviews     int default 0,
  description text
);

-- 予約
create table if not exists public.reservations (
  id            text primary key,
  facility_id   text,
  facility_name text,
  icon          text,
  color         text,
  store_id      text,
  store_name    text,
  store_area    text,
  date          text,      -- 'YYYY-MM-DD'
  start_h       int,
  end_h         int,
  hours         int,
  total         int,
  name          text,
  company       text,
  email         text,
  phone         text,
  people        text,
  purpose       text,
  note          text,
  created_at    timestamptz default now()
);

create index if not exists idx_res_fac_date on public.reservations(facility_id, date);

-- ============================================================
-- RLS（行レベルセキュリティ）
-- ============================================================
alter table public.facilities   enable row level security;
alter table public.reservations enable row level security;

-- 施設：閲覧は誰でも可、追加/編集/削除はログイン済みの運営者のみ
drop policy if exists "facilities_read"  on public.facilities;
drop policy if exists "facilities_write" on public.facilities;
create policy "facilities_read"  on public.facilities for select using (true);
create policy "facilities_write" on public.facilities for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- 予約：作成・閲覧は誰でも可、削除（取消）はログイン済みの運営者のみ
--   ※ select を公開しているのは「空き状況の表示」のため。
--      本番では予約者の個人情報を返さないビュー/RPCに置き換えるのが望ましい。
drop policy if exists "reservations_read"   on public.reservations;
drop policy if exists "reservations_insert" on public.reservations;
drop policy if exists "reservations_delete" on public.reservations;
create policy "reservations_read"   on public.reservations for select using (true);
create policy "reservations_insert" on public.reservations for insert with check (true);
create policy "reservations_delete" on public.reservations for delete
  using (auth.role() = 'authenticated');

-- ============================================================
-- 施設シード（3拠点・8施設）
-- ============================================================
insert into public.facilities
 (id,store_id,name,type,cap,area,loc,price,open_h,close_h,icon,equip,color,rating,reviews,description) values
('A','S1','スカイビュー会議室','会議室',12,'32㎡','12F',3000,8,21,'🏙️','["プロジェクター","ホワイトボード","Wi-Fi","大型モニター"]','linear-gradient(135deg,#b5687f,#d99fb0)',4.8,126,'最上階・眺望良好。役員会議やセミナーに。'),
('B','S1','コンパクトミーティングルーム','会議室',4,'12㎡','5F',1200,9,20,'💬','["モニター","Wi-Fi","ホワイトボード"]','linear-gradient(135deg,#6a8caf,#a9c3dd)',4.5,89,'少人数の打合せ・1on1・オンライン会議に最適。'),
('E','S1','防音セミナールーム','会議室',20,'45㎡','6F',3800,8,21,'🎤','["マイク・音響","プロジェクター","録画設備","Wi-Fi"]','linear-gradient(135deg,#8a6aaf,#bda9dd)',4.4,53,'防音仕様。研修・配信・収録に対応。'),
('C','S2','コワーキングデスク','ワークスペース',1,'個席','3F',600,8,22,'💻','["電源","Wi-Fi","フリードリンク"]','linear-gradient(135deg,#5e9e84,#9bc9b4)',4.6,204,'集中作業・リモートワークに。1席単位で予約。'),
('D','S2','多目的レンタルスペース','スペース',30,'68㎡','2F',5000,9,22,'🎪','["音響設備","プロジェクター","可動式テーブル","Wi-Fi"]','linear-gradient(135deg,#c08a4a,#e0bd8c)',4.7,67,'イベント・ワークショップ・撮影に。レイアウト自由。'),
('H','S2','防音ワークブース','ワークスペース',1,'個室','3F',800,7,23,'🎧','["電源","Wi-Fi","防音","モニター"]','linear-gradient(135deg,#7b6aaf,#b4a6dd)',4.7,175,'完全個室の防音ブース。Web会議・集中作業に。'),
('F','S3','カフェラウンジ席','ワークスペース',6,'20㎡','1F',900,8,22,'☕','["電源","Wi-Fi","カフェ併設"]','linear-gradient(135deg,#b07d6a,#ddb6a3)',4.3,142,'リラックスした打合せ・商談に。ドリンク注文可。'),
('G','S3','ガラス張り役員ルーム','会議室',8,'26㎡','10F',2600,8,21,'🪟','["大型モニター","Web会議カメラ","ホワイトボード","Wi-Fi"]','linear-gradient(135deg,#4f8a8b,#9ecfcf)',4.9,38,'採光良好な個室。商談・取締役会・オンライン会議に。')
on conflict (id) do nothing;

-- 拠点(STORES)はアプリ側に定数として保持しています（S1=東京/丸の内, S2=横浜/みなとみらい, S3=大阪/梅田）。
-- 拠点もDB管理したい場合は stores テーブルを追加してください。
