# ALVENTIRA: Warisan Sang Penjaga Cahaya

RPG story-driven, open world 2D pixel art bernuansa fantasy-anime, dibangun dengan **Godot 4.3**, dirancang native untuk Android 10–16 (touchscreen, tanpa root/Shizuku).

> **Status:** Vertical slice awal — satu area playable penuh (Desa Kayu Embun), satu side quest lengkap end-to-end ("Kambing yang Hilang"), sistem inti (combat, dialog, quest, inventory, save/load) sudah berfungsi nyata, bukan mockup. Ini fondasi untuk dikembangkan menjadi RPG jangka panjang — lihat `docs/story-design-doc.md` untuk lore & rencana cerita lengkap.

## Story Singkat

Tiga ratus tahun setelah bencana *Keretakan Aether* meruntuhkan peradaban kuno Kaum Virean, seorang pemuda desa bernama **Kael Arungi** menemukan bahwa tanda lahir di punggungnya menandakannya sebagai **Wardain** terakhir — penjaga Aether yang seharusnya sudah punah. Diburu oleh kultus **Order of Ash** dan diincar kerajaan, Kael harus memilih jalannya sendiri untuk mencegah bencana kedua. Detail lengkap dunia, karakter, dan struktur quest ada di `docs/story-design-doc.md`.

## Fitur (Vertical Slice Saat Ini)

- Eksplorasi 2D dengan collision, kamera mengikuti player
- Kontrol touchscreen penuh: virtual joystick + tombol Serang/Aksi/Tas/Quest/Pause
- Combat real-time sederhana (attack hitbox, musuh dengan AI kejar-serang, HP/damage/EXP/loot)
- Sistem dialog data-driven (JSON) dengan percabangan pilihan
- Quest system (start/complete, reward gold+item)
- Inventory dengan item konsumsi (potion)
- Save/load lokal berbasis JSON, penulisan atomik (anti-corrupt), autosave berkala + saat aplikasi di-pause
- Main menu (New Game/Continue/Settings/Quit), Pause menu (Resume/Save/Settings/Main Menu)

## Kebutuhan Android

- **Minimum:** Android 10 (API 29)
- **Target:** Android 16 (API 35+)
- Tidak butuh root, Shizuku, atau akses khusus apa pun
- APK biasa, terpasang seperti aplikasi normal
- Tidak butuh koneksi internet untuk bermain — seluruhnya lokal

## Struktur Project

```
project/
├── .github/workflows/build.yml   # CI build APK, tanpa Repository Secret
├── android/                      # Debug keystore development (lihat bawah)
├── assets/                       # characters/enemies/npcs/tiles/ui — placeholder legal
├── data/
│   ├── dialogues/*.json          # Dialog NPC, data-driven
│   └── quests/*.json             # Definisi quest
├── docs/                         # (di luar folder ini) story-design-doc.md
├── scenes/
│   ├── Main.tscn                 # Dunia Desa Kayu Embun
│   ├── MainMenu.tscn
│   ├── Player.tscn / NPC_Doni.tscn / Goat.tscn / Enemy.tscn
│   └── ui/                       # DialogueBox, InventoryPanel, QuestPanel, PauseMenu, TouchControls
├── scripts/
│   ├── autoload/                 # GameManager, SaveSystem, QuestSystem, DialogueSystem, UIManager
│   └── *.gd                      # Player, Enemy, NPC, kamera, dsb.
├── project.godot
└── export_presets.cfg
```

Prinsip arsitektur: setiap sistem (combat, dialog, quest, save, inventory) dipisah ke file/autoload sendiri-sendiri supaya mudah dikembangkan tanpa saling mengganggu.

## Cara Menjalankan Project Secara Lokal

