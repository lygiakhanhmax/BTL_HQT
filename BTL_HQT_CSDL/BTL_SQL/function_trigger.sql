USE QL_BV;
GO
----** Tạo 10 function (trả về kiểu vô hướng, bảng, biến bảng)
-- 1. Tính tổng số bệnh nhân của một bác sĩ
CREATE FUNCTION dbo.TongSoBenhNhan (@MaBacSi INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM BenhNhan WHERE MaBacSi = @MaBacSi;
    RETURN @Count
END;
GO

SELECT dbo.TongSoBenhNhan(11);

-- 2. Trả về tên bệnh nhân theo mã bệnh nhân (vô hướng)
-- Lấy tên bác sĩ theo mã
CREATE FUNCTION dbo.LayTenBacSi (@MaBacSi INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @Ten NVARCHAR(100);
    SELECT @Ten = HoTen FROM BacSi WHERE MaBacSi = @MaBacSi;
    RETURN @Ten;
END;
GO

SELECT dbo.LayTenBacSi(21);

-- 3. Trả về số lần một bệnh nhân đã được điều trị (vô hướng)
CREATE FUNCTION dbo.SoLanDieuTri (@MaBenhNhan INT)
RETURNS INT
AS
BEGIN
    DECLARE @SoLan INT;
    SELECT @SoLan = COUNT(*) FROM HoSoDieuTri WHERE MaBenhNhan = @MaBenhNhan;
    RETURN @SoLan;
END;
GO

SELECT dbo.SoLanDieuTri(102);

DROP FUNCTION dbo.SoLanDieuTri;
-- 4. Lấy danh sách bác sĩ theo chuyên khoa (bảng)
CREATE FUNCTION dbo.DanhSachBacSiTheoChuyenKhoa (@MaChuyenKhoa INT)
RETURNS TABLE
AS
RETURN (
    SELECT MaBacSi, HoTen, SoDienThoai
    FROM BacSi
    WHERE MaChuyenKhoa = @MaChuyenKhoa
);
GO

SELECT * FROM dbo.DanhSachBacSiTheoChuyenKhoa(2);

-- 5. Lấy danh sách bệnh nhân của một bác sĩ (bảng)
CREATE FUNCTION dbo.DanhSachBenhNhanCuaBacSi (@MaBacSi INT)
RETURNS TABLE
AS
RETURN (
    SELECT MaBenhNhan, HoTen, NgayNhapVien
    FROM BenhNhan
    WHERE MaBacSi = @MaBacSi
);
GO

SELECT * FROM dbo.DanhSachBenhNhanCuaBacSi(21);

-- 6. Kiểm tra xem bệnh nhân có được kê đơn thuốc không (vô hướng)
CREATE FUNCTION dbo.KiemTraKeDon (@MaBenhNhan INT)
RETURNS BIT
AS
BEGIN
    DECLARE @CoThuoc BIT;
    IF EXISTS (SELECT 1 FROM KeDon WHERE MaBenhNhan = @MaBenhNhan)
        SET @CoThuoc = 1;
    ELSE
        SET @CoThuoc = 0;
    RETURN @CoThuoc;
END;
GO

SELECT dbo.KiemTraKeDon(102);

-- 7. Lấy danh sách y tá đã chăm sóc một bệnh nhân (bảng)
CREATE FUNCTION dbo.DanhSachYTaChamSoc (@MaBenhNhan INT)
RETURNS TABLE
AS
RETURN (
    SELECT YT.MaYTa, YT.HoTen, CS.NoiDungChamSoc, CS.NgayChamSoc
    FROM ChamSocBenhNhan CS inner join YTa YT ON CS.MaYTa = YT.MaYTa
    WHERE CS.MaBenhNhan = @MaBenhNhan
);
GO

SELECT * FROM dbo.DanhSachYTaChamSoc(102);

-- 8. Lấy danh sách bệnh nhân theo ngày nhập viện (biến bảng)

DROP FUNCTION IF EXISTS dbo.BenhNhanTheoNgayNhapVien;

CREATE FUNCTION dbo.BenhNhanTheoNgayNhapVien (@Ngay DATE)
RETURNS @DanhSach TABLE (MaBenhNhan INT, HoTen NVARCHAR(100), DiaChi NVARCHAR(255))
AS
BEGIN
    INSERT INTO @DanhSach
    SELECT MaBenhNhan, HoTen, DiaChi
    FROM BenhNhan
    WHERE NgayNhapVien = @Ngay;
    RETURN;
END;
GO

SELECT * FROM dbo.BenhNhanTheoNgayNhapVien('2025-03-02');

-- 9. Lưu danh sách bệnh nhân nhập viện vào biến bảng
-- Lưu danh sách bệnh nhân nhập viện sau ngày 2025-03-01 vào biến bảng và hiển thị.

DROP TABLE #DanhSachBenhNhan;

CREATE TABLE #DanhSachBenhNhan (
    MaBenhNhan INT,
    HoTen NVARCHAR(100),
    NgayNhapVien DATE
);
GO

INSERT INTO #DanhSachBenhNhan
SELECT MaBenhNhan, HoTen, NgayNhapVien
FROM BenhNhan
WHERE NgayNhapVien >= '2025-03-01';
GO

SELECT * FROM #DanhSachBenhNhan;

--10 Function để tính số ngày bệnh nhân đã nằm viện tính đến hiện tại
CREATE FUNCTION dbo.SoNgayNamVien (@MaBenhNhan INT)
RETURNS INT
AS
BEGIN
    DECLARE @SoNgay INT;
    DECLARE @NgayNhapVien DATE;
    -- Lấy ngày nhập viện của bệnh nhân
    SELECT @NgayNhapVien = NgayNhapVien 
    FROM BenhNhan 
    WHERE MaBenhNhan = @MaBenhNhan;
    -- Tính số ngày nằm viện đến hiện tại
    IF @NgayNhapVien IS NOT NULL
        SET @SoNgay = DATEDIFF(DAY, @NgayNhapVien, GETDATE());
    ELSE
        SET @SoNgay = 0;
    RETURN @SoNgay;
END;
GO

SELECT 
    MaBenhNhan, 
    HoTen, 
    NgayNhapVien, 
    dbo.SoNgayNamVien(MaBenhNhan) AS SoNgayNamVien
FROM BenhNhan;

-- Tạo 7- 10 trigger để kiểm soát dữ liệu 
-- 1. Ngăn không cho nhập bệnh nhân có cùng số CMND/CCCD
DROP TRIGGER trg_KiemTraCMND_BenhNhan;
GO
CREATE TRIGGER trg_KiemTraCMND_BenhNhan
ON BenhNhan
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM BenhNhan b inner join inserted i ON b.SoCMND_CCCD = i.SoCMND_CCCD
    )
    BEGIN
        RAISERROR (N'Số CMND/CCCD đã tồn tại!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

INSERT INTO BenhNhan (MaBenhNhan, HoTen, SoCMND_CCCD)  
VALUES ('108', N'Gia Kiệt', '345678901'); 

-- 2. Tự động cập nhật ngày nhập viện khi có hồ sơ điều trị mới
CREATE TRIGGER trg_CapNhatNgayNhapVien
ON HoSoDieuTri
AFTER INSERT
AS
BEGIN
    UPDATE BenhNhan
    SET NgayNhapVien = i.NgayDieuTri
    FROM BenhNhan b inner join inserted i ON b.MaBenhNhan = i.MaBenhNhan;
END;
GO

SELECT * FROM BenhNhan WHERE MaBenhNhan = 101;
GO

INSERT INTO BenhNhan (MaBenhNhan, HoTen, DiaChi, SoCMND_CCCD, NgayNhapVien, MaBacSi) 
VALUES (101, N'Văn Khoa', N'Hà Nội', '528475927', '2025-03-08', 11);

-- 3. Kiểm tra số điện thoại bác sĩ phải đủ 10 chữ số
CREATE TRIGGER trg_KiemTraSoDienThoai
ON BacSi
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE LEN(SoDienThoai) <> 10 OR SoDienThoai LIKE '%[^0-9]%'
    )
    BEGIN
        RAISERROR (N'Số điện thoại bác sĩ không hợp lệ!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

UPDATE BacSi 
SET SoDienThoai = 'abc1234567'  
WHERE MaBacSi = '11';

-- 4. Không cho phép xoá bác sĩ nếu còn bệnh nhân đang điều trị
DROP TRIGGER trg_KhongXoaBacSi;
GO

CREATE TRIGGER trg_KhongXoaBacSi
ON BacSi
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM deleted d inner join BenhNhan b ON d.MaBacSi = b.MaBacSi
    )
    BEGIN
        RAISERROR (N'Không thể xoá bác sĩ vì đang có bệnh nhân điều trị!', 16, 1);
        RETURN;
    END
    DELETE FROM BacSi WHERE MaBacSi IN (SELECT MaBacSi FROM deleted);
