create database QLTTTA
use QLTTTA
/* =============================================================
   0. THI?T L?P CHUNG
============================================================= */
SET ANSI_NULLS ON;-- Bật chuẩn so sánh NULL theo ANSI (NULL không bằng NULL)
SET QUOTED_IDENTIFIER ON;-- Cho phép dùng dấu " " cho tên đối tượng SQL
GO

GO

/* =============================================================
   1. H? TH?NG T�I KHO?N & PH�N QUY?N
============================================================= */

CREATE TABLE Vai_Tro (
    Ma_Vai_Tro INT IDENTITY(1,1) PRIMARY KEY,-- Khóa chính vai trò, tự tăng
    Ten_Vai_Tro NVARCHAR(50) NOT NULL UNIQUE -- Tên vai trò (Admin, Giáo viên, Phụ huynh, Học sinh)
);
GO

CREATE TABLE Ky_Nang (
    Ma_Ky_Nang INT IDENTITY(1,1) PRIMARY KEY,
    Ten_Ky_Nang NVARCHAR(50) NOT NULL UNIQUE
);
GO

CREATE TABLE Loai_Bai_Tap ( -- Danh mục loại bài tập
    Ma_Loai_Bai_Tap INT IDENTITY(1,1) PRIMARY KEY, -- Khóa chính
    Ten_Loai NVARCHAR(50) NOT NULL UNIQUE, -- Ví dụ: BTVN, Quiz, Project
    Mo_Ta NVARCHAR(255) -- Mô tả chi tiết loại bài
);
CREATE TABLE Phan_Loai_Bai_Tap ( -- Phân loại theo mục đích học tập
    Ma_Phan_Loai INT IDENTITY(1,1) PRIMARY KEY, -- Khóa chính
    Ten_Phan_Loai NVARCHAR(50) NOT NULL UNIQUE, -- Luyện tập, Kiểm tra, Ôn tập
    Mo_Ta NVARCHAR(255) -- Mô tả thêm
);

CREATE TABLE Sach_Giao_Trinh (
    Ma_Sach INT IDENTITY(1,1) PRIMARY KEY, -- ID sách
    Ten_Sach NVARCHAR(150) NOT NULL,       -- Ví dụ: Family and Friends 3
    Nha_Xuat_Ban NVARCHAR(100),
    Tac_Gia NVARCHAR(100),
    Phien_Ban NVARCHAR(50),                -- Version / Edition
    Mo_Ta NVARCHAR(MAX)
);

CREATE TABLE Khoa_Hoc (
    Ma_Khoa_Hoc INT IDENTITY(1,1) PRIMARY KEY, -- ID khóa học
    Ten_Khoa_Hoc NVARCHAR(100) NOT NULL,       -- Ví dụ: IELTS Foundation, Kids English
    Cap_Do NVARCHAR(50),                        -- Beginner / Intermediate / Advanced
    Mo_Ta NVARCHAR(MAX),                       -- Mô tả khóa học
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME()   -- Ngày tạo khóa
);

CREATE TABLE Nguoi_Dung (
    Ma_Nguoi_Dung INT IDENTITY(1,1) PRIMARY KEY,-- chạy bắt đầu từ 1 mỗi bản ghi tăng 1
    Ten_Dang_Nhap NVARCHAR(50) NOT NULL UNIQUE, -- NOT NULL nghĩa là bắt buộc nhập, unique là không được trùng, usename đăng nhập, không cho phép 2 tài khoản bị trùng
    Email NVARCHAR(100) NOT NULL UNIQUE, -- Bắt buộc phải nhập, và không được phép trùng
    Mat_Khau_Hash NVARCHAR(255) NOT NULL, -- Bắt buộc phải nhập mật khẩu
    Salt NVARCHAR(255),--Salt là một chuỗi ngẫu nhiên được tạo ra riêng cho từng người dùng, dùng để kết hợp với mật khẩu trước khi băm (hash).
    Ho_Ten NVARCHAR(100) NOT NULL,
    Ma_Vai_Tro INT NOT NULL,-- Khóa ngoại tới bảng vai trò, VD 1. Amin, 2. Giáo viên 3. Phụ Huynh 4. Học SInh
    Anh_Dai_Dien NVARCHAR(255),
    Trang_Thai NVARCHAR(20) NOT NULL CHECK (Trang_Thai IN (N'Hoat_Dong', N'Tam_Khoa', N'Khoa')),-- chỉ cho phép 3 giá trị hoạt động, tạm khóa, khóa
    Lan_Dang_Nhap_Cuoi DATETIME2 NULL,-- Datatime2 là kiểu nâng cấp của Datetime sẽ lưu thời điểm đăng nhập cuối cùng với ngày + giờ chính xác cao
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME(),--Khi INSERT dữ liệu mà không nhập giá trị cho cột Ngay_Tao, SQL Server sẽ:Tự động lấy ngày giờ hiện tại của hệ thống, Độ chính xác tới nano-giây
    Updated_At DATETIME2 DEFAULT SYSDATETIME(), -- Lưu thời điểm bản ghi được cập nhật lần cuối, nếu không Insert thì tự động cập nhật giá trị thời gian hiện tại, dùng để theo dõi chỉnh sửa đồng bộ dữ liệu
    FOREIGN KEY (Ma_Vai_Tro) REFERENCES Vai_Tro(Ma_Vai_Tro)
);
GO

