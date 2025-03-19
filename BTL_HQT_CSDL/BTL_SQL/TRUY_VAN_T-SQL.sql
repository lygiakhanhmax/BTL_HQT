USE QL_BV;
GO

--***Các câu truy vấn cơ bản:
-- 1. Truy vấn dữ liệu (SELECT)
-- Lấy danh sách tất cả bác sĩ và chuyên khoa của họ:
SELECT BacSi.MaBacSi, BacSi.HoTen, ChuyenKhoa.TenChuyenKhoa
FROM BacSi inner join ChuyenKhoa ON BacSi.MaChuyenKhoa = ChuyenKhoa.MaChuyenKhoa;

-- Lấy danh sách bệnh nhân nhập viện sau ngày 2025-03-03:
SELECT * FROM BenhNhan
WHERE NgayNhapVien > '2025-03-03';

-- Lấy danh sách thuốc đã được kê cho bệnh nhân có mã 101:
SELECT ThuocVatTu.TenThuocVatTu 
FROM KeDon inner join ThuocVatTu ON KeDon.MaThuocVatTu = ThuocVatTu.MaThuocVatTu
WHERE KeDon.MaBenhNhan = 101;

-- Truy vấn nâng cao
-- INNER JOIN (Liệt kê danh sách bệnh nhân cùng bác sĩ điều trị)
SELECT BenhNhan.MaBenhNhan, BenhNhan.HoTen, BacSi.MaBacSi, BacSi.HoTen
FROM BenhNhan inner join HoSoDieuTri ON BenhNhan.MaBenhNhan = HoSoDieuTri.MaBenhNhan
			  inner join BacSi ON HoSoDieuTri.MaBacSi = BacSi.MaBacSi;

-- INNER JOIN với nhiều bảng (Liệt kê danh sách bệnh nhân, bác sĩ điều trị và khoa của bác sĩ)
SELECT BenhNhan.HoTen, BacSi.HoTen, ChuyenKhoa.TenChuyenKhoa
FROM BenhNhan inner join HoSoDieuTri ON BenhNhan.MaBenhNhan = HoSoDieuTri.MaBenhNhan
			  inner join BacSi ON HoSoDieuTri.MaBacSi = BacSi.MaBacSi
		      inner join ChuyenKhoa ON BacSi.MaChuyenKhoa = ChuyenKhoa.MaChuyenKhoa;

-- GROUP BY (Đếm số bệnh nhân theo từng khoa)
SELECT ChuyenKhoa.TenChuyenKhoa, COUNT(BenhNhan.MaBenhNhan) AS SoLuongBenhNhan
FROM BenhNhan inner join HoSoDieuTri ON BenhNhan.MaBenhNhan = HoSoDieuTri.MaBenhNhan
			  inner join BacSi ON HoSoDieuTri.MaBacSi = BacSi.MaBacSi
		      inner join ChuyenKhoa ON BacSi.MaChuyenKhoa = ChuyenKhoa.MaChuyenKhoa
GROUP BY ChuyenKhoa.TenChuyenKhoa;

-- GROUP BY (Thống kê số lượng bác sĩ theo chuyên khoa)
SELECT ck.TenChuyenKhoa, COUNT(bs.MaBacSi) AS SoLuongBacSi
FROM BacSi bs inner join ChuyenKhoa ck ON bs.MaChuyenKhoa = ck.MaChuyenKhoa
GROUP BY ck.TenChuyenKhoa;

-- GROUP BY (Thống kê số lượng đơn thuốc kê cho từng bệnh nhân)
SELECT bn.HoTen AS BenhNhan, COUNT(kd.MaThuocVatTu) AS SoLuongThuoc
FROM KeDon kd inner join BenhNhan bn ON kd.MaBenhNhan = bn.MaBenhNhan
GROUP BY bn.HoTen
ORDER BY SoLuongThuoc DESC;

