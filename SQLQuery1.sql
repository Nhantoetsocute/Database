CREATE DATABASE QLTTTA;
GO
USE QLTTTA;
GO

/* =============================================================
   0. THIẾT LẬP CHUNG
============================================================= */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =============================================================
   1. HỆ THỐNG DANH MỤC & TÀI KHOẢN
============================================================= */

CREATE TABLE Vai_Tro (
    Ma_Vai_Tro INT IDENTITY(1,1) PRIMARY KEY,
    Ten_Vai_Tro NVARCHAR(50) NOT NULL UNIQUE 
);

CREATE TABLE Ky_Nang (
    Ma_Ky_Nang INT IDENTITY(1,1) PRIMARY KEY,
    Ten_Ky_Nang NVARCHAR(50) NOT NULL UNIQUE
);

-- CẬP NHẬT: Tích hợp thuộc tính phân loại vào đây
CREATE TABLE Loai_Bai_Tap (
    Ma_Loai_Bai_Tap INT IDENTITY(1,1) PRIMARY KEY,
    Ten_Loai NVARCHAR(50) NOT NULL UNIQUE, -- Ví dụ: Quiz, Homework, Mid-term
    Mo_Ta NVARCHAR(255),
    Nhom_Phan_Loai NVARCHAR(50) DEFAULT N'Luyen_Tap', -- Kiem_Tra, Luyen_Tap, Nang_Cao
    Yeu_Cau_Cham_Diem BIT DEFAULT 1,                -- 1: Cần GV chấm, 0: Tự động
    Diem_Apos_Goi_Y INT DEFAULT 10                  -- Điểm thưởng gợi ý khi giao loại bài này
);

CREATE TABLE Sach_Giao_Trinh (
    Ma_Sach INT IDENTITY(1,1) PRIMARY KEY,
    Ten_Sach NVARCHAR(150) NOT NULL,
    Nha_Xuat_Ban NVARCHAR(100),
    Tac_Gia NVARCHAR(100),
    Phien_Ban NVARCHAR(50),
    Mo_Ta NVARCHAR(MAX)
);

CREATE TABLE Khoa_Hoc (
    Ma_Khoa_Hoc INT IDENTITY(1,1) PRIMARY KEY,
    Ten_Khoa_Hoc NVARCHAR(100) NOT NULL,
    Cap_Do NVARCHAR(50), -- Beginner, IELTS, etc.
    Mo_Ta NVARCHAR(MAX),
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME()
);

CREATE TABLE Nguoi_Dung (
    Ma_Nguoi_Dung INT IDENTITY(1,1) PRIMARY KEY,
    Ten_Dang_Nhap NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Mat_Khau_Hash NVARCHAR(255) NOT NULL,
    Salt NVARCHAR(255),
    Ho_Ten NVARCHAR(100) NOT NULL,
    Ma_Vai_Tro INT NOT NULL,
    Anh_Dai_Dien NVARCHAR(255),
    Trang_Thai NVARCHAR(20) NOT NULL CHECK (Trang_Thai IN (N'Hoat_Dong', N'Tam_Khoa', N'Khoa')),
    Lan_Dang_Nhap_Cuoi DATETIME2 NULL,
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME(),
    Updated_At DATETIME2 DEFAULT SYSDATETIME(),
    FOREIGN KEY (Ma_Vai_Tro) REFERENCES Vai_Tro(Ma_Vai_Tro)
);
GO

CREATE INDEX IDX_NguoiDung_VaiTro ON Nguoi_Dung(Ma_Vai_Tro);
GO

/* =============================================================
   2. HỒ SƠ CHI TIẾT (ACTOR PROFILES)
============================================================= */

CREATE TABLE Quan_Tri_Vien (
    Ma_Quan_Tri INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Nguoi_Dung INT NOT NULL UNIQUE,
    Phong_Ban NVARCHAR(100),
    FOREIGN KEY (Ma_Nguoi_Dung) REFERENCES Nguoi_Dung(Ma_Nguoi_Dung) ON DELETE CASCADE
);

CREATE TABLE Giao_Vien (
    Ma_Giao_Vien INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Nguoi_Dung INT NOT NULL UNIQUE,
    Chuyen_Mon NVARCHAR(100),
    Quoc_Tich NVARCHAR(50),
    Tieu_Su NVARCHAR(MAX),
    FOREIGN KEY (Ma_Nguoi_Dung) REFERENCES Nguoi_Dung(Ma_Nguoi_Dung) ON DELETE CASCADE
);

CREATE TABLE Phu_Huynh (
    Ma_Phu_Huynh INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Nguoi_Dung INT NOT NULL UNIQUE,
    So_Dien_Thoai NVARCHAR(20),
    Dia_Chi NVARCHAR(MAX),
    FOREIGN KEY (Ma_Nguoi_Dung) REFERENCES Nguoi_Dung(Ma_Nguoi_Dung) ON DELETE CASCADE
);

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

