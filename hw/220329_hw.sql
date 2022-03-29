-------------------------------------------------------
-- 220329
-------------------------------------------------------
/*
1. EX_EMPLOYEE테이블의 퇴사자관리를 별도의 테이블 TBL_EMP_QUIT에서 하려고 한다.
다음과 같이 TBL_EMP_JOIN, TBL_EMP_QUIT테이블을 생성하고, TBL_EMP_JOIN에서 DELETE시 자동으로 퇴사자 데이터가 TBL_EMP_QUIT에 INSERT되도록 트리거를 생성하라.

-TBL_EMP_JOIN 테이블 생성 : EX_EMPLOYEE테이블에서 QUIT_DATE, QUIT_YN 컬럼제외하고 복사

-TBL_EMP_QUIT : EX_EMPLOYEE테이블에서 QUIT_YN 컬럼제외하고 복사

*/

-- 재직자 테이블
create table tbl_emp_join
as
select emp_id, emp_name, emp_no, email, phone, dept_code, job_code, sal_level, salary, bonus, manager_id, hire_date
from ex_employee
where quit_yn = 'N';

select * from tbl_emp_join;

-- 퇴사자 테이블
create table tbl_emp_quit
as
select emp_id, emp_name, emp_no, email, phone, dept_code, job_code, sal_level, salary, bonus, manager_id, hire_date, quit_date
from ex_employee
where quit_yn = 'Y';

select * from tbl_emp_quit;

-- 트리거 생성
create or replace trigger trig_tbl_emp_quit
    before
    delete on tbl_emp_join
    for each row
begin
    insert into tbl_emp_quit
    values(:old.emp_id, :old.emp_name, :old.emp_no, :old.email, :old.phone,
        :old.dept_code, :old.job_code, :old.sal_level, :old.salary, :old.bonus,
        :old.manager_id, :old.hire_date, sysdate);
end;
/

delete from tbl_emp_join where emp_id = '&퇴사자사번';

--rollback;
--commit;