-- HAVING (Chỉ thống kê chuyên khoa có từ 3 bác sĩ trở lên)
SELECT ck.TenChuyenKhoa, COUNT(bs.MaBacSi) AS SoLuongBacSi
FROM BacSi bs inner join ChuyenKhoa ck ON bs.MaChuyenKhoa = ck.MaChuyenKhoa
GROUP BY ck.TenChuyenKhoa
HAVING COUNT(bs.MaBacSi) >= 3;

-- HAVING (Tìm y tá đã chăm sóc ít nhất 3 bệnh nhân khác nhau)
SELECT yt.HoTen AS YTa, COUNT(DISTINCT bn.MaBenhNhan) AS SoBenhNhan
FROM ChamSocBenhNhan cs inner join YTa yt ON cs.MaYTa = yt.MaYTa
						inner join BenhNhan bn ON cs.MaBenhNhan = bn.MaBenhNhan
GROUP BY yt.HoTen
HAVING COUNT(DISTINCT bn.MaBenhNhan) >= 3;

-- HAVING (Bệnh nhân nào được kê hơn 3 loại thuốc?)
SELECT bn.HoTen AS BenhNhan, COUNT(DISTINCT kd.MaThuocVatTu) AS SoLuongThuoc
FROM KeDon kd inner join BenhNhan bn ON kd.MaBenhNhan = bn.MaBenhNhan
GROUP BY bn.HoTen
HAVING COUNT(DISTINCT kd.MaThuocVatTu) > 3;

-- SUBQUERY (Tìm bệnh nhân chỉ nhập viện 1 lần)
SELECT HoTen
FROM BenhNhan
WHERE MaBenhNhan IN (
    SELECT MaBenhNhan
    FROM HoSoDieuTri
    GROUP BY MaBenhNhan
    HAVING COUNT(*) = 1
);

-- SUBQUERY (Tìm bác sĩ có số bệnh nhân cao nhất)
SELECT HoTen
FROM BacSi
WHERE MaBacSi IN (
    SELECT MaBacSi
    FROM BenhNhan
    GROUP BY MaBacSi
    HAVING COUNT(MaBenhNhan) = (
        SELECT MAX(SoLuong)
        FROM (
            SELECT MaBacSi, COUNT(MaBenhNhan) AS SoLuong
            FROM BenhNhan
            GROUP BY MaBacSi
        ) AS Temp
    )
);

-- SUBQUERY (Tìm bệnh nhân đã từng khám ở tất cả các khoa)
SELECT MaBenhNhan, HoTen
FROM BenhNhan B
WHERE NOT EXISTS (
    SELECT MaChuyenKhoa FROM ChuyenKhoa
    EXCEPT
    SELECT DISTINCT MaBenhNhan FROM HoSoDieuTri WHERE HoSoDieuTri.MaBenhNhan = B.MaBenhNhan
);

DROP VIEW IF EXISTS V_DanhSachBacSi;
GO

---**Tạo 7- 10 view từ cơ bản đến nâng cao
--1. Danh sách bác sĩ và chuyên khoa của họ
--Hiển thị thông tin bác sĩ và chuyên khoa mà họ làm việc.
CREATE VIEW V_DanhSachBacSi AS
SELECT 
    bs.MaBacSi, bs.HoTen AS TenBacSi, bs.DiaChi, bs.SoDienThoai, 
    ck.TenChuyenKhoa
FROM BacSi bs inner join ChuyenKhoa ck ON bs.MaChuyenKhoa = ck.MaChuyenKhoa;
GO

SELECT table_name FROM information_schema.views;
GO
SELECT * FROM V_DanhSachBacSi;
GO

--2. Danh sách bệnh nhân và bác sĩ điều trị
--Hiển thị thông tin bệnh nhân và bác sĩ trực tiếp điều trị họ.
DROP VIEW IF EXISTS V_BenhNhan_BacSi;
GO
CREATE VIEW V_BenhNhan_BacSi AS
SELECT 
    bn.MaBenhNhan, bn.HoTen AS TenBenhNhan, bn.DiaChi, bn.SoCMND_CCCD, bn.NgayNhapVien, 
    bs.HoTen AS TenBacSi