CREATE INDEX IDX_NguoiDung_VaiTro ON Nguoi_Dung(Ma_Vai_Tro);
GO

/* =============================================================
   2. ACTOR PROFILES
============================================================= */

CREATE TABLE Quan_Tri_Vien (
    Ma_Quan_Tri INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Nguoi_Dung INT NOT NULL UNIQUE,
    Phong_Ban NVARCHAR(100),
    FOREIGN KEY (Ma_Nguoi_Dung) REFERENCES Nguoi_Dung(Ma_Nguoi_Dung) ON DELETE CASCADE
);
GO

CREATE TABLE Giao_Vien (
    Ma_Giao_Vien INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Nguoi_Dung INT NOT NULL UNIQUE,
    Chuyen_Mon NVARCHAR(100),
    Quoc_Tich NVARCHAR(50),
    Tieu_Su NVARCHAR(MAX),
    FOREIGN KEY (Ma_Nguoi_Dung) REFERENCES Nguoi_Dung(Ma_Nguoi_Dung) ON DELETE CASCADE
);
GO

CREATE TABLE Phu_Huynh (
    Ma_Phu_Huynh INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Nguoi_Dung INT NOT NULL UNIQUE,
    So_Dien_Thoai NVARCHAR(20),
    Dia_Chi NVARCHAR(MAX),
    FOREIGN KEY (Ma_Nguoi_Dung) REFERENCES Nguoi_Dung(Ma_Nguoi_Dung) ON DELETE CASCADE
);
GO

CREATE TABLE Hoc_Sinh (
    Ma_Hoc_Sinh INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Nguoi_Dung INT NOT NULL UNIQUE,
    Ma_Phu_Huynh INT NULL,
    Ngay_Sinh DATE,
    Diem_Tong_Apos INT DEFAULT 0,
    Updated_At DATETIME2 DEFAULT SYSDATETIME(),

    FOREIGN KEY (Ma_Nguoi_Dung) REFERENCES Nguoi_Dung(Ma_Nguoi_Dung) ON DELETE CASCADE,

    FOREIGN KEY (Ma_Phu_Huynh) REFERENCES Phu_Huynh(Ma_Phu_Huynh)
);
GO

CREATE INDEX IDX_HocSinh_PhuHuynh ON Hoc_Sinh(Ma_Phu_Huynh);
GO

/* =============================================================
   3. L?P H?C & CHUY�N C?N
============================================================= */


CREATE TABLE Lop_Hoc ( -- Bảng lớp học
    Ma_Lop INT IDENTITY(1,1) PRIMARY KEY, -- Khóa chính lớp học
    Ma_Lop_Hien_Thi NVARCHAR(20) UNIQUE, -- Mã lớp hiển thị cho người dùng
    Ma_Khoa_Hoc INT NOT NULL, -- Liên kết khóa học (course)
    Ma_Giao_Vien INT NULL, -- Giáo viên phụ trách lớp
    Lich_Hoc NVARCHAR(255), -- Lịch học (VD: T2-T4 18:00–20:00)
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME(), -- Ngày tạo lớp
    Updated_At DATETIME2 DEFAULT SYSDATETIME(), -- Ngày cập nhật gần nhất
    CONSTRAINT FK_Lop_Hoc_Giao_Vien  FOREIGN KEY (Ma_Giao_Vien)  REFERENCES Giao_Vien(Ma_Giao_Vien) ON DELETE SET NULL, -- Xóa GV → lớp vẫn tồn tại
    CONSTRAINT FK_Lop_Hoc_Khoa_Hoc  FOREIGN KEY (Ma_Khoa_Hoc)  REFERENCES Khoa_Hoc(Ma_Khoa_Hoc) -- Mỗi lớp thuộc 1 khóa học
);

