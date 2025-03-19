CREATE DATABASE QL_BV;
GO
USE QL_BV;
GO

DROP TABLE HoSoDieuTri;
DROP TABLE ChamSocBenhNhan;
DROP TABLE KeDon;
DROP TABLE BenhNhan;
DROP TABLE YTa;
DROP TABLE BacSi;
DROP TABLE ThuocVatTu;
DROP TABLE ChuyenKhoa;

-- Bảng Chuyên khoa
CREATE TABLE ChuyenKhoa (
    MaChuyenKhoa INT PRIMARY KEY,
    TenChuyenKhoa NVARCHAR(100)
);
GO

-- Bảng Bác sĩ
CREATE TABLE BacSi (
    MaBacSi INT PRIMARY KEY,
    HoTen NVARCHAR(100),
    DiaChi NVARCHAR(255),
    SoDienThoai NVARCHAR(15),
    MaChuyenKhoa INT,
    FOREIGN KEY (MaChuyenKhoa) REFERENCES ChuyenKhoa(MaChuyenKhoa)
);
GO

-- Bảng Bệnh nhân
CREATE TABLE BenhNhan (
    MaBenhNhan INT PRIMARY KEY,
    HoTen NVARCHAR(100),
    DiaChi NVARCHAR(255),
    SoCMND_CCCD NVARCHAR(20),
    NgayNhapVien DATE,
    MaBacSi INT,
    FOREIGN KEY (MaBacSi) REFERENCES BacSi(MaBacSi)
);
GO

-- Bảng Hồ sơ điều trị
CREATE TABLE HoSoDieuTri (
    MaHoSoDieuTri INT PRIMARY KEY,
    NgayDieuTri DATE,
    ChanDoan NVARCHAR(255),
    MaBenhNhan INT,
    MaBacSi INT,
    FOREIGN KEY (MaBenhNhan) REFERENCES BenhNhan(MaBenhNhan),
    FOREIGN KEY (MaBacSi) REFERENCES BacSi(MaBacSi)
);
GO

-- Bảng Y tá
CREATE TABLE YTa (
    MaYTa INT PRIMARY KEY,
    HoTen NVARCHAR(100),
    DiaChi NVARCHAR(255),
    SoDienThoai VARCHAR(15)
);
GO

-- Bảng Chăm sóc bệnh nhân
CREATE TABLE ChamSocBenhNhan (
    MaChamSoc INT PRIMARY KEY,
    NgayChamSoc DATE,
    NoiDungChamSoc NVARCHAR(255),
    MaYTa INT,
    MaBenhNhan INT,
    FOREIGN KEY (MaYTa) REFERENCES YTa(MaYTa),
    FOREIGN KEY (MaBenhNhan) REFERENCES BenhNhan(MaBenhNhan)
);
GO

-- Bảng Thuốc và vật tư y tế
CREATE TABLE ThuocVatTu (
    MaThuocVatTu INT PRIMARY KEY,
    TenThuocVatTu NVARCHAR(255),
    Loai NVARCHAR(50)
);
GO

-- Bảng Kê đơn thuốc/vật tư
CREATE TABLE KeDon (
    MaThuocVatTu INT,
    MaBenhNhan INT,
    PRIMARY KEY (MaThuocVatTu, MaBenhNhan),
    FOREIGN KEY (MaThuocVatTu) REFERENCES ThuocVatTu(MaThuocVatTu),
    FOREIGN KEY (MaBenhNhan) REFERENCES BenhNhan(MaBenhNhan)
);
GO

-- Chèn dữ liệu (INSERT)
-- Thêm dữ liệu vào bảng ChuyenKhoa
INSERT INTO ChuyenKhoa (MaChuyenKhoa, TenChuyenKhoa) VALUES 
(1, N'Nội tổng quát'),
(2, N'Ngoại thần kinh'),
(3, N'Tim mạch'),
(4, N'Nhi khoa'),
(5, N'Da liễu'),
(6, N'Tiêu hóa');
GO

-- Thêm dữ liệu vào bảng BacSi
INSERT INTO BacSi (MaBacSi, HoTen, DiaChi, SoDienThoai, MaChuyenKhoa) VALUES 
(11, N'Lý Khánh', N'Hà Nội', '0398740501', 1),
(21, N'Minh Quân', N'TP HCM', '0976543210', 2),
(31, N'Minh Tuệ', N'Đà Nẵng', '0965432109', 3),
(41, N'Văn Minh', N'Cần Thơ', '0923456789', 4),
(51, N'Văn Thường', N'Huế', '0912345678', 5),
(61, N'Tự Nghiệp', N'Hải Phòng', '0909876543', 6);
GO