FROM BenhNhan bn inner join BacSi bs ON bn.MaBacSi = bs.MaBacSi;
GO

SELECT table_name FROM information_schema.views;
GO

SELECT * FROM V_BenhNhan_BacSi;
GO

-- 3. Hồ sơ điều trị chi tiết của từng bệnh nhân
-- Liệt kê chẩn đoán của bệnh nhân, bác sĩ điều trị và ngày điều trị.
CREATE VIEW V_HoSoDieuTri AS
SELECT 
    hdt.MaHoSoDieuTri, hdt.NgayDieuTri, hdt.ChanDoan, 
    bn.HoTen AS TenBenhNhan, bs.HoTen AS TenBacSi
FROM HoSoDieuTri hdt inner join BenhNhan bn ON hdt.MaBenhNhan = bn.MaBenhNhan
				   	 inner join BacSi bs ON hdt.MaBacSi = bs.MaBacSi;
GO

SELECT * FROM V_HoSoDieuTri;
GO

-- 4. Danh sách y tá và số lần chăm sóc bệnh nhân
-- Hiển thị y tá cùng số lần chăm sóc bệnh nhân của họ.
CREATE VIEW V_SoLanChamSoc AS
SELECT 
    yt.MaYTa, yt.HoTen AS TenYTa, yt.DiaChi, yt.SoDienThoai, 
    COUNT(csb.MaChamSoc) AS SoLanChamSoc
FROM YTa yt left join ChamSocBenhNhan csb ON yt.MaYTa = csb.MaYTa
GROUP BY yt.MaYTa, yt.HoTen, yt.DiaChi, yt.SoDienThoai;
GO

SELECT * FROM V_SoLanChamSoc;
GO

-- 5. Danh sách bệnh nhân có kê đơn thuốc
-- Liệt kê bệnh nhân nào đang có đơn thuốc.
CREATE VIEW V_BenhNhan_KeDon AS
SELECT 
    bn.MaBenhNhan, bn.HoTen AS TenBenhNhan, bn.DiaChi, 
    tvt.TenThuocVatTu, tvt.Loai
FROM KeDon kd inner join BenhNhan bn ON kd.MaBenhNhan = bn.MaBenhNhan
	  		  inner join ThuocVatTu tvt ON kd.MaThuocVatTu = tvt.MaThuocVatTu;

SELECT * FROM V_BenhNhan_KeDon;
GO

-- 6. Danh sách bệnh nhân nhập viện trong tháng 3/2025
-- Lọc danh sách bệnh nhân nhập viện trong tháng 3 năm 2025.
CREATE VIEW V_BenhNhan_Thang3 AS
SELECT * FROM BenhNhan
WHERE MONTH(NgayNhapVien) = 3 AND YEAR(NgayNhapVien) = 2025;
GO

SELECT * FROM V_BenhNhan_Thang3;
GO

-- 7. Danh sách bệnh nhân có nhiều hơn 1 đơn thuốc
-- Lọc ra những bệnh nhân có kê từ 2 đơn thuốc trở lên.
CREATE VIEW V_BenhNhan_NhieuThuoc AS
SELECT 
    bn.MaBenhNhan, bn.HoTen AS TenBenhNhan, 
    COUNT(kd.MaThuocVatTu) AS SoLuongThuoc
FROM KeDon kd inner join BenhNhan bn ON kd.MaBenhNhan = bn.MaBenhNhan
GROUP BY bn.MaBenhNhan, bn.HoTen
HAVING COUNT(kd.MaThuocVatTu) > 1;
GO

SELECT * FROM V_BenhNhan_NhieuThuoc;
GO

