# PetHub

PetHub là ứng dụng Flutter hỗ trợ quản lý quán café thú cưng, đặt bàn, dịch vụ chăm sóc Pet, cộng đồng khách hàng và công việc nhân viên.

## Thành viên phát triển

Repository:

```text
Tran-Tuyen-144/Project-Mobile-Sum26
```

## Công nghệ sử dụng

- Flutter và Dart
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Google Sign-In
- GoRouter
- SharedPreferences
- Image Picker
- Share Plus

## Chức năng hiện tại

### Khách hàng

- Đăng ký và đăng nhập bằng email
- Đăng nhập Google
- Quên mật khẩu
- Hồ sơ cá nhân
- Tên hiển thị và avatar
- Đăng bài cộng đồng
- Đăng bài ẩn danh
- Thả tim, chỉnh sửa và xóa bài viết
- Đặt bàn và dịch vụ

### Nhân viên

- Màn chọn chức vụ tạm thời
- Bảng công việc theo khung giờ
- Xử lý đơn Café
- Xử lý dịch vụ Spa
- Ghi chú bệnh án
- Cập nhật hình ảnh sau Spa
- Quản lý lịch làm việc của Pet
- Cập nhật sức khỏe Pet
- Giao diện Check-in bằng QR

### Quản lý

- Quản lý doanh thu
- Quản lý đặt bàn
- Quản lý ca làm
- Quản lý nhân viên
- Quản lý danh mục

## Yêu cầu môi trường

Kiểm tra Flutter:

```powershell
flutter --version
flutter doctor -v
```

Cài đặt các thành phần còn thiếu được báo bởi `flutter doctor`.

## Clone dự án

```powershell
git clone https://github.com/Tran-Tuyen-144/Project-Mobile-Sum26.git

cd Project-Mobile-Sum26
```

## Cài dependencies

```powershell
flutter clean
flutter pub get
```

## Chạy ứng dụng

```powershell
flutter run
```

## Cập nhật code mới nhất

Trước khi bắt đầu làm việc:

```powershell
git pull origin main
flutter pub get
```

## Firebase

Dự án đang dùng chung Firebase project của nhóm.

Các file cấu hình đã có trong repository:

```text
lib/firebase_options.dart
android/app/google-services.json
```

Không tự tạo Firebase project mới và không thay package Android.

## Ảnh Cloudinary → Firebase

Ứng dụng không lưu file ảnh vào Firebase Storage. Khi người dùng chọn ảnh từ
thư viện hoặc camera, app upload file lên Cloudinary rồi chỉ lưu `secure_url`
và `public_id` vào Firestore. Vì vậy tất cả máy đang đăng nhập cùng tài khoản
(hoặc đang xem cùng bài cộng đồng) sẽ hiển thị đúng một ảnh từ URL Firestore.

Cloudinary đang dùng unsigned upload preset `pethub_unsigned` của cloud
`kxkbvskv`. Preset phải cho phép upload unsigned và giới hạn định dạng/kích
thước ảnh trong Cloudinary Console. Không đưa API secret vào app Flutter.

Package Android hiện tại:

```text
com.example.pethub_app
```

## Cấu hình Google Sign-In cho máy mới

Mỗi thành viên chạy:

```powershell
cd android
.\gradlew.bat signingReport
```

Tìm:

```text
Variant: debug
SHA1:
SHA-256:
```

Gửi SHA-1 và SHA-256 cho trưởng nhóm để thêm vào:

```text
Firebase Console
→ Project Settings
→ General
→ Android app
→ Add fingerprint
```

Sau khi SHA được thêm, trưởng nhóm tải lại:

```text
google-services.json
```

và thay vào:

```text
android/app/google-services.json
```

Sau đó thành viên chạy lại:

```powershell
flutter clean
flutter pub get
flutter run
```

## Lỗi thường gặp

### Google Sign-In báo ApiException 10

Nguyên nhân thường là SHA-1 của máy chưa được thêm vào Firebase.

### Firestore báo PERMISSION_DENIED

Đây là lỗi quyền Firestore, không phải lỗi sai mật khẩu. Bản app hiện tại vẫn
lưu đặt bàn, sơ đồ bàn, thực đơn và thông báo trên máy để dùng được khi lỗi
này xuất hiện. Để bật đồng bộ Firebase cho toàn nhóm, một thành viên có quyền
với project chạy ở thư mục dự án:

```powershell
firebase login
firebase use pethub-e6a26
firebase deploy --only firestore:rules
```

File rules cần deploy là `firestore.rules`. Sau đó đăng xuất/đăng nhập lại và
khởi động lại ứng dụng. Nếu vẫn lỗi, kiểm tra trong Firebase Console rằng
Authentication đã bật Email/Password và project đang là `pethub-e6a26`.

Không chuyển Firestore sang test mode cho ứng dụng thật; rules hiện tại yêu
cầu người dùng phải đăng nhập. Khi chuẩn bị phát hành, nên giới hạn các quyền
admin bằng Firebase custom claims thay vì cấp quyền chung cho mọi tài khoản.

### No matching client found for package name

Kiểm tra package phải là:

```text
com.example.pethub_app
```

### Cảnh báo deprecated hoặc unchecked API

Đây thường chỉ là warning từ plugin. Nếu ứng dụng vẫn build và cài đặt thành công thì có thể bỏ qua.

## Quy trình push code

Kiểm tra thay đổi:

```powershell
git status
```

Thêm code:

```powershell
git add .
```

Commit:

```powershell
git commit -m "Mô tả nội dung đã làm"
```

Lấy code mới trước khi push:

```powershell
git pull --rebase origin main
```

Push:

```powershell
git push origin main
```

## Lưu ý làm việc nhóm

- Luôn pull trước khi bắt đầu sửa.
- Không sửa đồng thời cùng một file khi chưa thống nhất.
- Không push thư mục `build`.
- Không push file `local.properties`.
- Không push keystore hoặc tài khoản dịch vụ Firebase.
- Không thay đổi package name nếu chưa thống nhất với nhóm.
- Sau khi sửa `pubspec.yaml`, các thành viên phải chạy `flutter pub get`.