-- Thêm dữ liệu vào bảng BenhNhan
INSERT INTO BenhNhan (MaBenhNhan, HoTen, DiaChi, SoCMND_CCCD, NgayNhapVien, MaBacSi) VALUES 
(101, N'Đình Quang', N'Hà Nội', '123456789', '2025-03-01', 11),
(102, N'Lai Hiệp', N'TP HCM', '234567890', '2025-03-02', 21),
(103, N'Văn Khoa', N'Đà Nẵng', '345678901', '2025-03-03', 31),
(104, N'Văn Xanh', N'Cần Thơ', '456789012', '2025-03-04', 41),
(105, N'Minh Quang', N'Huế', '567890123', '2025-03-05', 51),
(106, N'Minh Hoàng', N'Hải Phòng', '678901234', '2025-03-06', 61);
GO

-- Thêm dữ liệu vào bảng HoSoDieuTri
INSERT INTO HoSoDieuTri (MaHoSoDieuTri, NgayDieuTri, ChanDoan, MaBenhNhan, MaBacSi) VALUES 
(10, '2025-03-13', N'Cảm cúm', 101, 11),
(12, '2025-03-14', N'Đau đầu', 102, 21),
(13, '2025-03-11', N'Huyết áp cao', 103, 31),
(14, '2025-03-15', N'Viêm phổi', 104, 41),
(15, '2025-03-16', N'Dị ứng da', 105, 51),
(16, '2025-03-17', N'Đau dạ dày', 106, 61);
GO

-- Thêm dữ liệu vào bảng YTa
INSERT INTO YTa (MaYTa, HoTen, DiaChi, SoDienThoai) VALUES 
(201, N'Thương Lê', N'Hà Nội', '0954321098'),
(202, N'Mai Chi', N'TP HCM', '0943210987'),
(203, N'Lan Anh', N'Đà Nẵng', '0932109876'),
(204, N'Tuấn Anh', N'Cần Thơ', '0898765432'),
(205, N'Tiến Đức', N'Huế', '0887654321'),
(206, N'Ngọc Trường', N'Hải Phòng', '0876543210');
GO

-- Thêm dữ liệu vào bảng ChamSocBenhNhan
INSERT INTO ChamSocBenhNhan (MaChamSoc, NgayChamSoc, NoiDungChamSoc, MaYTa, MaBenhNhan) VALUES 
(301, '2025-04-08', N'Thay băng vết thương', 201, 101),
(302, '2025-04-09', N'Hỗ trợ uống thuốc', 202, 102),
(303, '2025-04-10', N'Kiểm tra huyết áp', 203, 103),
(304, '2025-04-11', N'Theo dõi hô hấp', 204, 104),
(305, '2025-04-12', N'Bôi thuốc ngoài da', 205, 105),
(306, '2025-04-13', N'Hướng dẫn ăn uống', 206, 106);
GO

-- Thêm dữ liệu vào bảng ThuocVatTu
INSERT INTO ThuocVatTu (MaThuocVatTu, TenThuocVatTu, Loai) VALUES 
(401, N'Paracetamol', N'Thuốc'),
(402, N'Băng gạc', N'Vật tư'),
(403, N'Vitamin C', N'Thuốc'),
(404, N'Kháng sinh Amoxicillin', N'Thuốc'),
(405, N'Kem bôi da', N'Thuốc'),
(406, N'Men vi sinh', N'Thuốc');
GO

-- Thêm dữ liệu vào bảng KeDon
INSERT INTO KeDon (MaThuocVatTu, MaBenhNhan) VALUES 
(401, 101),
(402, 102),
(403, 103), 
(404, 104),
(405, 105),
(406, 106);
GO

SELECT * FROM ChuyenKhoa;
SELECT * FROM BacSi;
SELECT * FROM BenhNhan;
SELECT * FROM HoSoDieuTri;
SELECT * FROM YTa;
SELECT * FROM ChamSocBenhNhan;
SELECT * FROM ThuocVatTu;
SELECT * FROM KeDon;

-- Cập nhật dữ liệu (UPDATE)
-- Cập nhật số điện thoại của bác sĩ có mã 11:
UPDATE BacSi 
SET SoDienThoai = '0911111111'
WHERE MaBacSi = 11;
GO

-- Cập nhật chẩn đoán mới cho bệnh nhân có mã hồ sơ điều trị 10:
UPDATE HoSoDieuTri
SET ChanDoan = N'Cảm cúm nặng'
WHERE MaHoSoDieuTri = 10;
GO

