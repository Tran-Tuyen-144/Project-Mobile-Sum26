# Đặt Pet Offline

## Mục đích
Cho phép nhân viên tạo đơn đặt pet trực tiếp cho khách đến quán mà không cần khách đặt trước trên ứng dụng.

## Luồng hoạt động

### Bước 1: Khách đến quán

- Khách yêu cầu được chơi hoặc đặt một pet.
- Nhân viên mở chức năng **Đặt Pet Offline**.

### Bước 2: Hiển thị danh sách Pet

- Hệ thống hiển thị toàn bộ danh sách pet đang có.
- Mỗi pet sẽ hiển thị:
  - Hình ảnh.
  - Tên pet.
  - Trạng thái.

### Bước 3: Kiểm tra trạng thái Pet
Mỗi pet sẽ có một trong hai trạng thái:

**1. Có sẵn (Available)**

- Hiển thị màu xanh hoặc nút "Có thể đặt".
- Nhân viên có thể chọn pet để tạo đơn.

**2. Đã được đặt (Occupied/Booked)**

- Hiển thị màu đỏ hoặc nhãn "Đã có người đặt".
- Không cho phép chọn pet này.
- Có thể hiển thị thêm thời gian dự kiến pet sẽ trống (nếu có).

### Bước 4: Chọn Pet

- Nhân viên chọn một pet có trạng thái **Có sẵn**.
- Nhập thông tin đơn:
  - Tên khách (hoặc SĐT nếu cần).
  - Số bàn.
  - Thời gian sử dụng.
  - Ghi chú (nếu có).

### Bước 5: Xác nhận

- Nhấn nút **Xác nhận đặt**.
- Hệ thống tạo đơn đặt pet offline.
- Trạng thái của pet được cập nhật thành **Đã được đặt** ngay lập tức.

### Bước 6: Kết thúc

- Danh sách pet được làm mới.
- Pet vừa được đặt sẽ hiển thị trạng thái **Đã có người đặt** và không thể được chọn bởi đơn khác cho đến khi kết thúc hoặc hủy đơn.

---

## Quy tắc nghiệp vụ

- Một pet chỉ được phục vụ **một đơn tại một thời điểm**.
- Không cho phép tạo đơn mới với pet đang ở trạng thái **Đã được đặt**.
- Sau khi đơn hoàn thành hoặc bị hủy, trạng thái pet sẽ chuyển lại thành **Có sẵn**.
- Đặt online và đặt offline đều sử dụng chung trạng thái của pet để tránh trùng lịch.
