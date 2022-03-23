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

-------------------------------------------------------
-- 220323
-------------------------------------------------------
-- #1번
-- 학생이름과 주소지를 표시하시오.
-- 단, 출력 헤더는 "학생 이름", "주소지"로 하고, 정렬은 이름으로 오름차순 표시하도록 한다.
select
    student_name "학생 이름",
    student_address 주소지
from tb_student
order by "학생 이름" ;



-- #2번
-- 휴학중인 학생들의 이름과 주민번호를 나이가 적은 순서로 화면에 출력하시오.
select
    student_name, student_ssn
from tb_student
where absence_yn = 'Y'
order by student_ssn desc ;


-- #3번
-- 주소지가 강원도나 경기도인 학생들 중 1900 년대 학번을 가진 학생들의 이름과 학번,
-- 주소를 이름의 오름차순으로 화면에 출력하시오.
-- 단, 출력헤더에는 "학생이름","학번", "거주지 주소" 가 출력되도록 한다
select
    student_name 학생이름,
    student_no 학번,
    student_address "거주지 주소"
from tb_student
where
    student_no not like 'A%'
    and student_address like '경기도%'
    or student_address like '강원도%' ;



-- #4번
-- 현재 법학과 교수 중 가장 나이가 많은 사람부터 이름을 확인할 수 있는 SQL 문장을 작성하시오.
-- (법학과의 '학과코드'는 학과 테이블(TB_DEPARTMENT)을 조회해서 찾아내도록 하자)
select
    professor_name,
    professor_ssn
from tb_professor
where
    department_no = (select department_no from tb_department where department_name = '법학과')
order by professor_ssn ;



-- #5번
-- 2004 년 2 학기에 'C3118100' 과목을 수강한 학생들의 학점을 조회하려고 한다.
-- 학점이 높은 학생부터 표시하고, 학점이 같으면 학번이 낮은 학생부터 표시하는 구문을 작성해보시오.
select
    student_no,
    to_char(point, '0.00') point
from tb_grade
where
    class_no = 'C3118100'
    and term_no = '200402'
order by 2 desc ;



-- #6번
-- 학생 번호, 학생 이름, 학과 이름을 학생 이름으로 오름차순 정렬하여 출력하는 SQL문을 작성하시오
select
    s.student_no,
    s. student_name,
    (select department_name from tb_department where s.department_no = department_no) department_name
from tb_student s
order by s.student_name ; -- 문제의 결과집합과 다르게 나온다 > 질문하기



-- #7번
-- 춘 기술대학교의 과목 이름과 과목의 학과 이름을 출력하는 SQL 문장을 작성하시오.
select
    class_name,
    (select department_name from tb_department where c.department_no = department_no) department_name
from tb_class c ;



-- #8번
-- 과목별 교수 이름을 찾으려고 한다. 과목 이름과 교수 이름을 출력하는 SQL 문을 작성하시오.
select
    (select class_name from tb_class where cp.class_no = class_no) class_name,
    (select professor_name from tb_professor where cp.professor_no = professor_no) professor_name
from tb_class_professor cp ;



-- #9번
-- 8 번의 결과 중 ‘인문사회’ 계열에 속한 과목의 교수 이름을 찾으려고 한다.
-- 이에 해당하는 과목 이름과 교수 이름을 출력하는 SQL 문을 작성하시오.
select
    class_name,
    (select professor_name from tb_professor where cp.professor_no = professor_no) professor_name
from
    tb_class_professor cp
        join tb_class c
            using(class_no)
        join tb_department d
            using(department_no)
where
    d.category = '인문사회' ;


-- #10번
--  ‘음악학과’ 학생들의 평점을 구하려고 한다. 음악학과 학생들의 "학번", "학생 이름",
-- "전체 평점"을 출력하는 SQL 문장을 작성하시오.
-- (단, 평점은 소수점 1 자리까지만 반올림하여 표시한다.)
select
    student_no 학번,
    student_name "학생 이름",
    round(student_avg_point, 1) "전체 평점"
from (
    select
        student_no,
        avg(point) student_avg_point,
        (select department_no from tb_student where g.student_no = student_no) department_no,
        (select student_name from tb_student where g.student_no = student_no) student_name
    from tb_grade g
    group by student_no
)
where
    department_no = (select department_no from tb_department where department_name = '음악학과')
order by 1 ;