-- Cập nhật ngày xuất viện cho bệnh nhân có mã 105:
UPDATE BenhNhan
SET NgayNhapVien = '2025-03-15'
WHERE MaBenhNhan = 105;
GO

-- Xóa dữ liệu (DELETE)
-- Xóa trong bảng KeDon trước 
DELETE FROM KeDon
WHERE MaBenhNhan = 103;

-- Xóa trong bảng ChamSocBenhNhan trước 
DELETE FROM ChamSocBenhNhan 
WHERE MaBenhNhan = 105;

-- Xóa trong bảng BacSi mã 21
-- Kiểm tra các hồ sơ điều trị liên quan đến bác sĩ 21:
SELECT * FROM BenhNhan WHERE MaBacSi = 21;

--Nếu không muốn xóa bệnh nhân, có thể gán MaBacSi của họ sang bác sĩ khác 
UPDATE BenhNhan SET MaBacSi = 11 
WHERE MaBacSi = 21;

--Nếu không muốn xóa dữ liệu, có thể cập nhật MaBacSi của các hồ sơ điều trị sang bác sĩ khác
UPDATE HoSoDieuTri SET MaBacSi = 11 
WHERE MaBacSi = 21;

DELETE FROM BacSi WHERE MaBacSi = 21;



----**CHƯƠNG 5
--1. Tạo người dùng:
-- Bước 1: Tạo đăng nhập ở cấp server
CREATE LOGIN NHOM_3 WITH PASSWORD = 'maxmeli';
-- Bước 2: Chuyển sang cơ sở dữ liệu cần sử dụng
USE QL_BV;
-- Bước 3: Tạo người dùng trong cơ sở dữ liệu
CREATE USER NHOM_3 FOR LOGIN NHOM_3;
-- Bước 4: Cấp quyền cho người dùng (Toàn quyền trên CSDL)
ALTER ROLE db_owner ADD MEMBER NHOM_3;
--Chạy lệnh sau để xem người dùng trong CSDL QL_BV:
USE QL_BV;
SELECT name FROM sys.database_principals WHERE type = 'S';
--Chạy lệnh sau để kiểm tra quyền của User_Test:
USE QL_BV;
EXEC sp_helprolemember 'db_owner';

--2.1. Thiết lập các quyền truy cập 
--Gán quyền SELECT cho người dùng NHOM_3 trên bảng BenhNhan
GRANT SELECT ON BenhNhan TO NHOM_3;
--Gán quyền INSERT và UPDATE cho người dùng NHOM_3 trên bảng HoSoDieuTri
GRANT SELECT, INSERT, UPDATE ON HoSoDieuTri TO NHOM_3;

-- Tạo stored procedure để lấy danh sách bệnh nhân
CREATE PROCEDURE sp_LayDanhSachBenhNhan
AS
BEGIN
    SELECT * FROM BenhNhan
END
GO

--Gán quyền EXECUTE cho người dùng NHOM_3 trên một thủ tục lưu trữ (stored procedure)
GRANT EXECUTE ON sp_LayDanhSachBenhNhan TO NHOM_3;

--2.2.  Phân quyền người dùng SQL
--Tạo Role
CREATE ROLE bacsi_role;
--Gán Quyền Cho Role
GRANT SELECT, INSERT, UPDATE ON BenhNhan TO bacsi_role;
--Thu hồi Quyền
--Thu hồi quyền SELECT từ người dùng NHOM_3
REVOKE SELECT ON BenhNhan FROM NHOM_3;
--Thu hồi quyền từ role
REVOKE SELECT, INSERT ON BenhNhan FROM bacsi_role;

-- Ngăn người dùng NHOM_3 xóa dữ liệu từ bảng BenhNhan
DENY DELETE ON BenhNhan TO NHOM_3;

----Kiểm Tra Quyền Của Người Dùng
SELECT * FROM fn_my_permissions('BenhNhan', 'OBJECT');

---3. Quản lý sao lưu và phục hồi dữ liệu
-- Sao lưu đầy đủ (Full backup)
BACKUP DATABASE QL_BV
TO DISK = 'D:\Backup\QL_BV_Backup.bak';

-- Sao lưu differential (chỉ lưu thay đổi từ bản full backup gần nhất)
BACKUP DATABASE QL_BV
TO DISK = 'D:\Backup\QL_BV_Diff.bak'
WITH DIFFERENTIAL;

-- Sao lưu transaction log
BACKUP LOG QL_BV
TO DISK = 'D:\Backup\QL_BV_Log.bak';

--Phục hồi cơ sở dữ liệu (Restore)
RESTORE DATABASE QL_BV
FROM DISK = 'D:\Backup\QL_BV_Backup.bak'
WITH REPLACE;
