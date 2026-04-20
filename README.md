### Services
- [x] Source Control & CI/CD: [Gitea](https://about.gitea.com/), [Drone CI](https://www.drone.io/)
- [x] Knowledge-Base/Wiki: [BookStack](https://www.bookstackapp.com/)
- [x] Monitoring & Observability: [Uptime Kuma](https://uptimekuma.org/)
- [x] Database Tools: [Adminer](https://www.adminer.org/en/)
- [x] Dev Tools: [IT Tools](https://it-tools.tech/)
- [x] Network Management: [dnsmasq](https://github.com/howtomgr/dnsmasq), [Nginx Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [ ] Project Management (suggest): [Plane](https://plane.so/)
- [ ] Communication (suggest): [Mattermost](https://mattermost.com/)

### Auto Setup

1. Clone the repository: `git clone https://github.com/ttasc/dockitt.git`
2. Move to the cloned directory: `cd dockitt`
3. Run `./setup.sh`
4. Then follow the instructions.

---

# Manual Setup

**Các thành phần cốt lõi bao gồm:**
*   **Hạ tầng mạng & Điều hướng:** Cụm DNS nội bộ (DNSMasq) và Reverse Proxy (Nginx Proxy Manager).
*   **Quản lý Mã nguồn & Tự động hóa:** Gitea (Git Server) và Drone CI (CI/CD Pipeline).
*   **Quản lý Tri thức & Cơ sở dữ liệu:** BookStack (Wiki/Docs) và Adminer (Database Management).
*   **Giám sát Hệ thống:** Uptime Kuma.
*   **Tiện ích:** IT-Tools.

## 1. YÊU CẦU MÔI TRƯỜNG & CHUẨN BỊ
*   **Hệ điều hành Server:** Lõi Linux (Khuyến nghị: Debian server).
*   **Phần mềm yêu cầu:** `docker`, `docker compose`, `openssl`, `bash`.
*   **Kiến trúc mạng Docker (Được tạo tự động):**
    *   Tên mạng: `dockitt_network`
    *   Lớp mạng (Subnet): `10.0.0.0/24`
    *   Gateway: `10.0.0.1`

## 2. CƠ CHẾ HOẠT ĐỘNG CỦA SCRIPT TRIỂN KHAI
Thay vì cấu hình thủ công từng dịch vụ, quá trình triển khai được tự động hóa qua script `setup.sh`. Script này thực hiện các nhiệm vụ ngầm sau:
1.  **Nhận diện tự động:** Lấy IP của máy chủ vật lý và tên miền mong muốn (Mặc định: `dockitt.local`).
2.  **Đồng bộ Quyền hạn (Permissions):** Tự động lấy User ID (`PUID`) và Group ID (`PGID`) của user Linux hiện hành đẩy vào file `.env` để ngăn chặn triệt để lỗi "Permission Denied" khi Docker ghi dữ liệu ra ổ cứng (Volumes).
3.  **Bảo mật:** Tự động dùng `openssl` để sinh ngẫu nhiên chuỗi bảo mật `DRONE_RPC_SECRET`.
4.  **Phân phối cấu hình:** Tự động sao chép file `.env` tổng vào từng thư mục dịch vụ con.

---

## 3. HƯỚNG DẪN TRIỂN KHAI CHI TIẾT CÁC DỊCH VỤ

Để bắt đầu quá trình cài đặt, quản trị viên cấp quyền thực thi và khởi chạy kịch bản tại thư mục gốc của dự án:
```bash
chmod +x setup.sh
./setup.sh
```

### Bước 3.0: Khởi tạo Thông số Môi trường (Preamble & Step 0)
Ngay khi khởi chạy, kịch bản (script) sẽ yêu cầu quản trị viên xác nhận cấu hình nền tảng.
*   **[THAO TÁC THỦ CÔNG]**: Nhập tên miền nội bộ (Mặc định: `dockitt.local`) và xác nhận địa chỉ IP của máy chủ vật lý.
*   **[HÀNH ĐỘNG CỦA SCRIPT]**:
    1.  Nhân bản file `.env.example.conf` thành file `.env` gốc.
    2.  Tự động quét `User ID (PUID)` và `Group ID (PGID)` của tài khoản Linux hiện hành để ghi đè vào file `.env`, nhằm ngăn chặn lỗi phân quyền đọc/ghi ổ cứng của Docker.
    3.  Tự động sinh một chuỗi mã hóa ngẫu nhiên (16-hex) gán vào biến `DRONE_RPC_SECRET` để bảo mật luồng giao tiếp giữa Drone Server và Drone Runner.
    4.  Cập nhật toàn bộ tên miền trong `.env` theo domain đã nhập.
    5.  Phân phối (sao chép) file `.env` hoàn chỉnh vào từng thư mục dịch vụ con (ví dụ: `gitea/`, `drone/`, `bookstack/`...).

### Bước 3.1: Khởi tạo Mạng nội bộ (Step 1)
*   **[HÀNH ĐỘNG CỦA SCRIPT]**: Tự động kiểm tra và tạo một Virtual Network mang tên `dockitt_network` với dải IP cố định `10.0.0.0/24`. Tất cả container được triển khai sau đó sẽ giao tiếp nội bộ trong vùng mạng cách ly này.

### Bước 3.2: Triển khai Máy chủ Phân giải Tên miền - DNSMasq (Step 2 & 3)
*   **[THAO TÁC THỦ CÔNG]**: Nhấn `Y` khi kịch bản yêu cầu xác nhận triển khai DNSMasq.
*   **[HÀNH ĐỘNG CỦA SCRIPT]**: Ghi đè cấu hình vào file `dnsmasq.conf`, tự động thiết lập quy tắc định tuyến: mọi truy cập đến `*.dockitt.local` sẽ được phân giải về địa chỉ IP của máy chủ vật lý. Khởi động container DNSMasq.

### Bước 3.3: Triển khai Cổng điều phối - Nginx Proxy Manager (Step 4 & 5)
*   **[THAO TÁC THỦ CÔNG 1]**: Nhấn `Y` để xác nhận triển khai NPM.
*   **[HÀNH ĐỘNG CỦA SCRIPT]**: Khởi động container NPM tại các cổng 80, 443 và 81.
*   **[THAO TÁC THỦ CÔNG 2 - BẮT BUỘC]**:
    1. Truy cập trang quản trị NPM tại địa chỉ: `http://<SERVER_IP>:81`
    2. Đăng nhập bằng thông tin mặc định (`admin@example.com` / `changeme`) và thiết lập thông tin Admin mới.
    *Lưu ý: Giữ trạng thái đăng nhập trên trình duyệt để tiếp tục cấu hình cho các dịch vụ tiếp theo.*

### Bước 3.4: Triển khai Tiện ích Lập trình - IT-Tools (Step 6 & 7)
*   **[THAO TÁC THỦ CÔNG 1]**: Nhấn `Y` trên terminal.
*   **[HÀNH ĐỘNG CỦA SCRIPT]**: Khởi động container IT-Tools ở chế độ ngầm trong mạng nội bộ.
*   **[THAO TÁC THỦ CÔNG 2]**: Truy cập giao diện NPM, thêm một Proxy Host mới với các thông số:
    *   Domain Names: `tools.dockitt.local`
    *   Forward Hostname / IP: `it-tools`
    *   Forward Port: `80`
    *   Tùy chọn: Đánh dấu chọn *Block Common Exploits*.

### Bước 3.5: Triển khai Máy chủ Mã nguồn - Gitea (Step 8 - 10)
*   **[THAO TÁC THỦ CÔNG 1]**: Nhấn `Y` trên terminal.
*   **[HÀNH ĐỘNG CỦA SCRIPT]**: Khởi động cụm container Gitea và PostgreSQL.
*   **[THAO TÁC THỦ CÔNG 2]**:
    1. Truy cập NPM và tạo Proxy Host:
       * Domain Names: `git.dockitt.local`
       * Forward Hostname / IP: `gitea`
       * Forward Port: `3000`
    2. Truy cập `http://git.dockitt.local`, cuộn xuống cuối trang cài đặt và khởi tạo tài khoản Administrator.

### Bước 3.6: Triển khai Tự động hóa CI/CD - Drone (Step 11 - 16)
*Tại bước này, kịch bản sẽ hiển thị thông báo yêu cầu cấu hình OAuth2 và tạm dừng chờ xác nhận.*

*   **[THAO TÁC THỦ CÔNG 1 (Xác thực chéo)]**:
    1. Trên giao diện Gitea, truy cập đường dẫn: `Settings -> Applications -> Manage OAuth2 Applications`.
    2. Khởi tạo ứng dụng mới với tên "Drone CI", giá trị Redirect URI thiết lập là `http://drone.dockitt.local/login`.
    3. Sao chép `Client ID` và `Client Secret`.
    4. Mở file `drone/.env` trên máy chủ, gán hai mã trên vào biến `DRONE_GITEA_CLIENT_ID` và `DRONE_GITEA_CLIENT_SECRET`. Lưu tệp tin.
*   **[THAO TÁC THỦ CÔNG 2]**: Quay lại terminal, nhấn `Y` để xác nhận hoàn tất cấu hình OAuth2.
*   **[HÀNH ĐỘNG CỦA SCRIPT]**: Khởi động cụm Drone Server và Drone Runner (được cấp quyền truy cập docker socket).
*   **[THAO TÁC THỦ CÔNG 3]**:
    1. Truy cập NPM và tạo Proxy Host:
       * Domain Names: `drone.dockitt.local`
       * Forward Hostname / IP: `drone`
       * Forward Port: `80`
    2. Truy cập `http://drone.dockitt.local`, chấp nhận yêu cầu ủy quyền thông qua Gitea để hoàn tất liên kết CI/CD.

### Bước 3.7: Triển khai Kho tài liệu - BookStack (Step 17 - 19)
*   **[THAO TÁC THỦ CÔNG 1]**: Nhấn `Y` trên terminal.
*   **[HÀNH ĐỘNG CỦA SCRIPT]**: Khởi động cụm BookStack và MariaDB. Quá trình khởi tạo các bảng dữ liệu (migration) lần đầu cho MariaDB có thể kéo dài từ 15 đến 30 giây.
*   **[THAO TÁC THỦ CÔNG 2]**:
    1. Truy cập NPM và tạo Proxy Host:
       * Domain Names: `docs.dockitt.local`
       * Forward Hostname / IP: `bookstack`
       * Forward Port: `80`
    2. Đăng nhập hệ thống bằng tài khoản mặc định (`admin@admin.com` / `password`).

### Bước 3.8: Triển khai Quản trị Database - Adminer (Step 20 - 22)
*   **[THAO TÁC THỦ CÔNG 1]**: Nhấn `Y` trên terminal.
*   **[HÀNH ĐỘNG CỦA SCRIPT]**: Khởi động container Adminer.
*   **[THAO TÁC THỦ CÔNG 2]**: Truy cập NPM và tạo Proxy Host:
    *   Domain Names: `db.dockitt.local`
    *   Forward Hostname / IP: `adminer`
    *   Forward Port: `8080`

### Bước 3.9: Triển khai Giám sát Hệ thống - Uptime Kuma (Step 23 - 25)
*   **[THAO TÁC THỦ CÔNG 1]**: Nhấn `Y` trên terminal.
*   **[HÀNH ĐỘNG CỦA SCRIPT]**: Khởi động container Uptime Kuma.
*   **[THAO TÁC THỦ CÔNG 2]**:
    1. Truy cập NPM và tạo Proxy Host:
       * Domain Names: `status.dockitt.local`
       * Forward Hostname / IP: `uptime-kuma`
       * Forward Port: `3001`
    2. Truy cập `http://status.dockitt.local`, tạo tài khoản quản trị và bổ sung các Monitor (thiết lập giám sát HTTP đối với các tên miền đã tạo và giám sát phân giải DNS tại địa chỉ IP `10.0.0.5`).

### Bước 3.10: Hoàn tất Triển khai (Step 26)
Khi màn hình terminal hiển thị thông báo **"DEPLOYMENT COMPLETED"**, quy trình cài đặt phía Server chính thức kết thúc. Quản trị viên cần tiến hành cấu hình Card mạng của các thiết bị Client (thiết lập thông số Primary DNS trỏ về Server IP) để bắt đầu sử dụng toàn bộ hệ sinh thái `dockitt.local`.

---

## 4. CẤU HÌNH MÁY KHÁCH
Vì hệ thống sử dụng tên miền nội bộ ảo (`.dockitt.local`), các máy tính (Client) muốn truy cập vào hệ thống này (bao gồm máy của Dev, PM, QA) **không cần** phải chỉnh sửa file `hosts` rườm rà.

Thay vào đó, chỉ cần cấu hình Card mạng (Wi-Fi/Ethernet) của máy Client:
*   Chuyển **Primary DNS Server** trỏ về địa chỉ IP của Máy chủ chứa dự án (Server IP - Giá trị được in ra ở cuối script cài đặt).
*   Từ lúc này, mọi request tới `*.dockitt.local` sẽ được Server phân giải và Nginx Proxy Manager điều hướng mượt mà.
