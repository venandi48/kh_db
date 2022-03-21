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
-- 220318 실습문제 : INNER JOIN & OUTER JOIN
-------------------------------------------------------

-- #1번
-- 학번, 학생명, 담당교수명을 출력하세요.
-- 담당교수가 없는 학생은 '없음'으로 표시
select
    s.student_no 학번,
    s.student_name 학생명,
    nvl(p.professor_name, '없음') 담당교수명
from
    tb_student s left join tb_professor p
            on s.coach_professor_no = p.professor_no;


-- #2번
-- 학과별 교수명과 인원수를 모두 표시하세요.
select 
    d.department_name 학과,
    nvl(p.professor_name, ' - ') 교수명,
    nvl(tb_count.pro_count, 0) 학과교수인원수
from 
    tb_department d
        left join tb_professor p
            on d.department_no = p.department_no
        left join (
                    select
                        department_no,
                        count(professor_name) pro_count
                    from tb_professor
                    group by department_no
                ) tb_count
            on d.department_no = tb_count.department_no
order by d.department_name;

-- 강사님 답안
select decode(grouping(department_name),0,nvl(department_name,'미지정'),1,'총계') 학과명
       , decode(grouping(professor_name),0,professor_name,1,count(*)) 교수명  
from tb_professor p 
    left join tb_department d using(department_no)
group by rollup(department_name, professor_name )
order by d.department_name;

-- 다시 풀어보기
select
    decode(grouping(department_name), 0, nvl(department_name, '소속없음'), 1, '총계') 학과,
    decode(grouping(professor_name), 0, professor_name, 1, count(*)) 교수
from
    tb_department d
        right join tb_professor p
            using(department_no)
group by
    rollup(department_name, professor_name)
order by department_name
;

-- #3번
-- 이름이 [~람]인 학생의 평균학점을 구해서 학생명과 평균학점(반올림해서 소수점둘째자리까지)과 같이 출력.
-- (동명이인일 경우에 대비해서 student_name만으로 group by 할 수 없다.)
select
    s.student_name 학생명,
    s.student_no 학번,
    to_char(round(tb_avg.avg_point, 2), '0.00') 평균학점
from
    tb_student s join (
            select
                g.student_no avg_student_no,
                avg(g.point) avg_point
            from tb_grade g
            group by g.student_no) tb_avg
        on s.student_no = tb_avg.avg_student_no
where s.student_name like '%람'
order by s.student_name;

-- 강사님 답안
select
    student_name 학생명,
    round(avg(point),2) 평균학점
from tb_student s join tb_grade g using(student_no)
where student_name like '%람' 
group by student_no, student_name;


-- #4번
-- 학생별 다음정보를 구하라.
/*
--------------------------------------------
학생명  학기     과목명    학점
-------------------------------------------
감현제    200401    전기생리학     4.5
            .
            .
--------------------------------------------
*/
select
    s.student_name 학생명,
    g.term_no 학기,
    c.class_name 과목명,
    g.point 학점
from
    tb_student s
        join tb_grade g
            on s.student_no = g.student_no
        join tb_class c
            on g.class_no = c.class_no
order by 1, 2, 3;