-- 8. Số lần chăm sóc bệnh nhân theo từng y tá trong tháng 4/2025
-- Thống kê số lần y tá chăm sóc bệnh nhân trong tháng 4/2025.
CREATE VIEW V_ThongKeChamSoc_Thang4 AS
SELECT 
    yt.HoTen AS TenYTa, COUNT(csb.MaChamSoc) AS SoLanChamSoc
FROM ChamSocBenhNhan csb inner join YTa yt ON csb.MaYTa = yt.MaYTa
WHERE MONTH(csb.NgayChamSoc) = 4 AND YEAR(csb.NgayChamSoc) = 2025
GROUP BY yt.HoTen;
GO

SELECT * FROM V_ThongKeChamSoc_Thang4;
GO

-- 9. Số lần điều trị của từng bác sĩ trong tháng 3/2025
-- Thống kê số hồ sơ điều trị của từng bác sĩ trong tháng 3/2025.
CREATE VIEW V_SoHoSoDieuTri_Thang3 AS
SELECT 
    bs.HoTen AS TenBacSi, COUNT(hdt.MaHoSoDieuTri) AS SoHoSoDieuTri
FROM HoSoDieuTri hdt inner join BacSi bs ON hdt.MaBacSi = bs.MaBacSi
WHERE MONTH(hdt.NgayDieuTri) = 3 AND YEAR(hdt.NgayDieuTri) = 2025
GROUP BY bs.HoTen;
GO

SELECT * FROM V_SoHoSoDieuTri_Thang3;
GO

----**Tạo 7-10 index cần thiết cho các bảng
-- 1. Index trên các khóa ngoại
-- Nhằm tăng tốc truy vấn khi thực hiện JOIN giữa các bảng liên quan.
-- Index cho MaChuyenKhoa trong bảng BacSi
CREATE INDEX idx_BacSi_MaChuyenKhoa ON BacSi(MaChuyenKhoa);

-- Index cho MaBacSi trong bảng BenhNhan
CREATE INDEX idx_BenhNhan_MaBacSi ON BenhNhan(MaBacSi);

-- Index cho MaBenhNhan và MaBacSi trong bảng HoSoDieuTri
CREATE INDEX idx_HoSoDieuTri_MaBenhNhan ON HoSoDieuTri(MaBenhNhan);
CREATE INDEX idx_HoSoDieuTri_MaBacSi ON HoSoDieuTri(MaBacSi);

-- Index cho MaBenhNhan và MaYTa trong bảng ChamSocBenhNhan
CREATE INDEX idx_ChamSocBenhNhan_MaBenhNhan ON ChamSocBenhNhan(MaBenhNhan);
CREATE INDEX idx_ChamSocBenhNhan_MaYTa ON ChamSocBenhNhan(MaYTa);

-- Index cho MaBenhNhan trong bảng KeDon
CREATE INDEX idx_KeDon_MaBenhNhan ON KeDon(MaBenhNhan);

-- 2. Index trên các cột thường xuyên lọc dữ liệu (WHERE, ORDER BY)
-- Nhằm tăng hiệu suất khi tìm kiếm hoặc sắp xếp.
-- Index trên SoCMND_CCCD để tìm bệnh nhân nhanh hơn
CREATE INDEX idx_BenhNhan_SoCMND_CCCD ON BenhNhan(SoCMND_CCCD);

-- Index trên NgayDieuTri để tăng tốc truy vấn theo ngày điều trị
CREATE INDEX idx_HoSoDieuTri_NgayDieuTri ON HoSoDieuTri(NgayDieuTri);
-- Index trên NgayNhapVien để tối ưu các truy vấn tìm bệnh nhân nhập viện theo ngày
CREATE INDEX idx_BenhNhan_NgayNhapVien ON BenhNhan(NgayNhapVien);

DROP INDEX idx_BenhNhan_NgayNhapVien ON BenhNhan;
--SQL Server:
EXEC sp_helpindex 'BenhNhan';
EXEC sp_helpindex 'ChamSocBenhNhan';
EXEC sp_helpindex 'HoSoDieuTri';
EXEC sp_helpindex 'KeDon';