CREATE TABLE Bai_Tap_Goc (
    Ma_Bai_Tap_Goc INT IDENTITY(1,1) PRIMARY KEY, -- ID bài tập gốc
    Tieu_De NVARCHAR(255) NOT NULL,               -- Tên bài tập
    Noi_Dung NVARCHAR(MAX),                       -- Nội dung bài
    Ma_Sach INT NULL,                             -- Nếu bài trong sách
    Ma_Khoa_Hoc INT NULL,                         -- Nếu bài theo khóa
    Don_Vi_Bai NVARCHAR(50),                      -- Unit / Lesson / Chapter
    Trang NVARCHAR(20),                           -- Trang sách (nếu có)
    Ma_Loai_Bai_Tap INT NOT NULL,                 -- Quiz / BTVN / Project
    Ma_Phan_Loai INT NOT NULL,                    -- Luyện tập / Kiểm tra
    FOREIGN KEY (Ma_Sach) REFERENCES Sach_Giao_Trinh(Ma_Sach),
    FOREIGN KEY (Ma_Khoa_Hoc) REFERENCES Khoa_Hoc(Ma_Khoa_Hoc),
    FOREIGN KEY (Ma_Loai_Bai_Tap) REFERENCES Loai_Bai_Tap(Ma_Loai_Bai_Tap),
    FOREIGN KEY (Ma_Phan_Loai) REFERENCES Phan_Loai_Bai_Tap(Ma_Phan_Loai)
);
GO

CREATE TABLE Hoc_Sinh_Lop_Hoc (
    Ma_Hoc_Sinh INT NOT NULL,
    Ma_Lop INT NOT NULL,
    Ngay_Tham_Gia DATE DEFAULT CAST(GETDATE() AS DATE),
    Trang_Thai NVARCHAR(20)
        CHECK (Trang_Thai IN (N'Dang_Hoc', N'Da_Ket_Thuc')),
    PRIMARY KEY (Ma_Hoc_Sinh, Ma_Lop),
    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh) ON DELETE CASCADE,
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop) ON DELETE CASCADE
);
GO
CREATE TABLE Buoi_Hoc (
    Ma_Buoi_Hoc INT IDENTITY(1,1) PRIMARY KEY, -- ID buổi học
    Ma_Lop INT NOT NULL,                       -- Lớp học
    Ngay_Hoc DATE NOT NULL,                    -- Ngày học
    Gio_Bat_Dau TIME NOT NULL,                 -- Giờ bắt đầu
    Gio_Ket_Thuc TIME NOT NULL,                -- Giờ kết thúc
    Ma_Giao_Vien INT NOT NULL,                 -- Giáo viên
    Trang_Thai_Giao_Vien NVARCHAR(20) CHECK (Trang_Thai_Giao_Vien IN (N'Day', N'Nghi', N'Day_Thay')),
    Ghi_Chu NVARCHAR(255),
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop),
    FOREIGN KEY (Ma_Giao_Vien) REFERENCES Giao_Vien(Ma_Giao_Vien),
    CONSTRAINT UQ_BuoiHoc UNIQUE (Ma_Lop, Ngay_Hoc, Gio_Bat_Dau)
);

CREATE TABLE Diem_Danh (
    Ma_Buoi_Hoc INT NOT NULL, -- Gắn với buổi học cụ thể
    Ma_Hoc_Sinh INT NOT NULL, -- Học sinh
    Trang_Thai NVARCHAR(20) CHECK (Trang_Thai IN (N'Co_Mat', N'Vang', N'Muon', N'Co_Phep')),
    PRIMARY KEY (Ma_Buoi_Hoc, Ma_Hoc_Sinh),
    FOREIGN KEY (Ma_Buoi_Hoc) REFERENCES Buoi_Hoc(Ma_Buoi_Hoc) ON DELETE CASCADE,
    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh) ON DELETE CASCADE
);

