-------------------------------------------------------
-- 220322
-------------------------------------------------------
-- 문제1
-- 기술지원부에 속한 사람들의 사람의 이름,부서코드,급여를 출력하시오
select
    emp_name 이름,
    dept_code 부서코드,
    to_char(salary, 'fm999,999,999')급여
from employee e
where
    (select dept_title from department where dept_id = e.dept_code) = '기술지원부';


-- 문제2
-- 기술지원부에 속한 사람들 중 가장 연봉이 높은 사람의 이름,부서코드,급여를 출력하시오
select
    emp_name 이름,
    dept_code 부서코드,
    to_char(salary, 'fm999,999,999') 급여
from employee e left join department d
    on e.dept_code = d.dept_id
where
    (
        select max((salary + salary * nvl(bonus, 0)) * 12)
        from employee
        where dept_code = e.dept_code
        group by dept_code
    ) = (salary + salary * nvl(bonus, 0)) * 12
    and
    d.dept_title = '기술지원부' ;

-- 강사님 풀이
select *
from (
    select EMP_NAME 이름
        ,DEPT_CODE 부서코드
        ,(SALARY+SALARY*NVL(BONUS,0))*12 연봉
    from EMPLOYEE
    where DEPT_CODE=(select DEPT_ID from DEPARTMENT where DEPT_TITLE ='기술지원부')
    order by 연봉 desc
)
where rownum < 2; 



-- 문제3
-- 매니저가 있는 사원중에 월급이 전체사원 평균보다 많은 사원의  
-- 사번,이름,매니저 이름, 월급을 구하시오. 
/*
	1. JOIN을 이용하시오
	2. JOIN하지 않고, 스칼라상관쿼리(SELECT)를 이용하기
*/
-- 1. JOIN 이용
select
    e.emp_id 사번,
    e.emp_name 이름,
    m.emp_name "매니저 이름",
    to_char(e.salary, 'fm999,999,999') 월급
from
    employee e join employee m
        on e.manager_id = m.emp_id
where
    e.salary > (select avg(salary) from employee);

-- 2.스칼라 상관쿼리 이용
select
    e.emp_id 사번,
    e.emp_name 이름,
    (select emp_name from employee where e.manager_id = emp_id) 매니저이름,
    e.salary 월급
from employee e
where
    e.salary > (select avg(salary) from employee)
    and exists(select 1 from employee where e.manager_id = emp_id);



-- 문제4
-- 같은 직급의 평균급여보다 같거나 많은 급여를 받는 직원의 이름, 직급코드, 급여, 급여등급 조회
select
    emp_name 이름,
    job_code 직급코드,
    to_char(salary, 'fm999,999,999') 급여,
    sal_level 급여등급
from employee e
where salary >= (select avg(salary) from employee where e.job_code = job_code group by job_code)
order by job_code ;



-- 문제5
-- 부서별 평균 급여가 3000000 이상인 부서명, 평균 급여 조회
-- 단, 평균 급여는 소수점 버림, 부서명이 없는 경우 '인턴'처리
select distinct
    nvl((select dept_title from department where e.dept_code = dept_id), '인턴') 부서명,
    to_char(trunc(avg(salary) over(partition by dept_code)), 'fm999,999,999') 부서평균급여
from employee e
where
    (select avg(salary) from employee where dept_code = e.dept_code) >= 3000000 ;
-- 강사님 풀이
select nvl((select DEPT_TITLE from DEPARTMENT where DEPT_ID=EMPLOYEE.DEPT_CODE),'인턴') 부서명
        ,trunc(avg(SALARY),0) 평균급여
from EMPLOYEE 
group by DEPT_CODE
having avg(SALARY) >= 3000000;



-- 문제6
-- 직급의 연봉 평균보다 적게 받는 여자사원의
-- 사원명,직급명,부서명,연봉을 이름 오름차순으로 조회하시오
-- 연봉 계산 => (급여 + (급여*보너스))*12
select
    emp_name 사원명,
    (select job_name from job where job_code = e.job_code) 직급명,
    nvl((select dept_title from department where dept_id = e.dept_code), '인턴') 부서명,
    연봉,
    job_avg_sal 직급평균연봉,
    trunc(e.job_avg_sal)
from
(
    select
        t.*,
        decode(substr(emp_no, 8, 1), '2', '여', '4', '여', '남') gender,
        avg((salary + (salary * nvl(bonus, 0)))*12) over(partition by job_code) job_avg_sal,
        (salary + salary * nvl(bonus, 0)) * 12 연봉
    from employee t
)e
where
    e.job_avg_sal > 연봉
    and e.gender = '여'
order by emp_name ;

-- 강사님 풀이
with my_emp
as
(
    select 
        emp_name,
        nvl((select dept_title from department where dept_id = E.dept_code), '인턴') dept_title, 
        job_code,
        (select job_name from job where job_code = E.job_code) job_name,
        (salary + salary * nvl(bonus, 0)) * 12 annual_salary,
        decode(substr(emp_no,8,1), '2','여','4','여','남') gender
    from 
        employee E
)
select 
    *
from 
    my_emp E
where 
    gender = '여' 
    and 
    annual_salary < ( select avg((salary+salary*nvl(bonus,0))*12) 
                        from employee 
                        where job_code = E.job_code )
order by emp_name;
-- 강사님 풀이2
with my_emp
as
(
    select 
        emp_name,
        nvl((select dept_title from department where dept_id = E.dept_code), '인턴') dept_title, 
        (select job_name from job where job_code = E.job_code) job_name,
        (salary + salary * nvl(bonus, 0)) * 12 annual_salary,
        decode(substr(emp_no,8,1), '2','여','4','여','남') gender,
        avg((salary + salary * nvl(bonus, 0)) * 12) over(partition by job_code) avg_annual_salary_by_job_code
    from 
        employee E
)
select  *
from my_emp E
where 
    gender = '여' 
    and annual_salary < avg_annual_salary_by_job_code
order by emp_name;



-- 문제7
--다음 도서목록테이블을 생성하고, 공저인 도서만 출력하세요.
--공저 : 두명이상의 작가가 함께 쓴 도서
/*
create table tbl_books (
book_title  varchar2(50)
,author     varchar2(50)
,loyalty     number(5)
);

insert into tbl_books values ('반지나라 해리포터', '박나라', 200);
insert into tbl_books values ('대화가 필요해', '선동일', 500);
insert into tbl_books values ('나무', '임시환', 300);
insert into tbl_books values ('별의 하루', '송종기', 200);
insert into tbl_books values ('별의 하루', '윤은해', 400);
insert into tbl_books values ('개미', '장쯔위', 100);
insert into tbl_books values ('아지랑이 피우기', '이오리', 200);
insert into tbl_books values ('아지랑이 피우기', '전지연', 100);
insert into tbl_books values ('삼국지', '노옹철', 200);
insert into tbl_books values ('별의 하루', '대북혼', 300);
*/

select
    book_title "공저인 도서명"
from
(
    select book_title, count(*) author_count
    from tbl_books
    group by book_title
)
where author_count >= 2 ;
