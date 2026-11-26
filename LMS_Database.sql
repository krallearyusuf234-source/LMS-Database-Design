USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'LMS_DB')
BEGIN
    ALTER DATABASE LMS_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LMS_DB;
END
GO

CREATE DATABASE LMS_DB;
GO
USE LMS_DB;
GO


-- 1. TABLOLARIN OLUŞTURULMASI (DDL & Kısıtlamalar)
CREATE TABLE bolumler (
    bolum_id INT PRIMARY KEY,
    bolum_adi VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE akademisyenler (
    akademisyen_id INT PRIMARY KEY,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    unvan VARCHAR(50)
);

CREATE TABLE ogrenciler (
    ogrenci_id INT PRIMARY KEY,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    bolum_id INT,
    sinif INT CHECK (sinif BETWEEN 1 AND 4),
    kayit_tarihi DATE DEFAULT GETDATE(),
    CONSTRAINT fk_bolum FOREIGN KEY (bolum_id) REFERENCES bolumler(bolum_id)
);

CREATE TABLE dersler (
    ders_id INT PRIMARY KEY,
    ders_adi VARCHAR(100) NOT NULL,
    kredi INT CHECK (kredi BETWEEN 1 AND 6),
    akademisyen_id INT,
    CONSTRAINT fk_akademisyen FOREIGN KEY (akademisyen_id) REFERENCES akademisyenler(akademisyen_id)
);

CREATE TABLE notlar (
    ogrenci_id INT,
    ders_id INT,
    vize INT CHECK (vize BETWEEN 0 AND 100),
    final INT CHECK (final BETWEEN 0 AND 100),
    PRIMARY KEY (ogrenci_id, ders_id),
    FOREIGN KEY (ogrenci_id) REFERENCES ogrenciler(ogrenci_id),
    FOREIGN KEY (ders_id) REFERENCES dersler(ders_id)
);

CREATE TABLE sanal_siniflar (
    sanal_sinif_id INT PRIMARY KEY,
    ders_id INT,
    baslik VARCHAR(150),
    aktif_mi BIT DEFAULT 1,
    FOREIGN KEY (ders_id) REFERENCES dersler(ders_id)
);

CREATE TABLE odevler (
    odev_id INT PRIMARY KEY,
    ders_id INT,
    baslik VARCHAR(150),
    teslim_tarihi DATE,
    FOREIGN KEY (ders_id) REFERENCES dersler(ders_id)
);

CREATE TABLE sinavlar (
    sinav_id INT PRIMARY KEY,
    ders_id INT,
    sinav_adi VARCHAR(100),
    tarih DATETIME,
    FOREIGN KEY (ders_id) REFERENCES dersler(ders_id)
);
GO


-- 2. ÖRNEK VERİLERİN EKLENMESİ (DML - INSERT)

INSERT INTO bolumler VALUES (101, 'Bilgisayar Mühendisliği');
INSERT INTO bolumler VALUES (102, 'Elektrik-Elektronik Mühendisliği');
INSERT INTO bolumler VALUES (103, 'Mekatronik Mühendisliği');
INSERT INTO bolumler VALUES (104, 'Makine Mühendisliği');
INSERT INTO bolumler VALUES (105, 'Metalurji ve Malzeme Mühendisliği');
INSERT INTO bolumler VALUES (106, 'İnşaat Mühendisliği');

INSERT INTO akademisyenler VALUES (1, 'Harun', 'Yılmaz', 'Dr. Öğr. Üyesi');
INSERT INTO akademisyenler VALUES (2, 'Ali', 'Sönmez', 'Prof. Dr.');

INSERT INTO ogrenciler (ogrenci_id, ad, soyad, bolum_id, sinif) 
VALUES (1, 'Yusuf', 'Yıldız', 101, 2);

INSERT INTO dersler VALUES (201, 'Nesneye Yönelik Programlama', 5, 2);
INSERT INTO dersler VALUES (202, 'Veri Yapıları ve Algoritmalar', 4, 2);
INSERT INTO dersler VALUES (203, 'Veritabanı Yönetim Sistemleri', 3, 1);
INSERT INTO dersler VALUES (204, 'Bilgisayar Mimarisi ve Organizasyonu', 3, 2);
INSERT INTO dersler VALUES (205, 'İngilizce', 2, 2);
INSERT INTO dersler VALUES (206, 'Olasılık ve İstatistik', 3, 2);

INSERT INTO notlar VALUES (1, 201, 80, 85);
INSERT INTO notlar VALUES (1, 202, 75, 80);
INSERT INTO notlar VALUES (1, 203, 85, 90);
INSERT INTO notlar VALUES (1, 204, 70, 75);
INSERT INTO notlar VALUES (1, 205, 90, 95);
INSERT INTO notlar VALUES (1, 206, 65, 70);

INSERT INTO sanal_siniflar VALUES (1, 203, 'VTYS 7. Hafta Canlı Ders (DDL & JOIN)', 1);
INSERT INTO odevler VALUES (1, 203, 'VTYS Veritabanı Ödevi', '2026-11-15');
INSERT INTO sinavlar VALUES (1, 203, 'VTYS Vize Sınavı', '2026-11-20');
GO


-- 3. JOIN VE VIEW (GÖRÜNÜM) OLUŞTURMA

CREATE VIEW vw_OgrenciTumDersler AS
SELECT 
    o.ogrenci_id,
    o.ad + ' ' + o.soyad AS OgrenciAdSoyad,
    b.bolum_adi,
    d.ders_adi,
    ak.unvan + ' ' + ak.ad + ' ' + ak.soyad AS DersiVerenHoca,
    n.vize,
    n.final
FROM ogrenciler o
INNER JOIN bolumler b ON o.bolum_id = b.bolum_id
INNER JOIN notlar n ON o.ogrenci_id = n.ogrenci_id
INNER JOIN dersler d ON n.ders_id = d.ders_id
INNER JOIN akademisyenler ak ON d.akademisyen_id = ak.akademisyen_id;
GO

SELECT * FROM vw_OgrenciTumDersler;
GO

-- 4. KULLANICI YETKİLENDİRME (DCL - GRANT / ROL YÖNETİMİ)

CREATE ROLE rol_ogrenci;
CREATE ROLE rol_akademisyen;

GRANT SELECT ON vw_OgrenciTumDersler TO rol_ogrenci;

GRANT SELECT, INSERT, UPDATE, DELETE ON notlar TO rol_akademisyen;
GRANT SELECT, INSERT, UPDATE, DELETE ON sanal_siniflar TO rol_akademisyen;
GRANT SELECT, INSERT, UPDATE, DELETE ON odevler TO rol_akademisyen;
GRANT SELECT, INSERT, UPDATE, DELETE ON sinavlar TO rol_akademisyen;
GO