GO

/* =============================================================
   4. B�O C�O & K? N?NG
============================================================= */

CREATE TABLE Bao_Cao_Bai_Hoc (
    Ma_Bao_Cao INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Hoc_Sinh INT NOT NULL,
    Ma_Giao_Vien INT NOT NULL,
    Tieu_De NVARCHAR(255),
    Ngay_Hoc DATE,
    Tien_Do_Hoan_Thanh INT CHECK (Tien_Do_Hoan_Thanh BETWEEN 0 AND 100),
    Muc_Tieu_Bai_Hoc NVARCHAR(MAX),
    Updated_At DATETIME2 DEFAULT SYSDATETIME(),

    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh) ON DELETE CASCADE,

    FOREIGN KEY (Ma_Giao_Vien) REFERENCES Giao_Vien(Ma_Giao_Vien) ON DELETE NO ACTION  
);
GO



CREATE TABLE Chi_Tiet_Ky_Nang (
    Ma_Bao_Cao INT NOT NULL,
    Ma_Ky_Nang INT NOT NULL,
    Diem_So INT CHECK (Diem_So BETWEEN 0 AND 100),
    Nhan_Xet_Giao_Vien NVARCHAR(MAX),
    PRIMARY KEY (Ma_Bao_Cao, Ma_Ky_Nang),
    FOREIGN KEY (Ma_Bao_Cao) REFERENCES Bao_Cao_Bai_Hoc(Ma_Bao_Cao) ON DELETE CASCADE,
    FOREIGN KEY (Ma_Ky_Nang) REFERENCES Ky_Nang(Ma_Ky_Nang)
);
GO


CREATE TABLE Bai_Tap_Ve_Nha ( -- Thông tin bài tập giáo viên giao
    Ma_Bai_Tap INT IDENTITY(1,1) PRIMARY KEY, -- ID bài tập
    Ma_Lop INT NOT NULL, -- Lớp được giao bài
    Tieu_De NVARCHAR(255) NOT NULL, -- Tiêu đề bài tập
    Noi_Dung NVARCHAR(MAX), -- Nội dung chi tiết
    Ngay_Giao DATETIME2 NOT NULL DEFAULT SYSDATETIME(), -- Ngày giáo viên giao bài
    Han_Nop DATETIME2 NOT NULL, -- Hạn cuối nộp bài
    Ma_Loai_Bai_Tap INT NOT NULL, -- Loại bài tập (FK)
    Ma_Phan_Loai INT NOT NULL, -- Phân loại bài tập (FK)
    Thuong_Apos INT DEFAULT 0, -- Điểm thưởng khi hoàn thành
    Trang_Thai NVARCHAR(20) 
    CHECK (Trang_Thai IN (N'Dang_Mo', N'Dong', N'Huy')) 
    DEFAULT N'Dang_Mo',
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop), -- Liên kết lớp học
    FOREIGN KEY (Ma_Loai_Bai_Tap) REFERENCES Loai_Bai_Tap(Ma_Loai_Bai_Tap), -- Liên kết loại bài
    FOREIGN KEY (Ma_Phan_Loai) REFERENCES Phan_Loai_Bai_Tap(Ma_Phan_Loai) -- Liên kết phân loại
);

GO

CREATE TABLE Bai_Nop_Hoc_Sinh (
    Ma_Bai_Nop INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Bai_Tap INT NOT NULL,
    Ma_Hoc_Sinh INT NOT NULL,
    Ngay_Nop DATETIME2 DEFAULT SYSDATETIME(),
    Duong_Dan_Bai_Lam NVARCHAR(MAX),
    Diem_So DECIMAL(5,2),
    Loi_Phe_Giao_Vien NVARCHAR(MAX),
    Trang_Thai NVARCHAR(20) CHECK (Trang_Thai IN (N'Cho_Cham', N'Da_Cham', N'Can_Lam_Lai')),
    CONSTRAINT UQ_BaiNop UNIQUE (Ma_Bai_Tap, Ma_Hoc_Sinh),
    FOREIGN KEY (Ma_Bai_Tap) REFERENCES Bai_Tap_Ve_Nha(Ma_Bai_Tap) ON DELETE CASCADE,
    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh) ON DELETE CASCADE
);
GO

