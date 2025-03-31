-- выбор схемы для выполнения скрипта
SET search_path TO organization_structure;

WITH RECURSIVE hierarchy AS (
    -- начало с EmployeeID = 1
    SELECT
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM
        employees
    WHERE
        employeeID = 1

    UNION ALL

    -- рекурсивно найти всех подчиненных
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM
        employees e
    JOIN
        hierarchy eh ON e.ManagerID = eh.EmployeeID
)

-- список сотрудников и информации о них
SELECT
    eh.EmployeeID,
    eh.Name AS "EmployeeName",
    eh.ManagerID,
    d.DepartmentName AS "DepartmentName",
    r.RoleName AS "RoleName",
    STRING_AGG(DISTINCT p.ProjectName, ', ') AS "ProjectNames",
    STRING_AGG(DISTINCT t.TaskName, ', ') AS "TaskNames"
FROM
    hierarchy eh
LEFT JOIN
    departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN
    roles r ON eh.RoleID = r.RoleID
LEFT JOIN
    projects p ON p.DepartmentID = d.DepartmentID
LEFT JOIN
    tasks t ON t.AssignedTo = eh.EmployeeID
GROUP BY
    eh.EmployeeID, eh.Name, eh.ManagerID, d.DepartmentName, r.RoleName
ORDER BY
    eh.Name;