----**Xây dựng 10 Stored Procedure(không tham số, có tham số, có OUTPUT)
-- 1. Stored Procedure không có tham số
-- 1.1. Lấy danh sách tất cả bệnh nhân
CREATE PROCEDURE sp_LayDanhSachBenhNhan
AS
BEGIN
    SELECT * FROM BenhNhan;
END;
GO

EXEC sp_LayDanhSachBenhNhan;
GO
-- 1.2. Lấy danh sách bác sĩ và chuyên khoa
CREATE PROCEDURE sp_LayDanhSachBacSi
AS
BEGIN
    SELECT BacSi.MaBacSi, BacSi.HoTen, ChuyenKhoa.TenChuyenKhoa 
    FROM BacSi inner join ChuyenKhoa ON BacSi.MaChuyenKhoa = ChuyenKhoa.MaChuyenKhoa;
END;
GO

EXEC sp_LayDanhSachBacSi;
-- 2. Stored Procedure có tham số
-- 2.1. Tìm bệnh nhân theo số CMND/CCCD
CREATE PROCEDURE sp_TimBenhNhanTheoCMND
    @SoCMND_CCCD VARCHAR(20)
AS
BEGIN
    SELECT * FROM BenhNhan WHERE SoCMND_CCCD = @SoCMND_CCCD;
END;

EXEC sp_TimBenhNhanTheoCMND @SoCMND_CCCD = '123456789';
-- 2.2. Tìm bệnh nhân theo mã bệnh nhân
CREATE PROCEDURE sp_TimBenhNhanTheoMa
    @MaBenhNhan INT
AS
BEGIN
    SELECT * FROM BenhNhan WHERE MaBenhNhan = @MaBenhNhan;
END;
GO

EXEC sp_TimBenhNhanTheoMa @MaBenhNhan = 102;
-- 2.3. Thêm bệnh nhân mới
ALTER PROCEDURE sp_ThemBenhNhan
    @MaBenhNhan INT,  
    @HoTen NVARCHAR(100),   
    @DiaChi NVARCHAR(200),  
    @SoCMND_CCCD VARCHAR(20),  
    @NgayNhapVien DATE,  
    @MaBacSi INT
AS
BEGIN
    INSERT INTO BenhNhan (MaBenhNhan, HoTen, DiaChi, SoCMND_CCCD, NgayNhapVien, MaBacSi)
    VALUES (@MaBenhNhan, @HoTen, @DiaChi, @SoCMND_CCCD, @NgayNhapVien, @MaBacSi);
END;
GO

EXEC sp_ThemBenhNhan 
    @MaBenhNhan = 100,  
    @HoTen = N'Trần Gia',  
    @DiaChi = N'Ninh Bình',  
    @SoCMND_CCCD = '756355555',  
    @NgayNhapVien = '2025-03-09',  
    @MaBacSi = 11;
	GO

	SELECT * FROM BenhNhan;
--2.4. Cập nhật thông tin bệnh nhân
CREATE PROCEDURE sp_CapNhatThongTinBenhNhan
    @MaBenhNhan INT,  
    @HoTen NVARCHAR(100),  
    @DiaChi NVARCHAR(200)
AS
BEGIN
    UPDATE BenhNhan  
    SET HoTen = @HoTen, DiaChi = @DiaChi  
    WHERE MaBenhNhan = @MaBenhNhan;
END;
GO

EXEC sp_CapNhatThongTinBenhNhan 
    @MaBenhNhan = 101,  
    @HoTen = N'Đình Quang Cập Nhật',  
    @DiaChi = N'Hà Nội Mới';
	GO

SELECT * FROM BenhNhan WHERE MaBenhNhan = 101;
-- 2.5. Xóa bệnh nhân theo mã
CREATE PROCEDURE sp_XoaBenhNhan
    @MaBenhNhan INT
AS
BEGIN
    DELETE FROM BenhNhan WHERE MaBenhNhan = @MaBenhNhan;