CREATE TABLE Nhat_Ky_Apos (
    Ma_Log INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Hoc_Sinh INT NOT NULL,
    So_Diem INT,
    Ly_Do NVARCHAR(255),
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME(),
    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh) ON DELETE CASCADE
);
GO

/* =============================================================
   6. TH�NG B�O
============================================================= */

CREATE TABLE Thong_Bao (
    Ma_Thong_Bao INT IDENTITY(1,1) PRIMARY KEY,
    Tieu_De NVARCHAR(255),
    Noi_Dung NVARCHAR(MAX),
    Loai_Thong_Bao NVARCHAR(50),
    Ma_Nguoi_Gui INT NULL,
    Ngay_Gui DATETIME2 DEFAULT SYSDATETIME(),
    FOREIGN KEY (Ma_Nguoi_Gui) REFERENCES Nguoi_Dung(Ma_Nguoi_Dung) ON DELETE SET NULL
);
GO

CREATE TABLE Nguoi_Nhan_Thong_Bao (
    Ma_Thong_Bao INT NOT NULL,
    Ma_Nguoi_Dung INT NOT NULL,
    Da_Doc BIT DEFAULT 0,
    PRIMARY KEY (Ma_Thong_Bao, Ma_Nguoi_Dung),
    FOREIGN KEY (Ma_Thong_Bao) REFERENCES Thong_Bao(Ma_Thong_Bao) ON DELETE CASCADE,
    FOREIGN KEY (Ma_Nguoi_Dung) REFERENCES Nguoi_Dung(Ma_Nguoi_Dung) ON DELETE CASCADE
);
GO

CREATE TABLE Diem_Danh_Giao_Vien (
    Ma_Diem_Danh INT IDENTITY(1,1) PRIMARY KEY, -- ID điểm danh
    Ma_Giao_Vien INT NOT NULL,                  -- Giáo viên
    Ma_Lop INT NOT NULL,                        -- Lớp học
    Ngay_Day DATE NOT NULL,                     -- Ngày dạy
    Trang_Thai NVARCHAR(20) NOT NULL             -- Trạng thái
        CHECK (Trang_Thai IN (N'Co_Mat', N'Vang', N'Muon', N'Nghi_Phep')),
    Ghi_Chu NVARCHAR(255),                      -- Lý do vắng / ghi chú
    Created_At DATETIME2 DEFAULT SYSDATETIME(), -- Ngày tạo
    FOREIGN KEY (Ma_Giao_Vien) REFERENCES Giao_Vien(Ma_Giao_Vien),
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop),
    CONSTRAINT UQ_DiemDanhGV UNIQUE (Ma_Giao_Vien, Ma_Lop, Ngay_Day)
);
CREATE TABLE Lich_Day (
    Ma_Lich INT IDENTITY PRIMARY KEY,
    Ma_Lop INT,
    Thu INT,        -- 2..8
    Gio_Bat_Dau TIME,
    Gio_Ket_Thuc TIME,
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop)
);

CREATE TABLE Loai_Bai_Tap ( -- Danh mục loại bài tập
    Ma_Loai_Bai_Tap INT IDENTITY(1,1) PRIMARY KEY, -- Khóa chính
    Ten_Loai NVARCHAR(50) NOT NULL UNIQUE, -- Ví dụ: BTVN, Quiz, Project
    Mo_Ta NVARCHAR(255) -- Mô tả chi tiết loại bài
);
CREATE TABLE Phan_Loai_Bai_Tap ( -- Phân loại theo mục đích học tập
    Ma_Phan_Loai INT IDENTITY(1,1) PRIMARY KEY, -- Khóa chính
    Ten_Phan_Loai NVARCHAR(50) NOT NULL UNIQUE, -- Luyện tập, Kiểm tra, Ôn tập
    Mo_Ta NVARCHAR(255) -- Mô tả thêm
);
CREATE TABLE Hoc_Phi ( 
    Ma_Hoc_Phi INT IDENTITY(1,1) PRIMARY KEY, -- ID học phí
    Ma_Hoc_Sinh INT NOT NULL, -- Học sinh phải đóng
    Ma_Lop INT NOT NULL, -- Lớp học áp dụng
    Ky_Hoc NVARCHAR(20) NOT NULL, -- Ví dụ: 2024-2025_HK1
    So_Tien DECIMAL(12,2) NOT NULL, -- Tổng học phí
    Han_Dong DATETIME2 NOT NULL, -- Hạn đóng học phí
    Trang_Thai NVARCHAR(20) NOT NULL 
        CHECK (Trang_Thai IN (N'Chua_Dong', N'Dong_Mot_Phan', N'Da_Dong')), -- Trạng thái
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME(), -- Ngày tạo học phí
    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh),
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop),
    CONSTRAINT UQ_HocPhi UNIQUE (Ma_Hoc_Sinh, Ma_Lop, Ky_Hoc) -- 1 học kỳ chỉ có 1 học phí
);
GO