END;
GO

DELETE FROM BacSi WHERE MaBacSi = '11';

-- 5. Tự động cập nhật chuyên khoa của bác sĩ khi sửa đổi
CREATE TRIGGER trg_CapNhatChuyenKhoa
ON BacSi
AFTER UPDATE
AS
BEGIN
    UPDATE BacSi
    SET MaChuyenKhoa = i.MaChuyenKhoa
    FROM BacSi b inner join inserted i ON b.MaBacSi = i.MaBacSi;
END;
GO

-- Thay 1 bằng ID bác sĩ cần kiểm tra
SELECT * FROM BacSi WHERE MaBacSi = 1;
GO

UPDATE BacSi  
SET MaChuyenKhoa = 2  -- Thay 2 bằng mã chuyên khoa mới  
WHERE MaBacSi = 11;  -- Thay 1 bằng ID bác sĩ cần cập nhật
GO

SELECT * FROM BacSi WHERE MaBacSi = 11; 
-- 6. Kiểm tra ngày chăm sóc bệnh nhân không nhỏ hơn ngày nhập viện
CREATE TRIGGER trg_KiemTraNgayChamSoc
ON ChamSocBenhNhan
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i inner join BenhNhan b ON i.MaBenhNhan = b.MaBenhNhan
        WHERE i.NgayChamSoc < b.NgayNhapVien
    )
    BEGIN
        RAISERROR (N'Ngày chăm sóc không được trước ngày nhập viện!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

UPDATE ChamSocBenhNhan 
SET NgayChamSoc = '2024-02-02' 
WHERE MaBenhNhan = '102';

-- 7. Ngăn kê đơn thuốc/vật tư trùng lặp cho cùng bệnh nhân
CREATE TRIGGER trg_KiemTraKeDon ON KeDon
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i inner join KeDon k ON i.MaThuocVatTu = k.MaThuocVatTu AND i.MaBenhNhan = k.MaBenhNhan
    )
    BEGIN
        RAISERROR (N'Bệnh nhân đã được kê đơn thuốc này trước đó!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

INSERT INTO KeDon (MaThuocVatTu, MaBenhNhan) VALUES (401, 102);
GO

-- kiểm tra trigger đang tồn tại
SELECT name FROM sys.triggers WHERE type = 'TR';
GO

-- Xóa trigger
DROP TRIGGER trg_KiemTraKeDon;
GO