END;
GO

DELETE FROM KeDon WHERE MaBenhNhan = 101;
DELETE FROM ChamSocBenhNhan WHERE MaBenhNhan = 101;
DELETE FROM HoSoDieuTri WHERE MaBenhNhan = 101;
DELETE FROM BenhNhan WHERE MaBenhNhan = 101;
GO

EXEC sp_XoaBenhNhan @MaBenhNhan = 101;

SELECT * FROM BenhNhan WHERE MaBenhNhan = 101;
-- 3. Stored Procedure có tham số OUTPUT
-- 3.1. Đếm số lượng bệnh nhân trong hệ thống
CREATE PROCEDURE sp_DemSoLuongBenhNhan
    @SoLuong INT OUTPUT
AS
BEGIN
    SELECT @SoLuong = COUNT(*) FROM BenhNhan;
END;
GO

DECLARE @SL INT;
EXEC sp_DemSoLuongBenhNhan @SL OUTPUT;
SELECT @SL AS SoLuongBenhNhan;
GO

-- 3.2. Lấy tổng số bệnh nhân điều trị bởi một bác sĩ
CREATE PROCEDURE sp_TongBenhNhanCuaBacSi
    @MaBacSi INT,  
    @TongBenhNhan INT OUTPUT
AS
BEGIN
    SELECT @TongBenhNhan = COUNT(*)  
    FROM BenhNhan  
    WHERE MaBacSi = @MaBacSi;
END;
GO

DECLARE @SL INT;
EXEC sp_TongBenhNhanCuaBacSi @MaBacSi = 11, @TongBenhNhan = @SL OUTPUT;
PRINT @SL;
GO
-- 3.3. Lấy ngày nhập viện của bệnh nhân theo mã
CREATE PROCEDURE sp_LayNgayNhapVien
    @MaBenhNhan INT,  
    @NgayNhapVien DATE OUTPUT
AS
BEGIN
    SELECT @NgayNhapVien = NgayNhapVien  
    FROM BenhNhan  
    WHERE MaBenhNhan = @MaBenhNhan;
END;
GO

DECLARE @Ngay DATE;
EXEC sp_LayNgayNhapVien @MaBenhNhan = 102, @NgayNhapVien = @Ngay OUTPUT;
PRINT @Ngay;
GO

-- Gọi SP không có tham số:
EXEC sp_TimBenhNhanTheoMa;
-- Gọi SP có tham số:
EXEC sp_TimBenhNhanTheoCMND @thamso1 = 'value1', @thamso2 = 'value2';
--Kiểm tra Stored Procedure đã tồn tại chưa
SELECT * FROM sys.procedures WHERE name = 'sp_LayDanhSachBenhNhan';

--3.4. Stored Procedure để hiển thị thông tin chi tiết về thuốc/vật tư được kê đơn cho bệnh nhân
CREATE PROCEDURE sp_ThongTinKeDonThuoc
    @MaBenhNhan INT
AS
BEGIN
    SELECT 
        bn.MaBenhNhan,
        bn.HoTen AS TenBenhNhan,
        bn.NgayNhapVien,
        tvt.MaThuocVatTu,
        tvt.TenThuocVatTu,
        tvt.Loai,
        bs.HoTen AS BacSiPhuTrach,
        ck.TenChuyenKhoa
    FROM BenhNhan bn inner join KeDon kd ON bn.MaBenhNhan = kd.MaBenhNhan
					 inner join ThuocVatTu tvt ON kd.MaThuocVatTu = tvt.MaThuocVatTu
					 inner join BacSi bs ON bn.MaBacSi = bs.MaBacSi
				   	 inner join ChuyenKhoa ck ON bs.MaChuyenKhoa = ck.MaChuyenKhoa
    WHERE bn.MaBenhNhan = @MaBenhNhan;
END;
GO

EXEC sp_ThongTinKeDonThuoc @MaBenhNhan = 102;

