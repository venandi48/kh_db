-- ====================================================
-- 실습문제 chun 계정
-- ====================================================

select * from tb_department; -- 학과
select * from tb_student; -- 학생
    -- (tb_department.department_no = tb_student.department_no)
    -- (tb_professor.professor_no = tb_student.coach_professor_no)
select * from tb_professor; -- 교수
    -- (tb_department.department_no = tb_professor.department_no)
select * from tb_class; -- 수업
    -- (tb_department.department_no = tb_class.department_no)
select * from tb_class_professor; -- 수업-교수
    -- (tb_class.class_no = tb_class_professor.class_no)
    -- (tb_professor.professor_no = tb_class_professor.professor_no)
select * from tb_grade; -- 학점
    -- (tb_student.student_no = tb_grade.student_no)
    -- (tb_class.class_no = tb_grade.class_no)

-------------------------------------------------------

-- #1번
--  춘 기술대학교의 학과 이름과 계열을 표시하시오. 단, 출력 헤더는 "학과 명", "계열" 으로 표시하도록 한다.
select
    department_name "학과 명",
    category 계열
from tb_department;



-- #2번
-- 학과의 학과 정원을 다음과 같은 형태로 화면에 출력한다.
/*
학과별 정원
------------------------------------------------
국어국문학과의 정원은 20 명 입니다.
영어영문학과의 정원은 36 명 입니다.
사학과의 정원은 28 명 입니다.
철학과의 정원은 28 명 입니다.
*/
select
    department_name || '의 정원은 ' || capacity || '명 입니다.' "학과별 정원"
from tb_department;



-- #3번
-- "국어국문학과" 에 다니는 여학생 중 현재 휴학중인 여학생을 찾아달라는 요청이 들어왔다. 누구인가?
-- (국문학과의 '학과코드'는 학과 테이블(TB_DEPARTMENT)을 조회해서 찾아 내도록 하자)
select s.student_name
from
    tb_student s left join tb_department d
        on s.department_no = d.department_no
where
    d.department_name = '국어국문학과'
    and s.absence_yn = 'Y'
    and substr(s.student_ssn, 8, 1) = '2';



-- #4번
--  도서관에서 대출 도서 장기 연체자 들을 찾아 이름을 게시하고자 한다.
-- 그 대상자들의 학번이 다음과 같을 때 대상자들을 찾는 적절한 SQL 구문을 작성하시오.
/*
    A513079, A513090, A513091, A513110, A513119
*/
select student_name
from tb_student
where student_no in ('A513079', 'A513090', 'A513091', 'A513110', 'A513119');



-- #5번
-- 입학정원이 20 명 이상 30 명 이하인 학과들의 학과 이름과 계열을 출력하시오.
select 
    department_name,
    category
from tb_department
where capacity between 20 and 30;



-- #6번
-- 춘 기술대학교는 총장을 제외하고 모든 교수들이 소속 학과를 가지고 있다.
-- 그럼 춘 기술대학교 총장의 이름을 알아낼 수 있는 SQL 문장을 작성하시오.
select professor_name
from tb_professor
where department_no is null;


-- #7번
-- 혹시 전산상의 착오로 학과가 지정되어 있지 않은 학생이 있는지 확인하고자 한다. 
-- 어떠한 SQL 문장을 사용하면 될 것인지 작성하시오
select *
from tb_student
where department_no is null;



-- #8번
-- 수강신청을 하려고 한다. 선수과목 여부를 확인해야 하는데,
-- 선수과목이 존재하는 과목들은 어떤 과목인지 과목번호를 조회해보시오.
select class_no
from tb_class
where preattending_class_no is not null;



-- #9번
--  춘 대학에는 어떤 계열(CATEGORY)들이 있는지 조회해보시오.
select distinct category
from tb_department;



-- #10번
-- 02 학번 전주 거주자들의 모임을 만들려고 한다.
-- 휴학한 사람들은 제외한 재학중인 학생들의 학번, 이름, 주민번호를 출력하는 구문을 작성하시오.
select
    student_no,
    student_name,
    student_ssn
from tb_student
where
    student_no like 'A2%'
    and student_address like '%전주시%'
    and absence_yn = 'N';