/* =============================================================
   3. LỚP HỌC & NGÂN HÀNG ĐỀ
============================================================= */

CREATE TABLE Lop_Hoc (
    Ma_Lop INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Lop_Hien_Thi NVARCHAR(20) UNIQUE,
    Ma_Khoa_Hoc INT NOT NULL,
    Ma_Giao_Vien INT NULL,
    Lich_Hoc NVARCHAR(255),
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME(),
    Updated_At DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Lop_Hoc_Giao_Vien FOREIGN KEY (Ma_Giao_Vien) REFERENCES Giao_Vien(Ma_Giao_Vien) ON DELETE SET NULL,
    CONSTRAINT FK_Lop_Hoc_Khoa_Hoc FOREIGN KEY (Ma_Khoa_Hoc) REFERENCES Khoa_Hoc(Ma_Khoa_Hoc)
);

-- CẬP NHẬT: Thêm Độ khó và Thời gian làm bài trực tiếp vào Ngân hàng đề
CREATE TABLE Bai_Tap_Goc (
    Ma_Bai_Tap_Goc INT IDENTITY(1,1) PRIMARY KEY,
    Tieu_De NVARCHAR(255) NOT NULL,
    Noi_Dung NVARCHAR(MAX),
    Ma_Sach INT NULL,
    Ma_Khoa_Hoc INT NULL,
    Don_Vi_Bai NVARCHAR(50),
    Trang NVARCHAR(20),
    Link NVARCHAR(500),
    Ma_Loai_Bai_Tap INT NOT NULL, -- Chỉ còn liên kết duy nhất tới bảng loại bài tập đã nâng cấp
    Do_Kho NVARCHAR(20) CHECK (Do_Kho IN (N'De', N'Trung_Binh', N'Kho', N'Rat_Kho')) DEFAULT N'Trung_Binh',
    Thoi_Gian_Lam_Bai_Phut INT DEFAULT 30,
    Trang_Thai NVARCHAR(20) CHECK (Trang_Thai IN (N'Hoat_Dong', N'An')) DEFAULT N'Hoat_Dong',
    FOREIGN KEY (Ma_Sach) REFERENCES Sach_Giao_Trinh(Ma_Sach),
    FOREIGN KEY (Ma_Khoa_Hoc) REFERENCES Khoa_Hoc(Ma_Khoa_Hoc),
    FOREIGN KEY (Ma_Loai_Bai_Tap) REFERENCES Loai_Bai_Tap(Ma_Loai_Bai_Tap)
);

CREATE TABLE Hoc_Sinh_Lop_Hoc (
    Ma_Hoc_Sinh INT NOT NULL,
    Ma_Lop INT NOT NULL,
    Ngay_Tham_Gia DATE DEFAULT CAST(GETDATE() AS DATE),
    Trang_Thai NVARCHAR(20) CHECK (Trang_Thai IN (N'Dang_Hoc', N'Da_Ket_Thuc')),
    PRIMARY KEY (Ma_Hoc_Sinh, Ma_Lop),
    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh) ON DELETE CASCADE,
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop) ON DELETE CASCADE
);

CREATE TABLE Buoi_Hoc (
    Ma_Buoi_Hoc INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Lop INT NOT NULL,
    Ngay_Hoc DATE NOT NULL,
    Gio_Bat_Dau TIME NOT NULL,
    Gio_Ket_Thuc TIME NOT NULL,
    Ma_Giao_Vien INT NOT NULL,
    Trang_Thai_Giao_Vien NVARCHAR(20) CHECK (Trang_Thai_Giao_Vien IN (N'Day', N'Nghi', N'Day_Thay')),
    Ghi_Chu NVARCHAR(255),
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop),
    FOREIGN KEY (Ma_Giao_Vien) REFERENCES Giao_Vien(Ma_Giao_Vien),
    CONSTRAINT UQ_BuoiHoc UNIQUE (Ma_Lop, Ngay_Hoc, Gio_Bat_Dau)
);

CREATE TABLE Diem_Danh (
    Ma_Buoi_Hoc INT NOT NULL,
    Ma_Hoc_Sinh INT NOT NULL,
    Trang_Thai NVARCHAR(20) CHECK (Trang_Thai IN (N'Co_Mat', N'Vang', N'Muon', N'Co_Phep')),
    PRIMARY KEY (Ma_Buoi_Hoc, Ma_Hoc_Sinh),
    FOREIGN KEY (Ma_Buoi_Hoc) REFERENCES Buoi_Hoc(Ma_Buoi_Hoc) ON DELETE CASCADE,
    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh) ON DELETE CASCADE
);

