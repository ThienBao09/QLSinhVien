create database Quanlysinhvienda
use Quanlysinhvienda

create table KHOA(
  MAKHOA char(5)not null,
  TENKHOA nvarchar(30) not NULL,
  constraint pk_KHOA_MAKHOA primary  key (MAKHOA)
)

create table LOP(
MALOP nvarchar(10) primary key,
MAKHOA char(5)not null,
constraint fk_LOP_KHOA foreign key(MAKHOA) references KHOA(MAKHOA)
)

create table MONHOC(
  TENMH  nvarchar(50) not null,
  MAMH char(5) not null primary key,
  SOTIET int not null
)

create table SINHVIEN(
  TENSV nvarchar(50) not null,
  MASV char(5) not null primary key,
  MALOP nvarchar(10),
  NGAYSINH date not null,
  GIOITINH char(3) not null,
  MAKHOA char(5)not null,
  constraint fk_SINHVIEN_KHOA foreign key(MAKHOA) references KHOA(MAKHOA),
  constraint fk_SINHVIEN_LOP foreign key(MALOP) references LOP(MALOP)
)

create table KETQUA(
  MASV char(5) not null,
  MAMH char(5) not null,
  LANTHI numeric,
  DIEM numeric,
  constraint pk_KETQUA_MASV_MAMH_LANTHI primary key(MASV,MAMH,LANTHI),
  constraint fk_KETQUA_MONHOC foreign key(MAMH) references MONHOC(MAMH),
  constraint fk_ketqua_SINHVIEN foreign key(MASV) references SINHVIEN(MASV)
)

insert into KHOA(MAKHOA,TENKHOA)
values ('CNTT','Cong nghe thong tin'),
       ('HA','Ngoai ngu'),
	   ('QTKD','Khoa quan tri kinh doanh')

insert into MONHOC(TENMH,MAMH,SOTIET)
values ('Co so du lieu','CSDL','50'),
       ('tieng anh','AVA','50'),
	   ('Toan roi rac','TRR','50'),
	   ('Ke toan tai chinh','KTTC','45')

insert into LOP(MALOP,MAKHOA)
values ('TH32','CNTT'),
       ('TA03','HA'),
	   ('KT03','QTKD'),
	   ('TH02','CNTT'),
	   ('KT23','QTKD')

insert into SINHVIEN(TENSV,MASV,MALOP,NGAYSINH,GIOITINH,MAKHOA) 
values ('Phan Dinh Bach','001','TH32','02/11/2000','Nam','CNTT'),
       ('Nghiem Thi Hien','024','KT03','02/22/2000','Nu','QTKD'),
	   ('Le Thi Huyen','004','TA03','04/24/2000','Nu','HA'),
	   ('Nguyen Huu Hiep','022','TH02','08/21/2000','Nam','CNTT'),
       ('Nguyen Van Hai','015','KT23','09/23/2000','Nam','QTKD')
        
insert into KETQUA(MASV,MAMH,LANTHI,DIEM)
values  ('001','CSDL','1','8'),
        ('024','KTTC','1','7'),
		('004','AVA','2','9'),
		('022','TRR','2','8'),
		('015','KTTC','1','6')
------select trả về dữ liệu bảng -----
Select*from KHOA
select*from LOP
select*from MONHOC
select*from SINHVIEN
select*from KETQUA
------select trả về tất cả các hàng của bảng SINHVIEN với cột GIOITINH = 'Nam'-----
 select*from SINHVIEN where GIOITINH='Nam'
------select trả về tất cả các hàng cảu bảng SINHVIEN với cột TENSV bắt đầy bằng ký tự 'N'-----
select*from SINHVIEN where TENSV like 'N%'
------ Danh sách các sinh viên gồm thông tin sau: Mã sinh viên, tên sinh viên, gioi tinh, Ngày sinh. Danh sách sẽ được sắp xếp theo thứ tự Nam/Nữ.-----
select MASV as ' Ma sinh vien ', TENSV as ' Ten sinh vien ' , GIOITINH as ' Gioi tinh ', NGAYSINH as ' Ngay sinh ' 
from SINHVIEN
order by GIOITINH asc
-----kết quả học tập cảu một sinh viên : TENSV,MAMH,LANTHI,DIEM của sinh viên có MÃ 024-----
select SINHVIEN.TENSV,KETQUA.MAMH,KETQUA.LANTHI,KETQUA.DIEM
from SINHVIEN join KETQUA on SINHVIEN.MASV=KETQUA.MASV
where KETQUA.MASV='024'
------lấy các môn học trên 40 tiết trong mã môn học có chữ T----
select * from MONHOC where SOTIET>40 and MAMH like '%T%'
----- cho biết tên sinh viên có điểm cao nhât ----
select SINHVIEN.TENSV,KETQUA.DIEM
from SINHVIEN join KETQUA on SINHVIEN.MASV=KETQUA.MASV
where DIEM=(select Max(DIEM) from KETQUA)
-----Đếm số lượng sinh viên của tùng khoa----
select KHOA.TENKHOA, count(*) as SoluongSV
from SINHVIEN join KHOA on SINHVIEN.MAKHOA=KHOA.MAKHOA
group by  KHOA.TENKHOA
-----câu lệnh update------
update SINHVIEN set TENSV= 'Nguyen Ngoc Bao' where MASV='015' 
select*from SINHVIEN
update KHOA set TENKHOA = 'Tieng Anh' where MAKHOA = 'HA'
-----câu lệnh delete-----
alter table KETQUA 
drop constraint fk_ketqua_masv 

Delete from SINHVIEN where GIOITINH = 'Nam'
-----view--------
go
create view vwSINHVIEN
as
select SINHVIEN.MASV,TENSV,NGAYSINH,DIEM, XEPLOAI = case 
when DIEM < 5 then 'Trung Binh'
when DIEM >=5 and DIEM <=8 then 'Kha'
else 'Gioi'
end
from SINHVIEN join KETQUA on SINHVIEN.MASV=KETQUA.MASV 

select * from vwSINHVIEN
------trigger------
go
create trigger tgUpdateSINHVIEN
on SINHVIEN
instead of update 
as
begin 
  alter table SINHVIEN drop constraint fk_SINHVIEN_LOP
  update SINHVIEN set MALOP=(select MALOP from inserted) where MALOP=(select MALOP from deleted)
  update LOP set MALOP=(select MALOP from inserted) where MALOP=(select MALOP from deleted)
  alter table SINHVIEN add constraint fk_SINHVIEN_LOP foreign key(MALOP) references LOP(MALOP)
  end
update SINHVIEN set MALOP= 'TH23' where MALOP = 'TH32'
 select * from SINHVIEN
 select * from LOP
 -------function: "Tạo function cho biết mã sinh viên, tên sinh viên, tên lớp, mã môn học, tên môn học, lần thi và điểm thi của từng sinh viên."----------
 go
 create function Fn_Laydiemthi()
 returns table return 
   select SINHVIEN.TENSV,SINHVIEN.MASV,SINHVIEN.NGAYSINH,SINHVIEN.MALOP,SINHVIEN.GIOITINH,KETQUA.DIEM,KETQUA.LANTHI
   from SINHVIEN join LOP on SINHVIEN.MALOP=LOP.MALOP
   join KETQUA on KETQUA.MASV=SINHVIEN.MASV
   join MONHOC on KETQUA.MAMH=MONHOC.MAMH
 
 select*from Fn_Laydiemthi()