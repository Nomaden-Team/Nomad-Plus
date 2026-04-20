<div align="center">

<img width="120" alt="Nomad Coffee Logo" src="https://github.com/user-attachments/assets/d39c584e-1d94-4598-bff9-bc53c4e82e46" />

# ☕ Nomad+

**Aplikasi Digital Cafe Teh Tarik Nomad**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-8B00FF?style=for-the-badge&logo=dart&logoColor=white)

</div>

---

## 👥 Tim Pengembang — NOMADEN

<div align="center">

| <img src="https://github.com/naylacamelia.png" width="72" style="border-radius:50%"/> | <img src="https://github.com/nabilaimtiyaz.png" width="72" style="border-radius:50%"/> | <img src="https://github.com/Ilyasa810.png" width="72" style="border-radius:50%"/> | <img src="https://github.com/LuthfiDffa.png" width="72" style="border-radius:50%"/> |
|:---:|:---:|:---:|:---:|
| **Nayla Camelia Indraswari** | **Nabila Imtiyaz Agustin** | **Muhammad Ilyasa' Izzuddin** | **Muhammad Reffi Fadillah** |
| `2409116009` | `2409116011` | `2409116033` | `2409116034` |
| Sistem Informasi A '24 | Sistem Informasi A '24 | Sistem Informasi A '24 | Sistem Informasi A '24 |
| [![GitHub](https://img.shields.io/badge/-Camel-181717?logo=github)](https://github.com/naylacamelia) | [![GitHub](https://img.shields.io/badge/-Lala-181717?logo=github)](https://github.com/nabilaimtiyaz) | [![GitHub](https://img.shields.io/badge/-Ilyasa'-181717?logo=github)](https://github.com/Ilyasa810) | [![GitHub](https://img.shields.io/badge/-Reffi-181717?logo=github)](https://github.com/LuthfiDffa) |

</div>

---

## 📚 Daftar Isi

- [📝 Deskripsi Aplikasi](#-deskripsi-aplikasi)
- [⚙️ Fitur Utama](#️-fitur-utama)
- [📦 Penjelasan Package](#-penjelasan-package-yang-digunakan)
- [📊 Use Case Diagram](#-use-case-diagram)
- [🔄 Flowchart Program](#-flowchart-program)
- [📑 Struktur Database](#-struktur-database)
- [🔒 Keamanan Database (RLS)](#-keamanan-database-rls)
- [🧩 Widget yang Digunakan](#-widget-yang-digunakan)
- [📂 Struktur Folder](#-struktur-folder--package)
- [🧰 Tech Stack](#-tech-stack)

---

## 📝 Deskripsi Aplikasi

**Nomad+** adalah aplikasi digital yang dirancang untuk membantu operasional **Cafe Teh Tarik Nomad** dalam mengelola menu, pesanan, serta interaksi dengan pelanggan secara lebih efisien dan terstruktur.

Aplikasi ini hadir dengan dua sisi pengalaman:

- 👤 **Pengguna (Pelanggan)** — dapat melihat menu, melakukan pemesanan, memanfaatkan promo & voucher, serta mengumpulkan poin loyalitas.
- 🧑‍💼 **Admin** — dapat mengelola data menu, pesanan, promo, dan voucher secara terpusat melalui dashboard yang terintegrasi.

---

## ⚙️ Fitur Utama

| No. | Fitur | Deskripsi |
|:---:|-------|-----------|
| 1 | 🏪 **Multi-Branch Selection** | Pengguna memilih cabang aktif melalui modal bottom sheet; menu dan antrean menyesuaikan cabang yang dipilih. Hanya cabang dengan status `is_open: true` yang bisa dipilih |
| 2 | 🏅 **Membership Tiering** | Sistem empat tier (Bronze → Silver → Gold → Platinum) dengan progress bar dan multiplier poin berbeda (1x, 1x, 1.5x, 2x) |
| 3 | ⭐ **Point & Rewards** | Poin dikumpulkan dari setiap transaksi selesai; dapat digunakan sebagai potongan harga (maks. 10% subtotal) atau ditukar langsung dengan menu reward (maks. 1 redeem per hari) |
| 4 | 🎟️ **Advanced Voucher System** | Validasi kode voucher dengan parameter minimal belanja, batas total pemakaian, batas per user, dan periode berlaku. Voucher dan poin tidak bisa digunakan bersamaan |
| 5 | 🔢 **Real-time Queue Number** | Nomor antrean dibuat otomatis setelah transaksi berhasil |
| 6 | 📋 **Status History** | Pelacakan riwayat pesanan: *pending* → *confirmed* → *done* |
| 7 | 🛒 **Order Management (CRUD)** | Pengguna dapat membuat, melihat, mengubah, dan menghapus pesanan sebelum diproses |
| 8 | 🖥️ **Admin Dashboard** | Pengelolaan menu, cabang, pesanan, promo, dan voucher secara terpusat |
| 9 | 🍽️ **Menu Management** | Admin dapat menambah, mengedit, dan menghapus menu beserta status ketersediaan (`is_available`) per cabang |
| 10 | ✏️ **Custom Order Request** | Pengguna dapat menambahkan catatan khusus (tingkat gula, preferensi, dll.) pada setiap item pesanan |
| 11 | 🔐 **Authentication & Validation** | Validasi form (email, password, phone, name) menggunakan `Validators` class; autentikasi via Supabase Auth |

---

## 📦 Penjelasan Package yang Digunakan

> Versi package diambil langsung dari `pubspec.yaml` proyek.

### 🔹 Package Utama

| Package | Versi | Fungsi |
|---------|:-----:|--------|
| `get` | `^4.6.6` | State management reaktif (`Obx`, `GetBuilder`), navigasi (`Get.toNamed`, `Get.back`), dan notifikasi (`Get.snackbar`, `Get.bottomSheet`, `Get.dialog`) |
| `supabase_flutter` | `^2.5.6` | Backend-as-a-service: autentikasi user, operasi CRUD ke database PostgreSQL, dan Row Level Security |
| `flutter_dotenv` | `^5.1.0` | Membaca konfigurasi sensitif dari file `.env` (Supabase URL & anon key) agar tidak hardcoded dalam kode sumber |
| `image_picker` | `^1.2.1` | Mengambil gambar dari galeri atau kamera; digunakan untuk upload foto profil dan gambar menu oleh admin |

### 🌟 Package Nilai Tambah

| Package | Versi | Fungsi |
|---------|:-----:|--------|
| `google_fonts` | `^6.2.1` | Menerapkan font kustom Google Fonts untuk identitas visual yang konsisten di seluruh aplikasi |
| `qr_flutter` | `^4.0.0` | Menghasilkan QR Code pada fitur nomor antrean setelah transaksi berhasil |

---

## 📊 Use Case Diagram

<details>
<summary><b>🔍 Lihat Use Case Diagram</b></summary>
<br>
<img width="1915" height="747" alt="Use Case Diagram" src="https://github.com/user-attachments/assets/e82eebd9-d0e7-4258-aef2-2d8ac1aa1479" />
</details>

---

## 🔄 Flowchart Program

<details>
<summary><b>1. Menu Login</b></summary>
<br>
<img width="446" height="755" alt="Flowchart Login" src="https://github.com/user-attachments/assets/102e23b9-e9cc-455d-b436-6221ef21394c" />
</details>

<details>
<summary><b>2. Menu Register</b></summary>
<br>
<img width="197" height="521" alt="Flowchart Register" src="https://github.com/user-attachments/assets/f8b4c209-c1f4-4c5b-9e02-c824c19a737e" />
</details>

<details>
<summary><b>3. Menu User (Pelanggan)</b></summary>
<br>
<img width="774" height="858" alt="Flowchart User" src="https://github.com/user-attachments/assets/9b28dfae-9cc4-4288-aef3-43bbccac9a64" />
</details>

<details>
<summary><b>4. Menu Admin</b></summary>
<br>
<img width="496" height="853" alt="Flowchart Admin" src="https://github.com/user-attachments/assets/2e4f72b7-fb8c-4284-9a91-ae97e2cf5ade" />
</details>

---

## 📑 Struktur Database

### Relasi Antar Tabel

```
users ──────────┬──── orders ────┬──── order_items ──── menu_items ──── categories
                │                │                           │
                │                ├──── vouchers              └──── branches
                │                │    (voucher_id)
                │                └──── branches
                │                     (branch_id)
                │
                └──── voucher_usages ──── vouchers
```

---

### 🏪 Tabel `branches`
Menyimpan data seluruh cabang Cafe Nomad. Digunakan untuk branch picker di home screen dan ditampilkan pada header cart. Hanya cabang dengan `is_open: true` yang bisa dipilih pengguna.

| Kolom | Keterangan |
|-------|------------|
| `id` | Primary key, identitas unik setiap cabang |
| `name` | Nama cabang cafe |
| `location` | Lokasi umum cabang |
| `address` | Alamat lengkap (ditampilkan di branch picker & cart header) |
| `phone` | Nomor telepon cabang |
| `is_open` | Status operasional — hanya `true` yang bisa dipilih user |
| `open_time` | Jam buka cabang |
| `close_time` | Jam tutup cabang |
| `image_url` | URL foto cabang |
| `created_at` | Waktu data dibuat (auto-generated) |

---

### 🏷️ Tabel `categories`
Mengelompokkan menu ke dalam kategori. Di home screen, hanya kategori `drink`, `snack`, `food`, dan `dessert` yang ditampilkan di section *Browse Categories*.

| Kolom | Keterangan |
|-------|------------|
| `id` | Primary key |
| `name` | Nama kategori |
| `icon` | Ikon kategori untuk tampilan UI |
| `created_at` | Waktu data dibuat |

---

### 🍽️ Tabel `menu_items`
Menyimpan seluruh menu yang tersedia. Menu dengan `is_featured: true` muncul di grid *Popular Nomads* pada home screen. Menu dengan `is_available: false` menampilkan overlay "Tidak Tersedia" dan tidak bisa ditambahkan ke cart.

| Kolom | Keterangan |
|-------|------------|
| `id` | Primary key |
| `category_id` | FK → `categories` |
| `branch_id` | FK → `branches` — menu tampil sesuai cabang yang dipilih |
| `created_by` | FK → `users` (admin yang menambahkan) |
| `name` | Nama menu |
| `description` | Deskripsi singkat |
| `price` | Harga menu |
| `image_url` | URL gambar (mendukung URL remote & path aset lokal) |
| `is_available` | Jika `false`, kartu menu non-interaktif dengan overlay merah |
| `is_featured` | Menu unggulan di grid home screen |
| `order_count` | Counter total pemesanan untuk analisis popularitas |
| `created_at` | Waktu data dibuat |
| `updated_at` | Waktu terakhir data diperbarui |

---

### 🛒 Tabel `orders`
Data utama setiap transaksi. Menjadi pusat relasi dengan tabel `users`, `branches`, `vouchers`, dan `order_items`. Field `points_used` dibatasi maksimal 10% dari subtotal oleh logika bisnis di controller.

| Kolom | Keterangan |
|-------|------------|
| `id` | Primary key |
| `user_id` | FK → `users` |
| `branch_id` | FK → `branches` |
| `voucher_id` | FK → `vouchers` (nullable) |
| `queue_number` | Nomor antrean yang dibuat otomatis setelah checkout |
| `payment_method` | Metode pembayaran (`cash` / `non-cash`) |
| `status` | Status pesanan (`pending` / `confirmed` / `done`) |
| `order_type` | Jenis pesanan (`dine-in` / `take-away`) |
| `subtotal` | Total harga sebelum diskon |
| `discount_amount` | Potongan dari voucher/promo |
| `service_fee` | Biaya tambahan layanan |
| `grand_total` | Total akhir yang dibayar |
| `points_earned` | Poin yang didapat dari transaksi ini |
| `points_used` | Poin yang digunakan; maks. 10% dari subtotal |
| `is_reward_redeem` | Penanda pesanan merupakan penukaran reward menu |
| `reward_menu_item_id` | FK → `menu_items` untuk reward (nullable) |
| `voucher_code` | Snapshot kode voucher yang digunakan |
| `notes` | Catatan tambahan pesanan |
| `created_at` | Waktu pesanan dibuat |
| `updated_at` | Waktu terakhir data diperbarui |

---

### 📦 Tabel `order_items`
Detail item dari setiap pesanan. Menyimpan `menu_name_snapshot` untuk menjaga konsistensi data historis meskipun nama menu berubah di kemudian hari.

| Kolom | Keterangan |
|-------|------------|
| `id` | Primary key |
| `order_id` | FK → `orders` |
| `menu_item_id` | FK → `menu_items` |
| `quantity` | Jumlah item yang dipesan |
| `price` | Harga satuan saat dipesan (snapshot harga) |
| `subtotal` | `quantity × price` |
| `menu_name_snapshot` | Nama menu saat transaksi — tidak terpengaruh jika nama menu diubah admin |
| `notes` | Catatan khusus per item (misal: tanpa es, gula setengah) |

---

### 👤 Tabel `users`
Data seluruh pengguna aplikasi beserta sistem loyalty. Field `total_earned_points` tidak pernah berkurang meskipun poin digunakan — dipakai sebagai acuan kenaikan tier.

| Kolom | Keterangan |
|-------|------------|
| `id` | Primary key |
| `auth_id` | UUID dari Supabase Auth |
| `name` | Nama lengkap |
| `email` | Email untuk login |
| `phone` | Nomor telepon |
| `role` | Peran dalam sistem (`user` / `admin`) |
| `loyalty_points` | Poin aktif yang bisa digunakan saat ini |
| `total_earned_points` | Akumulasi total poin — acuan naik tier, tidak berkurang saat poin dipakai |
| `membership_tier` | Tier aktif (`bronze` / `silver` / `gold` / `platinum`) |
| `created_at` | Waktu akun dibuat |

**Aturan naik tier berdasarkan `total_earned_points`:**

| Tier | Threshold |
|------|:---------:|
| 🥉 Bronze | 0 – 99 pts |
| 🥈 Silver | 100 – 299 pts |
| 🥇 Gold | 300 – 799 pts |
| 💎 Platinum | 800+ pts |

---

### 🎟️ Tabel `vouchers`
Data seluruh voucher yang tersedia. Admin dapat mengatur minimal belanja, batas total pemakaian, dan batas pemakaian per user.

| Kolom | Keterangan |
|-------|------------|
| `id` | Primary key |
| `created_by` | FK → `users` (admin) |
| `code` | Kode unik voucher |
| `name` | Nama voucher |
| `type` | Jenis diskon (persentase / nominal tetap) |
| `discount_value` | Nilai diskon |
| `max_discount` | Batas maksimal potongan untuk voucher persentase |
| `min_order_value` | Minimal subtotal agar voucher bisa digunakan |
| `usage_limit` | Batas total pemakaian oleh semua user |
| `used_count` | Jumlah pemakaian saat ini |
| `usage_per_user` | Batas pemakaian per akun |
| `start_date` | Tanggal mulai berlaku |
| `expiry_date` | Tanggal kadaluarsa |
| `is_active` | Status aktif/nonaktif |

---

### 📜 Tabel `voucher_usages`
Riwayat penggunaan voucher untuk tracking dan validasi batas pemakaian per user.

| Kolom | Keterangan |
|-------|------------|
| `id` | Primary key |
| `voucher_id` | FK → `vouchers` |
| `user_id` | FK → `users` |
| `order_id` | FK → `orders` |
| `used_at` | Waktu voucher digunakan |

---

## 🔒 Keamanan Database (Row Level Security)

Aplikasi menggunakan **RLS Supabase** untuk memastikan setiap pengguna hanya mengakses data yang menjadi haknya.

| Tabel | Public | User (Auth) | Admin |
|-------|:------:|:-----------:|:-----:|
| `branches` | ✅ Read | ✅ Read | ✅ Full CRUD |
| `categories` | ✅ Read | ✅ Read | ✅ Full CRUD |
| `menu_items` | ✅ Read | ✅ Read | ✅ Full CRUD |
| `orders` | ❌ | ✅ Own only | ✅ All + Update status |
| `order_items` | ❌ | ✅ Own only | ✅ All + Update |
| `users` | ❌ | ✅ Own only | ✅ All data |
| `vouchers` | ❌ | ✅ Read (active) | ✅ Full CRUD |
| `voucher_usages` | ❌ | ✅ Own history | ✅ All history |

> Data `voucher_usages` hanya dapat ditambahkan oleh sistem secara otomatis saat transaksi terjadi.

---

## 🧩 Widget yang Digunakan

Widget-widget berikut ditemukan dan diverifikasi langsung dari kode sumber proyek.

### 📐 Layout & Struktur

| Widget | Digunakan Di | Keterangan |
|--------|-------------|------------|
| `Scaffold` | Semua screen | Struktur dasar halaman — menyediakan AppBar, Body, dan BottomNavigationBar |
| `Stack` | `LoginScreen`, `HomeScreen`, `CartScreen` | Menumpuk elemen; dipakai untuk overlay gambar background di login, dan overlay "Tidak Tersedia" di kartu menu |
| `Column` & `Row` | Seluruh aplikasi | Menyusun elemen secara vertikal dan horizontal |
| `Padding` & `SizedBox` | Seluruh aplikasi | Mengatur spacing antar elemen secara konsisten |
| `Expanded` & `ConstrainedBox` | `CartScreen`, `HomeScreen` | `Expanded` membagi ruang sisa; `ConstrainedBox` memastikan `CartItemCard` memiliki tinggi minimum 96px |
| `SafeArea` | `HomeScreen`, `LoyaltyScreen`, `LoginScreen` | Mencegah konten terpotong oleh notch atau system bar |
| `LayoutBuilder` | `LoginScreen` | Mendeteksi tinggi layar untuk menyesuaikan ukuran elemen secara dinamis (compact vs normal) |
| `Positioned` & `Positioned.fill` | `HomeScreen`, `LoginScreen` | Menempatkan widget di posisi absolut dalam `Stack` |

### 🔄 Scrolling & List

| Widget | Digunakan Di | Keterangan |
|--------|-------------|------------|
| `CustomScrollView` + `SliverToBoxAdapter` | `HomeScreen` | Mengizinkan hero section dan konten di bawahnya bergabung dalam satu scroll yang mulus |
| `ListView` & `ListView.builder` | `CartScreen`, `LoyaltyScreen` | Render daftar item keranjang dan reward; `builder` dipakai untuk lazy rendering |
| `GridView.builder` | `HomeScreen` | Grid 2 kolom *Popular Nomads* dengan `mainAxisExtent: 254` dan `NeverScrollableScrollPhysics` (nested dalam `CustomScrollView`) |
| `PageView.builder` | Home promo slider | Carousel promo mingguan dengan `viewportFraction: 0.90` untuk efek peek |
| `SingleChildScrollView` | `LoginScreen`, `RegisterScreen` | Scroll pada halaman form panjang dengan `ClampingScrollPhysics` |

### 🎨 Styling & Visual

| Widget | Digunakan Di | Keterangan |
|--------|-------------|------------|
| `BoxDecoration` | Seluruh aplikasi | Kustomisasi kartu: rounded corner, border, shadow, warna, dan gradient |
| `LinearGradient` | `HomeScreen`, `LoginScreen`, `LoyaltyScreen` | Gradien brand pada hero section dan kartu membership — menggunakan konstanta `AppColors` (`gradientQueue`, `gradientLoyalty`, `gradientPrimarySoft`) |
| `LinearProgressIndicator` | `HomeScreen`, `LoyaltyScreen` | Progress bar tier membership yang dibungkus `ClipRRect` untuk sudut membulat |
| `AnimatedContainer` | Promo dot indicator | Dot aktif melebar animasi 220ms saat halaman carousel berubah |
| `ClipRRect` | `CartScreen`, `LoyaltyScreen`, kartu menu | Memotong gambar dan widget anak dengan `BorderRadius` tertentu |
| `CircleAvatar` | `HomeScreen`, `LoyaltyScreen` | Menampilkan initial huruf pertama nama user di area header |
| `DecoratedBox` | `LoginScreen`, `RegisterScreen` | Wrapper tombol utama dengan gradient + shadow tanpa overhead `Container` penuh |

### ⚡ State & Reaktivitas (GetX)

| Widget / API | Digunakan Di | Keterangan |
|--------|-------------|------------|
| `Obx` | `HomeScreen`, `LoginScreen`, `RegisterScreen`, `LoyaltyScreen` | Rebuild otomatis saat nilai `RxType` berubah — dipakai untuk loading state, toggle visibility password, qty cart, dan list menu reward |
| `GetBuilder` | `CartScreen`, `LoyaltyScreen` | Rebuild manual via `controller.update()` — lebih efisien untuk widget yang tidak butuh reactive granular |
| `Get.bottomSheet` | `HomeScreen` (branch picker), `LoyaltyScreen` (info sheet) | Bottom sheet kustom dengan `isScrollControlled: true` dan background transparan |
| `Get.dialog` | `LoyaltyScreen` (limit redeem) | Dialog konfirmasi limit redeem harian menggunakan `AlertDialog` |
| `Get.snackbar` | Auth & profile flow | Pesan sukses/gagal yang muncul di atas layar |
| `Get.find` / `Get.put` | Seluruh controller | Dependency injection tanpa `BuildContext` |

### 🖱️ Input & Interaksi

| Widget | Digunakan Di | Keterangan |
|--------|-------------|------------|
| `TextFormField` | `LoginScreen`, `RegisterScreen` | Input dengan validasi `Validators`; memiliki style berbeda untuk state focused, enabled, dan error |
| `Form` + `GlobalKey<FormState>` | `LoginScreen`, `RegisterScreen` | Validasi seluruh field secara terpusat sebelum submit |
| `InkWell` | `HomeScreen`, `LoyaltyScreen`, `CartScreen` | Tap handler dengan efek ripple pada kartu menu, tombol kategori, dan item branch picker |
| `GestureDetector` | Tombol delete cart, quick-add menu | Tap handler untuk aksi pada area kecil yang tidak butuh efek ripple |
| `ElevatedButton` | Tombol checkout, login, register | Tombol utama dengan `backgroundColor: Colors.transparent` (warna dihandle `DecoratedBox` di luar) |
| `IconButton` | AppBar back, toggle password | Tombol ikon dengan hit area standar Material (48×48) |
| `Checkbox` | `RegisterScreen` | Persetujuan syarat & ketentuan dengan shape `RoundedRectangleBorder` dan `activeColor: AppColors.primary` |

---

## 📂 Struktur Folder / Package

```
lib/
│
├── main.dart                                  # Entry point aplikasi
│
├── admin/                                     # Modul Admin
│   ├── bindings/                              # Dependency injection per halaman
│   │   ├── admin_binding.dart
│   │   ├── admin_branch_binding.dart
│   │   ├── admin_home_binding.dart
│   │   ├── admin_menu_binding.dart
│   │   ├── admin_order_binding.dart
│   │   └── admin_voucher_binding.dart
│   ├── controllers/                           # Logika bisnis admin
│   │   ├── admin_branch_controller.dart
│   │   ├── admin_home_controller.dart
│   │   ├── admin_menu_controller.dart
│   │   ├── admin_order_controller.dart
│   │   └── admin_voucher_controller.dart
│   ├── core/
│   │   ├── routes/                            # Routing halaman admin
│   │   └── utils/                             # Admin guard & branch scope
│   ├── data/
│   │   ├── datasources/                       # Komunikasi langsung ke Supabase
│   │   ├── models/                            # Model data admin
│   │   └── repositories/                     # Repository pattern
│   └── presentation/
│       ├── screens/
│       │   ├── admin_home_screen.dart
│       │   ├── branch/                        # Form & list cabang
│       │   ├── menu/                          # Form & list menu
│       │   ├── order/                         # Detail & list pesanan
│       │   └── voucher/                       # Form & list voucher
│       └── widgets/
│           └── admin_drawer.dart              # Sidebar navigasi admin
│
└── user/                                      # Modul User (Pelanggan)
    ├── controllers/                           # Logika bisnis user
    │   ├── auth/                              # login_controller, register_controller
    │   ├── cart/                              # cart_controller
    │   ├── home/                              # home_controller, main_controller
    │   ├── loyalty/                           # loyalty_controller
    │   ├── menu/                              # menu_controller, menu_detail_controller
    │   ├── order/                             # order_controller
    │   ├── profile/                           # profile_controller
    │   ├── splash/                            # splash_controller
    │   └── voucher/                           # voucher_controller
    ├── core/
    │   ├── app_state.dart                     # State global: user, branch, session
    │   ├── constants/
    │   │   ├── app_colors.dart                # Palet warna brand & tier gradient
    │   │   └── app_text_styles.dart           # Sistem tipografi (display, heading, body, price, button)
    │   ├── routes/                            # app_pages.dart, app_routes.dart
    │   ├── services/
    │   │   └── supabase_service.dart          # Inisialisasi Supabase client
    │   └── utils/
    │       ├── formatters.dart                # Format currency Rupiah & angka
    │       └── validators.dart                # Validasi email, password, phone, name
    ├── data/
    │   ├── datasources/                       # Komunikasi ke Supabase per domain
    │   │   ├── auth_remote.dart
    │   │   ├── branch_remote.dart
    │   │   ├── loyalty_remote.dart
    │   │   ├── menu_remote.dart
    │   │   ├── order_remote.dart
    │   │   ├── profil_remote.dart
    │   │   └── voucher_remote.dart
    │   ├── models/                            # Data class dengan factory fromMap()
    │   │   ├── branch_model.dart
    │   │   ├── menu_item_model.dart
    │   │   ├── order_model.dart
    │   │   ├── user_model.dart
    │   │   └── voucher_model.dart
    │   └── repositories/                     # Abstraksi antara datasource & controller
    └── presentation/
        └── screens/
            ├── auth/                          # login_screen, register_screen
            ├── cart/                          # cart_screen
            ├── home/                          # home_screen, main_screen
            ├── loyalty/                       # loyalty_screen
            ├── menu/                          # menu_screen, menu_detail_sheet
            ├── order/                         # order_history_screen, order_status_screen
            ├── profile/                       # profile_screen, edit_profile_screen
            ├── voucher/                       # voucher_screen
            └── splash_screen.dart
```

---

## 🧰 Tech Stack

<div align="center">

| Kategori | Teknologi | Versi |
|:--------:|-----------|:-----:|
| **Framework** | [Flutter](https://flutter.dev/) | SDK `^3.10.8` |
| **Language** | Dart | — |
| **State Management** | [GetX](https://pub.dev/packages/get) | `^4.6.6` |
| **Backend & Auth** | [Supabase](https://supabase.com/) | `^2.5.6` |
| **Database** | PostgreSQL (via Supabase) | — |
| **Font** | [Google Fonts](https://pub.dev/packages/google_fonts) | `^6.2.1` |
| **QR Code** | [qr_flutter](https://pub.dev/packages/qr_flutter) | `^4.0.0` |
| **Image Picker** | [image_picker](https://pub.dev/packages/image_picker) | `^1.2.1` |
| **Env Config** | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) | `^5.1.0` |
~
</div>

---

<div align="center">

**Developed with ❤️ for Teh Tarik Nomad © 2024**

*Sistem Informasi A '24 — Universitas Mulawarman*

</div>