GO
CREATE TABLE Thanh_Toan (
    Ma_Thanh_Toan INT IDENTITY(1,1) PRIMARY KEY, -- ID giao dịch
    Ma_Hoc_Phi INT NOT NULL, -- Thuộc học phí nào
    Ma_Phu_Huynh INT NOT NULL, -- Người thanh toán
    So_Tien DECIMAL(12,2) NOT NULL, -- Số tiền đã trả
    Phuong_Thuc NVARCHAR(50), -- Tiền mặt / Chuyển khoản / Online
    Thoi_Diem DATETIME2 DEFAULT SYSDATETIME(), -- Thời điểm thanh toán
    Ghi_Chu NVARCHAR(255), -- Ghi chú thêm
    FOREIGN KEY (Ma_Hoc_Phi) REFERENCES Hoc_Phi(Ma_Hoc_Phi) ON DELETE CASCADE,
    FOREIGN KEY (Ma_Phu_Huynh) REFERENCES Phu_Huynh(Ma_Phu_Huynh)
);
GO

CREATE TABLE Cong_No (
    Ma_Cong_No INT IDENTITY(1,1) PRIMARY KEY, -- ID công nợ
    Ma_Hoc_Phi INT NOT NULL UNIQUE, -- Mỗi học phí có 1 công nợ
    So_Tien_Phai_Dong DECIMAL(12,2) NOT NULL, -- Tổng phải đóng
    So_Tien_Da_Dong DECIMAL(12,2) DEFAULT 0, -- Đã đóng
    So_Tien_Con_No AS (So_Tien_Phai_Dong - So_Tien_Da_Dong), -- Còn nợ (computed)
    Updated_At DATETIME2 DEFAULT SYSDATETIME(), -- Cập nhật gần nhất
    FOREIGN KEY (Ma_Hoc_Phi) REFERENCES Hoc_Phi(Ma_Hoc_Phi) ON DELETE CASCADE
);
GO
CREATE TABLE Bao_Cao_Phu_Huynh (
    Ma_Bao_Cao INT IDENTITY(1,1) PRIMARY KEY, -- ID báo cáo
    Ma_Hoc_Sinh INT NOT NULL, -- Học sinh
    Ma_Phu_Huynh INT NOT NULL, -- Phụ huynh nhận báo cáo
    Thang INT NOT NULL CHECK (Thang BETWEEN 1 AND 12), -- Tháng báo cáo
    Nam INT NOT NULL, -- Năm báo cáo
    Nhan_Xet_Giao_Vien NVARCHAR(MAX), -- Nhận xét chung
    Tien_Do_Hoc_Tap NVARCHAR(255), -- Đánh giá tổng quát
    So_Buoi_Vang INT DEFAULT 0, -- Số buổi vắng
    Tong_Diem_Apos INT DEFAULT 0, -- Tổng điểm thưởng
    Tinh_Trang_Hoc_Phi NVARCHAR(100), -- Đã đóng / còn nợ
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME(), -- Ngày tạo báo cáo
    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh),
    FOREIGN KEY (Ma_Phu_Huynh) REFERENCES Phu_Huynh(Ma_Phu_Huynh),
    CONSTRAINT UQ_BaoCaoPH UNIQUE (Ma_Hoc_Sinh, Thang, Nam) -- 1 tháng 1 báo cáo
);
GO