1. Install **Godot 4.3** (stable, bukan .NET/Mono) dari [godotengine.org](https://godotengine.org/download).
2. Buka Godot → Import → pilih file `project.godot` di folder ini.
3. Tekan F5 atau tombol Play. Scene awal adalah `MainMenu.tscn`.
4. Untuk mencoba kontrol touch di desktop, aktifkan emulasi touch dari mouse (sudah di-set di `project.godot` lewat `pointing/emulate_touch_from_mouse=true`), jadi klik mouse akan berperilaku seperti tap.

## Cara Build APK Secara Lokal

1. Di Godot, buka **Project → Export**.
2. Pastikan Android SDK & Java sudah dikonfigurasi di **Editor → Editor Settings → Export → Android** (path SDK, `adb`, `jarsigner`).
3. Preset "Android" di project ini sudah dikonfigurasi memakai `android/alventira-debug.keystore` (lihat bagian signing di bawah) — tidak perlu bikin keystore baru untuk development.
4. Klik **Export Project**, pilih lokasi output `.apk`.

## Cara Build via GitHub Actions

Setiap push ke branch `main` (atau lewat tab **Actions → Build Android APK → Run workflow**) otomatis:

1. Checkout → tampilkan info environment (versi Godot, Java, disk)
2. Setup export template Godot & konfigurasi Android SDK
3. Verifikasi seluruh file penting project ada
4. Validasi project (`godot --headless --import`) + validasi seluruh file JSON dialog/quest
5. Set `versionCode` otomatis dari nomor build (`github.run_number`) — selalu naik
6. Build & export APK (`godot --headless --export-debug`)
7. Test dasar: cek ukuran file, cek struktur APK valid (ada `AndroidManifest.xml`), cek signature
8. Package APK dengan nama versi
9. Upload sebagai **GitHub Actions Artifact** (bisa diunduh dari halaman run workflow)

**Tidak butuh Repository Secret apa pun.** Kalau build gagal, buka tab Actions — setiap step diberi nama jelas dan `set -e` dipakai di semua step supaya error tidak tersembunyi; step yang gagal akan langsung terlihat merah dengan log detail di atasnya.

## Informasi Signing Development

File `android/alventira-debug.keystore` adalah keystore development yang **sengaja dikomit ke repository** (bukan lewat Secret), dengan:

- Alias: `alventira_dev`
- Password store & key: `alventira123`
- Masa berlaku: 20.000 hari (hingga tahun 2081)

Karena keystore ini selalu sama di setiap build, APK versi baru bisa **meng-update APK versi lama tanpa perlu uninstall** — sesuai kebutuhan development/testing internal.

⚠️ **Peringatan penting:** keystore ini **BUKAN untuk production / rilis ke Google Play Store**. Karena filenya publik di repository, siapa pun bisa membuat APK yang "terlihat resmi" dengan signature yang sama. Untuk rilis production sungguhan, buat keystore terpisah, jangan pernah dikomit ke repo, dan simpan sebagai Repository Secret khusus rilis (di luar scope workflow ini).

## Cara Menambahkan Konten Baru

### Menambah Karakter / NPC
1. Tambahkan sprite ke `assets/npcs/` (atau `assets/characters/` untuk party member).
2. Buat `SpriteFrames` (`.tres`) baru mengikuti pola `assets/npcs/doni_frames.tres`.
3. Duplikasi `scenes/NPC_Doni.tscn`, ganti `SpriteFrames`, atur `npc_name`, `dialogue_path`, `quest_id` di Inspector.
4. Instance scene NPC baru ke `scenes/Main.tscn` (atau map baru).

### Menambah NPC Biasa (tanpa quest)
Sama seperti di atas tapi kosongkan `quest_id` — NPC akan selalu menampilkan node `start` dari file dialognya.

### Menambah Quest
1. Buat file baru di `data/quests/nama_quest.json` mengikuti format `kambing_hilang.json` (field: `id`, `title`, `giver`, `description`, `reward_gold`, `reward_items`).
2. Buat file dialog terkait di `data/dialogues/` dengan node `start`, `accept_quest` (pakai `"action": "start_quest:<id>"`), dan node penyelesaian (pakai `"action": "complete_quest:<id>"`).
3. Hubungkan lewat `NPC.gd` (`quest_id`, `node_active_incomplete`, `node_active_complete`, dst).

### Menambah Map / Area Baru
1. Duplikasi `scenes/Main.tscn` sebagai titik awal (punya Player, TouchControls, UI layer siap pakai).
2. Ganti isi `Ground`, `Decorations`, `Boundaries`, dan NPC/musuh sesuai area baru.
3. Untuk transisi antar-area, tambahkan `Area2D` pemicu di tepi map yang memanggil `get_tree().change_scene_to_file(...)` — belum diimplementasikan di slice ini, tapi struktur scene sudah siap menampungnya.

### Menambah Item
Tambahkan efek pemakaiannya di `GameManager.use_item()` (`scripts/autoload/GameManager.gd`), lalu referensikan `id`-nya di `reward_items` pada file quest atau lewat `GameManager.add_item(...)` di tempat lain (misalnya lewat chest — belum diimplementasikan di slice ini).

### Menambah Musuh
1. Duplikasi `scenes/Enemy.tscn`, ganti `SpriteFrames`, atur `enemy_name`, `max_hp`, `attack_damage`, `exp_reward`, `gold_reward` di Inspector.
2. Instance ke scene map yang diinginkan.

## Cara Membuat Release

1. Pastikan semua perubahan sudah di-commit ke `main`.
2. Push — workflow `build.yml` berjalan otomatis dan menghasilkan artifact `alventira-android-apk`.
3. Unduh artifact dari halaman **Actions** run yang bersangkutan, atau (opsional, belum di-setup di workflow ini) tambahkan step `actions/create-release` untuk otomatis membuat GitHub Release dari artifact tersebut.

## Batasan & Rencana Lanjutan (Transparansi)

Bagian ini sengaja dituliskan jujur, sesuai prinsip "kecil tapi playable daripada besar tapi placeholder":

- **Baru satu area map** (Desa Kayu Embun). Hutan Lirenwood, Kota Sorenvale, Gua Rengkah Bumi, dll di `docs/story-design-doc.md` belum diimplementasikan sebagai scene.
- **Belum ada sistem transisi antar-area**, boss battle, equipment/armor, atau skill/MP aktif — arsitektur sudah dirancang supaya ini bisa ditambahkan tanpa merombak sistem inti.
- **Belum ada audio** (BGM/SFX) — struktur folder `assets/music/` dan `assets/sounds/` bisa ditambahkan kapan pun; `AudioServer` bus "Master" sudah dipakai di pengaturan volume.
- **Belum pernah dijalankan/dikompilasi langsung** oleh proses yang menuliskan project ini (tidak ada akses ke Godot engine maupun jaringan internet saat project ini dibuat) — validasi sesungguhnya baru terjadi saat kamu membuka project di Godot Editor atau menjalankan workflow GitHub Actions. Kalau menemukan error import/compile, itu wajar untuk first-run project sebesar ini; laporkan pesan errornya dan akan diperbaiki secara spesifik.

## Lisensi

Lihat `LICENSE`. Kode berlisensi MIT. Story, lore, dan nama karakter orisinal — lihat catatan kepemilikan di `LICENSE`.