/* =============================================================
   4. BÁO CÁO & BÀI TẬP
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

CREATE TABLE Chi_Tiet_Ky_Nang (
    Ma_Bao_Cao INT NOT NULL,
    Ma_Ky_Nang INT NOT NULL,
    Diem_So INT CHECK (Diem_So BETWEEN 0 AND 100),
    Nhan_Xet_Giao_Vien NVARCHAR(MAX),
    PRIMARY KEY (Ma_Bao_Cao, Ma_Ky_Nang),
    FOREIGN KEY (Ma_Bao_Cao) REFERENCES Bao_Cao_Bai_Hoc(Ma_Bao_Cao) ON DELETE CASCADE,
    FOREIGN KEY (Ma_Ky_Nang) REFERENCES Ky_Nang(Ma_Ky_Nang)
);

CREATE TABLE Bai_Tap_Ve_Nha (
    Ma_Bai_Tap INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Bai_Tap_Goc INT NOT NULL,
    Ma_Lop INT NOT NULL,
    Ngay_Giao DATETIME2 DEFAULT SYSDATETIME(),
    Han_Nop DATETIME2 NOT NULL,
    Thuong_Apos INT DEFAULT 0,
    Trang_Thai NVARCHAR(20) CHECK (Trang_Thai IN (N'Dang_Mo', N'Dong', N'Huy')) DEFAULT N'Dang_Mo',
    FOREIGN KEY (Ma_Bai_Tap_Goc) REFERENCES Bai_Tap_Goc(Ma_Bai_Tap_Goc),
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop)
);

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

CREATE TABLE Nhat_Ky_Apos (
    Ma_Log INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Hoc_Sinh INT NOT NULL,
    So_Diem INT,
    Ly_Do NVARCHAR(255),
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME(),
    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh) ON DELETE CASCADE
);

/* =============================================================
   6. THÔNG BÁO & LỊCH TRÌNH KHÁC
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

CREATE TABLE Nguoi_Nhan_Thong_Bao (
    Ma_Thong_Bao INT NOT NULL,
    Ma_Nguoi_Dung INT NOT NULL,
    Da_Doc BIT DEFAULT 0,
    PRIMARY KEY (Ma_Thong_Bao, Ma_Nguoi_Dung),
    FOREIGN KEY (Ma_Thong_Bao) REFERENCES Thong_Bao(Ma_Thong_Bao) ON DELETE CASCADE,
    FOREIGN KEY (Ma_Nguoi_Dung) REFERENCES Nguoi_Dung(Ma_Nguoi_Dung) ON DELETE CASCADE
);

CREATE TABLE Diem_Danh_Giao_Vien (
    Ma_Diem_Danh INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Giao_Vien INT NOT NULL,
    Ma_Lop INT NOT NULL,
    Ngay_Day DATE NOT NULL,
    Trang_Thai NVARCHAR(20) NOT NULL CHECK (Trang_Thai IN (N'Co_Mat', N'Vang', N'Muon', N'Nghi_Phep')),
    Ghi_Chu NVARCHAR(255),
    Created_At DATETIME2 DEFAULT SYSDATETIME(),
    FOREIGN KEY (Ma_Giao_Vien) REFERENCES Giao_Vien(Ma_Giao_Vien),
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop),
    CONSTRAINT UQ_DiemDanhGV UNIQUE (Ma_Giao_Vien, Ma_Lop, Ngay_Day)
);

CREATE TABLE Lich_Day (
    Ma_Lich INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Lop INT,
    Thu INT,
    Gio_Bat_Dau TIME,
    Gio_Ket_Thuc TIME,
    FOREIGN KEY (Ma_Lop) REFERENCES Lop_Hoc(Ma_Lop)
);

CREATE TABLE Bao_Cao_Phu_Huynh (
    Ma_Bao_Cao INT IDENTITY(1,1) PRIMARY KEY,
    Ma_Hoc_Sinh INT NOT NULL,
    Ma_Phu_Huynh INT NOT NULL,
    Thang INT NOT NULL CHECK (Thang BETWEEN 1 AND 12),
    Nam INT NOT NULL,
    Nhan_Xet_Giao_Vien NVARCHAR(MAX),
    Tien_Do_Hoc_Tap NVARCHAR(255),
    So_Buoi_Vang INT DEFAULT 0,
    Tong_Diem_Apos INT DEFAULT 0,
    Tinh_Trang_Hoc_Phi NVARCHAR(100),
    Ngay_Tao DATETIME2 DEFAULT SYSDATETIME(),
    FOREIGN KEY (Ma_Hoc_Sinh) REFERENCES Hoc_Sinh(Ma_Hoc_Sinh),
    FOREIGN KEY (Ma_Phu_Huynh) REFERENCES Phu_Huynh(Ma_Phu_Huynh),
    CONSTRAINT UQ_BaoCaoPH UNIQUE (Ma_Hoc_Sinh, Thang, Nam)
);
GO