-- #11번
-- 학번이 A313047 인 학생이 학교에 나오고 있지 않다.
-- 지도 교수에게 내용을 전달하기 위한 학과 이름, 학생 이름과 지도 교수 이름이 필요하다.
-- 이때 사용할 SQL 문을 작성하시오. 단, 출력헤더는 ‚학과이름‛, ‚학생이름‛, ‚지도교수이름‛으로 출력되도록 한다.
select
    (select department_name from tb_department where s.department_no = department_no) 학과이름,
    student_name 학생이름,
    (select professor_name from tb_professor where coach_professor_no = professor_no) 지도교수이름
from tb_student s
where
    student_no = 'A313047' ;



-- #12번
-- 2007 년도에 '인간관계론' 과목을 수강한 학생을 찾아 학생이름과 수강학기를 표시하는 SQL 문장을 작성하시오
select
    (select student_name from tb_student where g.student_no = student_no) student_name,
    term_no
from tb_grade g
where 
    substr(term_no, 1, 4) = '2007'
    and
    g.class_no = (select class_no from tb_class where class_name = '인간관계론')
order by 1 ;



-- #13번
-- 예체능 계열 과목 중 과목 담당교수를 한 명도 배정받지 못한 과목을 찾아
-- 그 과목 이름과 학과 이름을 출력하는 SQL 문장을 작성하시오.
select
    class_name,
    (select department_name from tb_department where c.department_no = department_no) department_name
from tb_class c
where
    department_no in (select department_no from tb_department where category = '예체능')
    and
    not exists (select * from tb_class_professor cp where cp.class_no = c.class_no)
order by 2;



-- #14번
-- 춘 기술대학교 서반아어학과 학생들의 지도교수를 게시하고자 한다.
-- 학생이름과 지도교수 이름을 찾고 만일 지도 교수가 없는 학생일 경우
-- "지도교수 미지정‛으로 표시하도록 하는 SQL 문을 작성하시오.
-- 단, 출력헤더는 '학생이름', '지도교수'로 표시하며 고학번 학생이 먼저 표시되도록 한다.
select
    student_name 학생이름,
    nvl((select professor_name from tb_professor where coach_professor_no = professor_no), '지도교수 미지정') 지도교수
from tb_student
where
    department_no = (select department_no from tb_department where department_name = '서반아어학과')
order by student_no ;



-- #15번
-- 휴학생이 아닌 학생 중 평점이 4.0 이상인 학생을 찾아
-- 그 학생의 학번, 이름, 학과 이름, 평점을 출력하는 SQL 문을 작성하시오.
select
    student_no 학번,
    student_name 이름,
    (select department_name from tb_department where t.department_no = department_no) "학과 이름",
    round(student_avg_point, 8) 평점
from (
    select s.*, (select avg(point) from tb_grade where s.student_no = student_no) student_avg_point
    from tb_student s
) t
where
    absence_yn = 'N' and
    student_avg_point >= 4.0
order by 1 ;


-- #16번
-- 환경조경학과 전공과목들의 과목 별 평점을 파악할 수 있는 SQL 문을 작성하시오.
select
    class_no,
    class_name,
    round(avg(point), 8)
from 
    tb_grade g join tb_class c
        using(class_no)
where
    department_no = (select department_no from tb_department where department_name = '환경조경학과')
    and c.class_type = '전공선택'
group by class_no, class_name
order by 1 ;


-- #17번
--  춘 기술대학교에 다니고 있는 최경희 학생과 같은 과 학생들의 이름과 주소를 출력하는 SQL 문을 작성하시오.
select
    student_name, student_address
from tb_student
where
    department_no = (select department_no from tb_student where student_name = '최경희') ;



-- #18번
-- 국어국문학과에서 총 평점이 가장 높은 학생의 이름과 학번을 표시하는 SQL 문을 작성하시오.
select
    student_no, student_name
from(
    select
        student_no,
        (select student_name from tb_student where g.student_no = student_no) student_name,
        avg(point)
    from tb_grade g
    where
        student_no in (select student_no from tb_student where department_no = 
                            (select department_no from tb_department where department_name = '국어국문학과'))
    group by student_no
    order by 3 desc
)t
where rownum = 1 ;



-- #19번
-- 춘 기술대학교의 "환경조경학과"가 속한 같은 계열 학과들의 학과 별 전공과목 평점을 파악하기 위한 적절한 SQL 문을 찾아내시오.
-- 단, 출력헤더는 "계열 학과명", "전공평점"으로 표시되도록 하고, 평점은 소수점 한 자리까지만 반올림하여 표시되도록 한다.
select
    department_name "계열 학과명",
    round(avg(point), 1) 전공평점
from
    tb_grade g 
        join tb_class c
            using(class_no)
        join tb_department d
            using(department_no)
where
    category = (select category from tb_department where department_name = '환경조경학과')
    and class_type = '전공선택'
group by department_name
order by 1 ;

